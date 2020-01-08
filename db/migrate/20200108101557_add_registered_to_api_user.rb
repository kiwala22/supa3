class AddRegisteredToApiUser < ActiveRecord::Migration[5.2]
  def change
    add_column :api_users, :registered, :boolean, default: false
  end
end
