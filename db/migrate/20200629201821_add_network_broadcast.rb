class AddNetworkBroadcast < ActiveRecord::Migration[5.2]
  def change
    add_column :broadcasts, :network, :string
  end
end
