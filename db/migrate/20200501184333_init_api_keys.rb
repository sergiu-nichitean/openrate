class InitApiKeys < ActiveRecord::Migration[6.0]
  def change
    User.all.each { |u| u.update(api_key: SecureRandom.uuid) }
  end
end
