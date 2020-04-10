class AddUnsubscribeTokenToSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :subscribers, :unsubscribe_token, :string
  end
end
