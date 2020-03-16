class AddGameToDraw < ActiveRecord::Migration[5.2]
  def change
    add_column :draws, :game, :string, default: "Supa3"
<<<<<<< HEAD
    add_index :draws, :game
=======
>>>>>>> origin/feature_updates
  end
end
