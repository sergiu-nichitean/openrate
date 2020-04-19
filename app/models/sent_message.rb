class SentMessage < ApplicationRecord
  belongs_to :message
  belongs_to :subscriber

  enum status: %i[sent opened error]

  def update_error(error_message)
    self.status = :error
    self.error = error_message
    save
  end
end
