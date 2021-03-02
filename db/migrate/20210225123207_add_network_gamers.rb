class AddNetworkGamers < ActiveRecord::Migration[5.2]
  def change
    add_column :gamers, :network, :string
    add_index :gamers, :network
  end
end
