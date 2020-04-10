class SentMessage < ApplicationRecord
  belongs_to :message
  belongs_to :subscriber

  enum status: %i[sent opened error]
end
