class AddUserSegmentToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :segment, :string
    add_index :tickets, :segment
  end
end
