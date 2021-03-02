class PredictionWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: 3

  def perform
    ##First check for gamers who have not played in the last 3 months and ##Update them all to have segment G for the respective game types
    Gamer.left_joins(:tickets).select(:id).where("tickets.created_at < ?", (Date.today.beginning_of_day - 90.days)).distinct.in_batches(of: 50000).update_all(supa3_segment: "G", supa5_segment: "G")

    sleep 5

    ##Then check for gamers who have played in the last 3 months
    Gamer.left_joins(:tickets).select(:id).where("tickets.created_at >= ?", (Date.today.beginning_of_day - 90.days)).distinct.find_each(batch_size: 5000) do |gamer|
      SegmentPredictionWorker.perform_async(gamer.id)
    end
  end
end
