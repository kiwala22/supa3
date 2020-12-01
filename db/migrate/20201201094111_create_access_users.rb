class CreateAccessUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :access_users do |t|
      t.string :first_name
      t.string :last_name
      t.string :token

      t.timestamps
    end
  end
end
