class AddInitiatedByToPayment < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :initiated_by, :int
  end
end
