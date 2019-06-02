class AddExecutionTimeToBroadcast < ActiveRecord::Migration[5.2]
  def change
    add_column :broadcasts, :execution_time, :datetime
  end
end
