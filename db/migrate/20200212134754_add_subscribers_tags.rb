class AddSubscribersTags < ActiveRecord::Migration[6.0]
  def change
    create_table :subscribers_tags, id: false do |t|
      t.belongs_to :subscriber
      t.belongs_to :tag
    end
  end
end
