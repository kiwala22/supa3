class AddApprovedByToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :approved_by, :int
  end
end
