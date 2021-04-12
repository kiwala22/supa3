class Prediction < ApplicationRecord
  belongs_to :gamer

  def self.reminders
    ##Find all predictions with targets greater than zero
    predictions = get_predictions()

    predictions.each(batch_size: 1000) do |prediction|
      RemindersWorker.perform_async(prediction.target, prediction.gamer_id)
    end
  end

  def self.rewards
    ##Find all predictions with targets greater than zero
    predictions = get_predictions()

    predictions.each(batch_size: 1000) do |prediction|
      RewardsWorker.perform_async(prediction.target, prediction.gamer_id)
    end
  end

  private

  def get_predictions
    predictions = Prediction.select(:target, :gamer_id).where("target > ?", 0)
    return predictions
  end

end
