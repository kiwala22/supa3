class AddRtpTicketsAndUsersToDraws < ActiveRecord::Migration[5.2]
  def change
    add_column :draws, :rtp, :decimal
    add_column :draws, :mtn_tickets, :integer
    add_column :draws, :airtel_tickets, :integer
    add_column :draws, :users, :integer
  end
end
