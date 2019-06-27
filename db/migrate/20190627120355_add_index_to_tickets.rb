class AddIndexToTickets < ActiveRecord::Migration[5.2]
  def change
     add_index :tickets, :reference
  end
end
