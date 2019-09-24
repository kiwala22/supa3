class AddConfirmationToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :confirmation, :boolean, default: false
  end
end
