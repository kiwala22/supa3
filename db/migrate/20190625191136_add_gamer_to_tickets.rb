class AddGamerToTickets < ActiveRecord::Migration[5.2]
  def change
    add_reference :tickets, :gamer, foreign_key: true
  end
end
