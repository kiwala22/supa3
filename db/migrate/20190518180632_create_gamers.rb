class CreateGamers < ActiveRecord::Migration[5.2]
  def change
    create_table :gamers do |t|
      t.string :phone_number
      t.decimal :probability_to_play, precision: 5, scale: 2
      t.decimal :predicted_revenue, precision: 8, scale: 2
      t.string :segment

      t.timestamps
    end
    add_index :gamers, :phone_number, unique: true
  end
end
