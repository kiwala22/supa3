class AddUndefinedTicketsToDraws < ActiveRecord::Migration[5.2]
  def change
    add_column :draws, :undefined_tickets, :integer
  end
end
