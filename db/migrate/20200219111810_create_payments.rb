class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
