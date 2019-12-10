class AddDefaultToWinAmountInTickets < ActiveRecord::Migration[5.2]
  def change
    change_column_default :tickets, :win_amount, 0
  end
end
