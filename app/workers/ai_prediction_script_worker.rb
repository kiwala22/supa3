class AiPredictionScriptWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: 3

  def perform

    Gamer.left_outer_joins(:prediction).select(:id).where( predictions: { gamer_id: nil } ).find_each(batch_size: 5000) do |gamer|
      AiSegmentPredictionWorker.perform_async(gamer.id)
    end

  end
end
