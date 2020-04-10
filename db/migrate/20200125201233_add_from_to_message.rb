class AddFromToMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :from, :string
  end
end
