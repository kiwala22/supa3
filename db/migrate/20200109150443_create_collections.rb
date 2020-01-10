class CreateCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :collections do |t|
      t.string :ext_transaction_id
      t.string :transaction_id
      t.string :resource_id
      t.string :receiving_fri
      t.string :currency
      t.decimal :amount, precision: 10, scale: 2
      t.string :phone_number
      t.string :status
      t.string :message

      t.timestamps
    end
  end
end
