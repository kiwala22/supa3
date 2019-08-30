class RemoveFourMatchAndFiveMatchFromDraws < ActiveRecord::Migration[5.2]
  def change
    remove_column :draws, :four_match, :integer
    remove_column :draws, :five_match, :integer
  end
end
