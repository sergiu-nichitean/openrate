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

    puts "emails_sent = #{broadcast.message.emails_sent}, audience_size = #{broadcast.message.audience_size}"

    return unless broadcast.message.emails_sent == broadcast.message.audience_size

    puts 'Sent emails equals audience size, changing status to sent'
    broadcast.update_attribute(:status, 'sent')
  end

  def send_emails(broadcast, retry_delay)
    broadcast.subscribers.each do |subscriber|
      break if broadcast_canceled?(broadcast)

      next if broadcast.message.sent_messages.find_by(subscriber_id: subscriber.id)

      sent_message = SentMessage.create_from_broadcast(broadcast, subscriber)
      error_message = send_email(subscriber, broadcast, sent_message)

      handle_sent_message(sent_message, error_message, broadcast.id, retry_delay)
      break if throttling_error?(error_message)
    end
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

  def send_email(subscriber, broadcast, sent_message)
    puts "Sending email to subscriber with ID: #{subscriber.id}, email: #{subscriber.email}"
    mail = sent_message.generate_email
    mail.delivery_method.settings.merge! custom_smtp_settings(broadcast.user)

    begin
      mail.deliver_now!
      error_message = ''
    rescue StandardError => e
      error_message = e.to_s
    end

    puts "Error message: #{error_message}"
    error_message
  end

  def custom_smtp_settings(user)
    {
      address: user.smtp_address,
      port: user.smtp_port,
      user_name: user.smtp_user_name,
      password: user.smtp_password
    }
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
