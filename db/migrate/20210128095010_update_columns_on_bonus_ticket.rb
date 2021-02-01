class UpdateColumnsOnBonusTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :bonus_tickets, :game, :string
    remove_column :bonus_tickets, :supa5_segment
    rename_column :bonus_tickets, :supa3_segment, :segment
  end
end
