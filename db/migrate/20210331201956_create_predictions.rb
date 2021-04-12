class CreatePredictions < ActiveRecord::Migration[5.2]
  def change
    create_table :predictions do |t|
      t.decimal :tickets, precision: 5, scale: 2
      t.decimal :probability, precision: 5, scale: 2
      t.integer :target
      t.references :gamer, foreign_key: true, index: {unique: true}

      t.timestamps
    end
  end
end
