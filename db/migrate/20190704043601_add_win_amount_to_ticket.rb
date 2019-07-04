class AddWinAmountToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :win_amount, :decimal, precision: 10, scale: 2
  end
end
