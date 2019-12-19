class AddNewUsersToDraw < ActiveRecord::Migration[5.2]
  def change
    add_column :draws, :new_users, :integer
  end
end
