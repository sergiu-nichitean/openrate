class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  has_many :subscribers, -> { includes :tags }
  has_many :broadcasts
  has_many :sequences
  has_many :messages
  has_many :tags
  has_many :subscriber_imports

  before_create :set_api_key

  def set_api_key
    self.api_key = SecureRandom.uuid
  end
end
