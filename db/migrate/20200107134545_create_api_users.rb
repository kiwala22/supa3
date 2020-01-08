class CreateApiUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :api_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :api_id
      t.string :api_key

      t.timestamps
    end
  end
end
