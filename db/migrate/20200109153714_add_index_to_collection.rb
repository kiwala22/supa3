class AddIndexToCollection < ActiveRecord::Migration[5.2]
  def change
  	add_index :collections, :transaction_id
  	add_index :collections, :phone_number
  	add_index :collections, :ext_transaction_id
  end
end
