class AddTicketReferenceAndRemoveTimeJackpot < ActiveRecord::Migration[5.2]
  def change
    add_column :jackpots, :ticket_reference, :string
    remove_column :jackpots, :time, :datetime
  end
end
