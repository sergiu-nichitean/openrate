class UpdateStatsForMessages < ActiveRecord::Migration[6.0]
  def change
    change_column :messages, :audience_size, :integer, default: 0
    change_column :messages, :opens, :integer, default: 0
    change_column :messages, :clicks, :integer, default: 0
    change_column :messages, :unsubscribes, :integer, default: 0
  end
end
