class CreatePushPayBroadcasts < ActiveRecord::Migration[5.2]
  def change
    create_table :push_pay_broadcasts do |t|
      t.string :phone_number
      t.integer :amount
      t.string :data
      t.string :status

      t.timestamps
    end
  end
end
