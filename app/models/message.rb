class Message < ApplicationRecord
  belongs_to :user
  has_one :broadcast
  has_many :sent_messages

  # TODO: 3. Calculate Open Rate / Click Rate
end
