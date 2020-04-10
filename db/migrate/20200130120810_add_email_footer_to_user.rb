class AddEmailFooterToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :company_name, :string
    add_column :users, :email_footer, :text
  end
end
