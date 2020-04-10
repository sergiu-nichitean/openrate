class Subscriber < ApplicationRecord
  belongs_to :user
  has_many :sent_messages, dependent: :destroy
  has_and_belongs_to_many :tags

  before_create :set_unsubscribe_token

  def set_unsubscribe_token
    self.unsubscribe_token = SecureRandom.uuid
  end
end
