class RemoveNullFalseOnSegmentsTimestamps < ActiveRecord::Migration[5.2]
  def change
    change_column :segments, :created_at, :datetime, :null => true
    change_column :segments, :updated_at, :datetime, :null => true
  end
end
