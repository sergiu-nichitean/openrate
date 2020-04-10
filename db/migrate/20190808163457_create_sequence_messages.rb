class CreateSequenceMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :sequence_messages do |t|
      t.references :message, foreign_key: true
      t.references :sequence, foreign_key: true
      t.integer :order
      t.integer :delay

      t.timestamps
    end
  end
end
