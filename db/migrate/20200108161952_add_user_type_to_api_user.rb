class AddUserTypeToApiUser < ActiveRecord::Migration[5.2]
  def change
    add_column :api_users, :user_type, :string
  end
end
