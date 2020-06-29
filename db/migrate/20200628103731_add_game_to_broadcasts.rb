class AddGameToBroadcasts < ActiveRecord::Migration[5.2]
  def change
    add_column :broadcasts, :game, :string
  end
end
