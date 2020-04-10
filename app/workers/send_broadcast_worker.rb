class SendBroadcastWorker
  include Sidekiq::Worker

  def perform(broadcast_id, retry_delay = 1)
    puts "Starting SendBroadcastWorker"

    broadcast = Broadcast.find(broadcast_id)

    if broadcast.status == 'scheduled'
      puts "Broadcast is scheduled, changing status to to_send"
      broadcast.update_attribute(:status, 'to_send')
    end

    send_emails(broadcast, retry_delay)

    sent_message_count = broadcast.message.sent_messages.count
    subscriber_count = broadcast.subscribers.count
    return unless sent_message_count == subscriber_count

    broadcast.update_attribute(:status, 'sent')
  end

  def send_emails(broadcast, retry_delay)
    broadcast.subscribers.each do |subscriber|
      next if broadcast.message.sent_messages.where(
        subscriber_id: subscriber.id
      ).first

      error_message = send_email(subscriber, broadcast)

      break if throttling_error?(error_message, broadcast.id, retry_delay)

      create_sent_message(broadcast, subscriber, error_message)
    end
  end

  def create_sent_message(broadcast, subscriber, error_message)
    puts "Creating sent_message for subscriber with ID: #{subscriber.id}, email: #{subscriber.email}"
    broadcast.message.sent_messages.create(
      subscriber_id: subscriber.id,
      status: error_message.empty? ? 'sent' : 'error',
      error: error_message
    )
  end

  def send_email(subscriber, broadcast)
    puts "Sending email to subscriber with ID: #{subscriber.id}, email: #{subscriber.email}"
    mail = generate_email(subscriber, broadcast)
    mail.delivery_method.settings.merge! custom_smtp_settings(broadcast.user)

    begin
      mail.deliver_now!
      error_message = ''
    rescue StandardError => e
      error_message = e.to_s
    end

    error_message
  end

  def generate_email(subscriber, broadcast)
    MessageMailer.with(
      to: subscriber.email,
      from: broadcast.message.from,
      subject: broadcast.message.subject,
      body: broadcast.message.content,
      footer: generate_footer(subscriber)
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

  def generate_footer(subscriber)
    host = 'https://www.openrate.io'
    token = subscriber.unsubscribe_token
    link = "<a href=\"#{host}/unsubscribe/#{token}/\">Unsubscribe</a>"
    subscriber.user.email_footer.gsub('{unsubscribe_link}', link)
  end

  def throttling_error?(error, broadcast_id, retry_delay)
    return unless error.match(/throttling/i)

    puts "Got throttling error: #{error}"

    new_delay = retry_delay * 2

    puts "Re-Scheduling worker in #{new_delay} minutes"
    SendBroadcastWorker.perform_in(
      new_delay.minutes, broadcast_id, new_delay
    )
  end
end
