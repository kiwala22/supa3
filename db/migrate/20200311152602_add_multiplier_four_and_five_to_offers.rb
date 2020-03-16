class AddMultiplierFourAndFiveToOffers < ActiveRecord::Migration[5.2]
  def change
    add_column :draw_offers, :multiplier_four, :integer
    add_column :draw_offers, :multiplier_five, :integer
  end
end
