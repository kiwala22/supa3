class CreateDraws < ActiveRecord::Migration[5.2]
  def change
    create_table :draws do |t|
      t.datetime :draw_time
      t.decimal :revenue, precision: 12, scale: 2
      t.decimal :payout, precision: 12, scale: 2
      t.integer :two_match
      t.string :three_match
      t.integer :one_match
      t.integer :no_match
      t.integer :ticket_count

      t.timestamps
    end
  end
end
