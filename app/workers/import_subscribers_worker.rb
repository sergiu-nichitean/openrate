class ImportSubscribersWorker
  include Sidekiq::Worker

  def perform(feed_rows, import_id)
    errors = []
    feed_rows.shift

    feed_rows.each_with_index do |feed_row, i|
      next unless (errors_on_row = row_errors(feed_row))

      errors << { line_number: i + 2, errors: errors_on_row }
    end

    finalize_import(import_id, feed_rows, errors)
  end

  def finalize_import(import_id, feed_rows, errors)
    import = SubscriberImport.find(import_id)

    if errors.empty?
      import_all_rows(feed_rows, import)
    else
      import.update_attributes(
        status: :failed,
        error_messages: errors
      )
    end
  end

  def row_errors(row)
    email = row[2]
    if email.nil? || email.empty?
      'Email field is empty.'
    elsif !Devise.email_regexp.match(email)
      "Invalid email: #{email}"
    end
  end

  def import_all_rows(rows, import)
    rows.each do |row|
      next unless email_unique?(row, import.user_id)

      create_subscriber(row, import.user_id)
    end
    import.update_attribute(:status, :done)
  end

  def create_subscriber(row, user_id)
    Subscriber.create(
      first_name: row[0],
      last_name: row[1],
      email: row[2],
      tags: build_tags(row, user_id),
      user_id: user_id
    )
  end

  def build_tags(row, user_id)
    return [] if row[3].nil? || row[3].empty?

    tags = []
    row[3].split(',').map(&:strip).each do |tag_name|
      tags << Tag.find_or_create_by(name: tag_name, user_id: user_id)
    end
    tags
  end

  def email_unique?(row, user_id)
    Subscriber.find_by(user_id: user_id, email: row[2]).nil?
  end
end
