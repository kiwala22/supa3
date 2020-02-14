class AddWinningNumberToDraws < ActiveRecord::Migration[5.2]
  def change
    add_column :draws, :winning_number, :string
  end
end
