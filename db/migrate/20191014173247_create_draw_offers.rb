class CreateDrawOffers < ActiveRecord::Migration[5.2]
  def change
    create_table :draw_offers do |t|
      t.integer :multiplier_one
      t.integer :multiplier_two
      t.integer :multiplier_three
      t.datetime :expiry_time
      t.string :segment

      t.timestamps
    end
  end
end
