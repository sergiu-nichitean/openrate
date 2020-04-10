class CreateFilters < ActiveRecord::Migration[6.0]
  def change
    create_table :filters do |t|
      t.references :broadcast, null: false, foreign_key: true
      t.string :type
      t.string :operator
      t.string :value

      t.timestamps
    end
  end
end
