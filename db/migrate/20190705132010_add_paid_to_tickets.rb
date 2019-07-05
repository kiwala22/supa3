class AddPaidToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :paid, :boolean, default: false
  end
end
