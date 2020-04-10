class GenerateUnsubscribeTokens < ActiveRecord::Migration[6.0]
  def change
    Subscriber.all.each do |s|
      next if s.unsubscribe_token

      s.update_attribute(:unsubscribe_token, SecureRandom.uuid)
    end
  end
end
