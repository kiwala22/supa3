class AddRewardedToPredictions < ActiveRecord::Migration[5.2]
  def change
    add_column :predictions, :rewarded, :string
  end
end
