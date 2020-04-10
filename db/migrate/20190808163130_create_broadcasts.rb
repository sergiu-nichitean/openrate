class CreateBroadcasts < ActiveRecord::Migration[5.2]
  def change
    create_table :broadcasts do |t|
      t.references :user, foreign_key: true
      t.references :message, foreign_key: true
      t.integer :status
      t.datetime :send_at

      t.timestamps
    end
  end
end
