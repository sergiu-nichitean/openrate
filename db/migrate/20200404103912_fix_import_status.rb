class FixImportStatus < ActiveRecord::Migration[6.0]
  def change
    rename_column :subscriber_imports, :errors, :error_message
  end
end
