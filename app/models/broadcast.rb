class Broadcast < ApplicationRecord
  belongs_to :user
  belongs_to :message
  has_many :filters, dependent: :destroy

  scope :sending, -> { where(status: :to_send) }
  scope :drafts, -> { where(status: :draft) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :sent, -> { where(status: :sent).order(send_at: :desc) }
  scope :canceled, -> { where(status: :canceled) }

  accepts_nested_attributes_for :message

  enum status: %i[draft scheduled sent to_send canceled]

  def sent_messages
    message.sent_messages
  end

  def audience_size
    message.audience_size.to_i
  end

  def emails_sent
    message.emails_sent.to_i
  end

  def emails_sent_percentage
    percentage_from_total(emails_sent)
  end

  def opens
    message.opens.to_i
  end

  def opens_percentage
    percentage_from_total(opens)
  end

  def clicks
    message.clicks.to_i
  end

  def clicks_percentage
    percentage_from_total(clicks)
  end

  def unsubscribes
    message.unsubscribes
  end

  def send_emails
    SendBroadcastWorker.perform_async(id)
  end

  def schedule_emails
    SendBroadcastWorker.perform_at(send_at, id)
  end

  def subscribers
    return user.subscribers.order(id: :desc) if filters.empty?

    result = user.subscribers.order(id: :desc).includes(:tags)

    filters.each do |f|
      result = f.narrow_query(result)
    end

    result
  end

  private

  def percentage_from_total(count)
    return '0' if audience_size.zero?

    "#{'%0.2f' % (count.to_f * 100.to_f / audience_size.to_f)}%"
  end
end
