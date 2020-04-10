class CreateSubscriberImports < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriber_imports do |t|
      t.references :user
      t.string :file_path

      t.timestamps
    end
  end
end
