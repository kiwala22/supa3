class CreateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :results do |t|
      t.string :phone_number
      t.integer :matches
      t.datetime :time
      
      t.timestamps
    end
  end
end
