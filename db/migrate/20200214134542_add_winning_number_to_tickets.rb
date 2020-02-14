class AddWinningNumberToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :winning_number, :string
  end
end
