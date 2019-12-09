class AddRevenueAndMethodToBroadcasts < ActiveRecord::Migration[5.2]
  def change
    add_column :broadcasts, :predicted_revenue_lower, :decimal, precision: 8, scale: 2
    add_column :broadcasts, :predicted_revenue_upper, :decimal, precision: 8, scale: 2
    add_column :broadcasts, :method, :string
  end
end
