class AddStatusToSnapshotSubscriber < ActiveRecord::Migration[6.0]
  def change
    add_column :snapshot_subscribers, :status, :integer
  end
end
