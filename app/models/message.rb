class Message < ApplicationRecord
  belongs_to :user
  has_one :broadcast
  has_many :sent_messages

  # TODO: 1. Calculate Open Rate / Click Rate
  # TODO: 2. Add rule: if opened, add tag, if clicked add tag
end
