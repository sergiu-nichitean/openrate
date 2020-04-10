json.extract! message, :id, :subject, :content, :user_id, :created_at, :updated_at
json.url message_url(message, format: :json)
