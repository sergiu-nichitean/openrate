class RemoveBroadcastIdFromSentMessages < ActiveRecord::Migration[6.0]
  def change
    remove_column :sent_messages, :broadcast_id
  end
end
