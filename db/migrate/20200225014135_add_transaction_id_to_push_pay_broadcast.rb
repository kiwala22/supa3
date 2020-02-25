class AddTransactionIdToPushPayBroadcast < ActiveRecord::Migration[5.2]
  def change
    add_column :push_pay_broadcasts, :transaction_id, :string
  end
end
