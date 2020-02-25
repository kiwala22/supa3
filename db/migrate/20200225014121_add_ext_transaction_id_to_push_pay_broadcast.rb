class AddExtTransactionIdToPushPayBroadcast < ActiveRecord::Migration[5.2]
  def change
    add_column :push_pay_broadcasts, :ext_transaction_id, :string
  end
end
