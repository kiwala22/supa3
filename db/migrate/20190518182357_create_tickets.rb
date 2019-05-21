class CreateTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :tickets do |t|
      t.string :phone_number
      t.decimal :amount, precision: 10, scale: 2
      t.datetime :time
      t.integer :number_matches
      t.string :reference

      t.timestamps
    end
  end
end
