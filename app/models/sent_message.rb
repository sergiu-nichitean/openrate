class SentMessage < ApplicationRecord
  belongs_to :message
  belongs_to :subscriber

  enum status: %i[sent opened error clicked]

  def update_error(error_message)
    self.status = :error
    self.error = error_message
    save
  end

  def replace_subscriber_vars(text)
    text.gsub('{{first_name}}', subscriber.first_name)
        .gsub('{{last_name}}', subscriber.last_name)
  end

  def content_replace_all_vars
    newcontent = add_click_tracking(message.content)
    replace_subscriber_vars(newcontent)
  end

  def generate_footer
    host = 'https://openrate.io'
    token = subscriber.unsubscribe_token
    url = "#{host}/unsubscribe/#{token}/#{message_id}"
    link = "<a href=\"#{url}\">Unsubscribe</a>"

    footer = add_click_tracking(subscriber.user.email_footer)
             .gsub('{{unsubscribe_link}}', link)
             .gsub!('{{unsubscribe_url}}', url)
    "#{footer} <img src=\"#{host}/trackpx/#{id}/openrateio.jpg\">"
  end

  def click_track_url(url)
    "https://openrate.io/trackcl/#{id}?url=#{CGI.escape(url)}"
  end

  def add_click_tracking(text)
    newtext = text.dup
    newtext.scan(/<a.*?href=["|']http(.*?)["|']/i).flatten.each do |url|
      newtext.gsub!(
        /<a(.*?)href=["|']http#{url}["|']/i,
        '<a\1href="' + click_track_url("http#{url}") + '"'
      )
    end
    newtext
  end

  def generate_email
    MessageMailer.with(
      to: subscriber.email,
      from: message.from,
      subject: replace_subscriber_vars(message.subject),
      body: content_replace_all_vars,
      footer: generate_footer
    ).regular_email
  end

  def trigger_open
    message.open_rule&.trigger_event(subscriber)
  end

  def trigger_click
    message.click_rule&.trigger_event(subscriber)
  end

  def self.create_from_broadcast(broadcast, snapshot_subscriber)
    return if snapshot_subscriber.subscriber.nil?

    broadcast.message.increment!(:emails_sent)
    snapshot_subscriber.update(status: 'done')
    broadcast.message.sent_messages.create(
      subscriber_id: snapshot_subscriber.subscriber_id, status: 'sent'
    )
  end
end
