class AddIndexToTicketsColumns < ActiveRecord::Migration[5.2]
  def change
    add_index :tickets, :phone_number
    add_index :tickets, :amount
    add_index :tickets, :time
    add_index :tickets, :number_matches
    add_index :tickets, :win_amount
    add_index :tickets, :data
    add_index :tickets, :paid
  end
end
