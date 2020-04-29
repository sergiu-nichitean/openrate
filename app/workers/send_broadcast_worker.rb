class SendBroadcastWorker
  include Sidekiq::Worker

  def perform(broadcast_id, retry_delay = 1)
    puts 'Starting SendBroadcastWorker'

    broadcast = Broadcast.find(broadcast_id)

    if broadcast.status == 'scheduled'
      puts 'Broadcast is scheduled, changing status to to_send'
      broadcast.update_attribute(:status, 'to_send')
    end

    send_emails(broadcast, retry_delay)

    return unless broadcast.message.emails_sent == broadcast.message.audience_size

    broadcast.update_attribute(:status, 'sent')
  end

  def send_emails(broadcast, retry_delay)
    broadcast.subscribers.each do |subscriber|
      break if broadcast_canceled?(broadcast)

      next if broadcast.message.sent_messages.find_by(subscriber_id: subscriber.id)

      sent_message = create_sent_message(broadcast, subscriber)
      error_message = send_email(subscriber, broadcast, sent_message.id)

      handle_sent_message(sent_message, error_message, broadcast.id, retry_delay)
      break if throttling_error?(error_message)
    end
  end

  def create_sent_message(broadcast, subscriber)
    puts "Creating sent_message for subscriber with ID: #{subscriber.id}, email: #{subscriber.email}"
    broadcast.message.increment!(:emails_sent)
    broadcast.message.sent_messages.create(
      subscriber_id: subscriber.id, status: 'sent'
    )
  end

  def sent_message_error(error_message, sent_message)
    return if error_message.empty?

    sent_message.update(status: 'error', error: error_message)
  end

  def handle_sent_message(sent_message, error_message, broadcast_id, retry_delay)
    if throttling_error?(error_message)
      sent_message.destroy
      reschedule_worker(broadcast_id, retry_delay)
    else
      sent_message_error(error_message, sent_message)
    end
  end

  def send_email(subscriber, broadcast, sent_message_id)
    puts "Sending email to subscriber with ID: #{subscriber.id}, email: #{subscriber.email}"
    mail = generate_email(subscriber, broadcast, sent_message_id)
    mail.delivery_method.settings.merge! custom_smtp_settings(broadcast.user)

    begin
      mail.deliver_now!
      error_message = ''
    rescue StandardError => e
      error_message = e.to_s
    end

    error_message
  end

  def generate_email(subscriber, broadcast, sent_message_id)
    MessageMailer.with(
      to: subscriber.email,
      from: broadcast.message.from,
      subject: replace_subscriber_vars(subscriber, broadcast.message.subject),
      body: replace_subscriber_vars(subscriber, broadcast.message.content),
      footer: generate_footer(subscriber, broadcast.message, sent_message_id)
    ).regular_email
  end

  def custom_smtp_settings(user)
    {
      address: user.smtp_address,
      port: user.smtp_port,
      user_name: user.smtp_user_name,
      password: user.smtp_password
    }
  end

  def replace_subscriber_vars(subscriber, text)
    text.gsub('{{first_name}}', subscriber.first_name)
        .gsub('{{last_name}}', subscriber.last_name)
  end

  def generate_footer(subscriber, message, sent_message_id)
    host = 'https://openrate.io'
    token = subscriber.unsubscribe_token
    url = "#{host}/unsubscribe/#{token}/#{message.id}"
    link = "<a href=\"#{url}\">Unsubscribe</a>"
    footer = subscriber.user.email_footer.gsub('{{unsubscribe_link}}', link)
    footer = footer.gsub('{{unsubscribe_url}}', url)
    "#{footer} <img src=\"https://openrate.io/trackpx/#{sent_message_id}/openrateio.jpg\">"
  end

  def throttling_error?(error)
    return unless error.match(/throttling/i)
  end

  def reschedule_worker(broadcast_id, retry_delay)
    puts "Got throttling error: #{error}"
    new_delay = retry_delay * 2
    puts "Re-Scheduling worker in #{new_delay} minutes"
    SendBroadcastWorker.perform_in(
      new_delay.minutes, broadcast_id, new_delay
    )
  end

  def broadcast_canceled?(broadcast)
    Broadcast.select(:status).where(id: broadcast.id).first.status == 'canceled'
  end
end
