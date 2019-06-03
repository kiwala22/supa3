class Gamer < ApplicationRecord

   validates :phone_number, uniqueness: true
   validates :phone_number, presence: true
   paginates_per 50

   def run_predictions
      SegmentPredictionWorker.perform_async()
   end
end
