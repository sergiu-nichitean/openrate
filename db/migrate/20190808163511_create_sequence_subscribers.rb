class CreateSequenceSubscribers < ActiveRecord::Migration[5.2]
  def change
    create_table :sequence_subscribers do |t|
      t.references :sequence, foreign_key: true
      t.references :subscriber, foreign_key: true

      t.timestamps
    end
  end
end
