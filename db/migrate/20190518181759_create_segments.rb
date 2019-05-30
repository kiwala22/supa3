class CreateSegments < ActiveRecord::Migration[5.2]
  def change
    create_table :segments do |t|
      t.integer :a
      t.integer :b
      t.integer :c
      t.integer :d
      t.integer :e
      t.integer :f


      t.timestamps
    end
  end
end
