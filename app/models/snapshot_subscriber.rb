class SnapshotSubscriber < ApplicationRecord
  belongs_to :subscriber
  belongs_to :message

  enum status: %i[pending done]
end
