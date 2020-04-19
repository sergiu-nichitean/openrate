class AddUnsubscribedToSentMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :sent_messages, :unsubscribed, :boolean
  end
end
