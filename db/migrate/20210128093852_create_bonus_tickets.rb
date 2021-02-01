class CreateBonusTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :bonus_tickets do |t|
      t.string :supa3_segment
      t.string :supa5_segment
      t.datetime :expiry
      t.integer :multiplier , default: 1

      t.timestamps
    end
  end
end
