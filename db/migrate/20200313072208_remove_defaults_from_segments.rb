class RemoveDefaultsFromSegments < ActiveRecord::Migration[5.2]
  def change
    change_column_default :segments, :created_at, nil
    change_column_default :segments, :created_at, nil
  end
end
