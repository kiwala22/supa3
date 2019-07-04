class AddDrawToTicket < ActiveRecord::Migration[5.2]
  def change
    add_reference :tickets, :draw, foreign_key: true
  end
end
