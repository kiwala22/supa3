class AddNetworkToCollection < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :network, :string
  end
end
