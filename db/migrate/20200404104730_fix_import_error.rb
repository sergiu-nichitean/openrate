class FixImportError < ActiveRecord::Migration[6.0]
  def change
    rename_column :subscriber_imports, :error_message, :error_messages
  end
end
