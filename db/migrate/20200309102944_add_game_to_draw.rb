class AddGameToDraw < ActiveRecord::Migration[5.2]
  def change
    add_column :draws, :game, :string, default: "Supa3"
    add_index :tickets, :game
  end
end
