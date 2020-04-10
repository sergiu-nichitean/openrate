class Broadcast < ApplicationRecord
  belongs_to :user
  belongs_to :message
  has_many :filters

  accepts_nested_attributes_for :message

  enum status: %i[draft scheduled sent to_send]

  def sent_messages
    message.sent_messages
  end

  def send_emails
    SendBroadcastWorker.perform_async(id)
  end

  def schedule_emails
    SendBroadcastWorker.perform_at(send_at, id)
  end

  def subscribers
    return user.subscribers if filters.empty?

    result = user.subscribers.includes(:tags)

    filters.each do |f|
      result = f.narrow_query(result)
    end

    result
  end
end
