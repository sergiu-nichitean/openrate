class Sequence < ApplicationRecord
  belongs_to :user
  has_many :messages, through: :sequence_message
end
