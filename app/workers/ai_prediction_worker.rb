class AiPredictionWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: 3

  def perform

    ##First check for gamers who have not played in the last 3 months and either create a prediction if it is not already present
    Gamer.left_joins(:tickets).select(:id).where("tickets.created_at < ?", (Date.today.beginning_of_day - 90.days)).distinct.find_each(batch_size: 5000) do |gamer|
      prediction = Prediction.create_with(tickets: 0, probability: 0, target: 0, gamer_id: gamer.id).find_or_create_by(gamer_id: gamer.id).update(tickets: 0, probability: 0, target: 0)
    end

    sleep 5

    ##Then check for gamers who have played in the last 3 months
    Gamer.left_joins(:tickets).select(:id).where("tickets.created_at >= ?", (Date.today.beginning_of_day - 90.days)).distinct.find_each(batch_size: 5000) do |gamer|
      AiSegmentPredictionWorker.perform_async(gamer.id)
    end
  end
end
