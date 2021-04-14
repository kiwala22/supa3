class AiPredictionScriptWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: 3

  def perform

    Prediction.select(:id).where("rewarded = ?", "Yes").in_batches(of: 5000).update_all(rewarded: "No")

    # Gamer.left_outer_joins(:prediction).select(:id).where( predictions: { gamer_id: nil } ).find_each(batch_size: 5000) do |gamer|
    #   AiSegmentPredictionWorker.perform_async(gamer.id)
    # end

  end
end
