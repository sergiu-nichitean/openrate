class AddErrorsToImports < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriber_imports, :errors, :json
  end
end
