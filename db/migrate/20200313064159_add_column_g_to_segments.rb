class AddColumnGToSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :segments, :g, :integer
  end
end
