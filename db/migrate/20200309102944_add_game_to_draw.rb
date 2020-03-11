class AddGameToDraw < ActiveRecord::Migration[5.2]
  def change
    add_column :draws, :game, :string, default: "Supa3"
  end
end
