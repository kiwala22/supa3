class CreateSupa3Segments < ActiveRecord::Migration[5.2]
  def change
    create_table :supa3_segments do |t|
      t.integer :a
      t.integer :b
      t.integer :c
      t.integer :d
      t.integer :e
      t.integer :f
      t.integer :g

      t.timestamps
    end
  end
end
