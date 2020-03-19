class CreateJackpots < ActiveRecord::Migration[5.2]
  def change
    create_table :jackpots do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :ticket_id
      t.datetime :time
      t.string :game
      t.boolean :jackpot, default: false

      t.timestamps
    end
  end
end
