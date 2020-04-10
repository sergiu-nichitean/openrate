class AddStatusToImports < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriber_imports, :status, :integer
  end
end
