class CreateDisbursements < ActiveRecord::Migration[5.2]
  def change
    create_table :disbursements do |t|
      t.string :ext_transaction_id
      t.string :currency, default: 'UGX'
      t.string :transaction_id
      t.decimal :amount, precision: 10, scale: 2
      t.string :phone_number
      t.string :status
      t.string :message
      t.string :network

      t.index :ext_transaction_id
      t.index :transaction_id
      t.index :phone_number

      t.timestamps
    end
  end
end
