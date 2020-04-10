class SubscriberImport < ApplicationRecord
  belongs_to :user
  enum status: %i[pending running failed done]

  after_create :set_initial_status

  def file_validation_error
    @feed_rows = CSV.read(file_path, col_sep: "\t")
    if @feed_rows[0] == ['First Name', 'Last Name', 'Email', 'Tags']
      nil
    else
      'The uploaded CSV has invalid columns.'
    end
  rescue ArgumentError
    'The uploaded file is not a valid CSV'
  end

  def start_import
    update_attribute(:status, :running)
    ImportSubscribersWorker.perform_async(@feed_rows, id)
  end

  def set_initial_status
    update_attribute(:status, :pending)
  end
end
