class Subscriber < ApplicationRecord
  belongs_to :user
  has_many :sent_messages, dependent: :destroy
  has_and_belongs_to_many :tags

  before_create :set_unsubscribe_token

  def set_unsubscribe_token
    self.unsubscribe_token = SecureRandom.uuid
  end

  def self.bulk_remove_by_emails(emails, user_id)
    deleted = Subscriber.where(email: emails, user_id: user_id).destroy_all
    if deleted.count == emails.count
      'Subscribers successfully deleted.'
    else
      not_found = emails - deleted.map(&:email)
      "#{deleted.count} subscribers successfully deleted. Emails not found: #{not_found.join(', ')}"
    end
  end
end
