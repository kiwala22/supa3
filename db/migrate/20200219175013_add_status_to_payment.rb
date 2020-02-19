class AddStatusToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :status, :string
  end
end
