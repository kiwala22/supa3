class AddDataToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :data, :string
  end
end
