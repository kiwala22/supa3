class AddFirstAndLastNamesToGamers < ActiveRecord::Migration[5.2]
  def change
    add_column :gamers, :first_name, :string
    add_column :gamers, :last_name, :string
  end
end
