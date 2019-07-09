class AddFourMatchAndFiveMatchToDraws < ActiveRecord::Migration[5.2]
  def change
    add_column :draws, :four_match, :integer
    add_column :draws, :five_match, :integer
  end
end
