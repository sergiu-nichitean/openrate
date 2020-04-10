class CreateSequences < ActiveRecord::Migration[5.2]
  def change
    create_table :sequences do |t|
      t.string :name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
