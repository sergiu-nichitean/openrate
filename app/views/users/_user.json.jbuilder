json.extract! user, :id, :first_name, :last_name, :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :smtp_address, :smtp_port, :smtp_user_name, :smtp_password, :use_zapier, :api_key, :created_at, :updated_at
json.url user_url(user, format: :json)
