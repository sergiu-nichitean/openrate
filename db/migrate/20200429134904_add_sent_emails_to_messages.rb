class AddSentEmailsToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :emails_sent, :integer, default: 0, nil: false
  end
end
