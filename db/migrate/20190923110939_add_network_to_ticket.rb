class AddNetworkToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :network, :string
  end
end
