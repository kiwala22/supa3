class AddTicketTypeToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :ticket_type, :string
  end
end
