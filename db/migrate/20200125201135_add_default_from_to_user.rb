class AddDefaultFromToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :default_from, :string
  end
end
