class CreateSentMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :sent_messages do |t|
      t.references :message, foreign_key: true
      t.references :subscriber, foreign_key: true
      t.references :broadcast, foreign_key: true
      t.integer :status
      t.text :error
      t.datetime :sent_at

      t.timestamps
    end
  end
end
