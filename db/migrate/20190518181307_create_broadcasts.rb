class CreateBroadcasts < ActiveRecord::Migration[5.2]
  def change
    create_table :broadcasts do |t|
      t.string :status
      t.string :message
      t.integer :contacts
      t.references :user, foreign_key: true
      t.string :segment

      t.timestamps
    end
  end
end
