class CreateRules < ActiveRecord::Migration[6.0]
  def change
    create_table :rules do |t|
      t.references :message, null: false, foreign_key: true
      t.integer :trigger
      t.string :action_class
      t.integer :action_id

      t.timestamps
    end
  end
end
