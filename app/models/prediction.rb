class Prediction < ApplicationRecord
  belongs_to :gamer

  def self.reminders
    ##Find all predictions with targets greater than zero and not yet rewarded
    predictions = Prediction.select(:target, :gamer_id).where("target > ? and rewarded = ?", 0, "No")

    predictions.each(batch_size: 1000) do |prediction|
      number_of_week_tickets = prediction.gamer.tickets.where("created_at >= ?", (Time.now.beginning_of_week)).count()
      if number_of_week_tickets == 0
        RemindersWorker.perform_async(prediction.target, prediction.gamer_id)
      end
    end
  end

end
