class SequenceMessage < ApplicationRecord
  belongs_to :message
  belongs_to :sequence
end
