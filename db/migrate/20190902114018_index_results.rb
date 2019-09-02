class IndexResults < ActiveRecord::Migration[5.2]
  def change
    add_index :results, :phone_number
    add_index :results, :matches
    add_index :results, :time
  end
end
