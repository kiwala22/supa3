class AddIndexTicketsOnNetwork < ActiveRecord::Migration[5.2]
  def change
    add_index :tickets, :network
  end
end
