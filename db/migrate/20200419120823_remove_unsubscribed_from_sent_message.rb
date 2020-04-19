class RemoveUnsubscribedFromSentMessage < ActiveRecord::Migration[6.0]
  def change
    remove_column :sent_messages, :unsubscribed
  end
end
