class AddKeywordsToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :keyword, :string
  end
end
