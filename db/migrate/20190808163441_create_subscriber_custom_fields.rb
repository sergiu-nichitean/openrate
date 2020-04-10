class CreateSubscriberCustomFields < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriber_custom_fields do |t|
      t.references :subscriber, foreign_key: true
      t.references :custom_field, foreign_key: true
      t.text :value

      t.timestamps
    end
  end
end
