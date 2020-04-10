class SubscriberCustomField < ApplicationRecord
  belongs_to :subscriber
  belongs_to :custom_field
end
