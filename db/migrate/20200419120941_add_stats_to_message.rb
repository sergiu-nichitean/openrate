class AddStatsToMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :audience_size, :integer
    add_column :messages, :opens, :integer
    add_column :messages, :clicks, :integer
    add_column :messages, :unsubscribes, :integer
  end
end
