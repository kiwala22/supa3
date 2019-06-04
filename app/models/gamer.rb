class Gamer < ApplicationRecord

   validates :phone_number, uniqueness: true
   validates :phone_number, presence: true
   paginates_per 50

   def self.run_predictions
      Gamer.find_each(batch_size: 1000) do |user|
         SegmentPredictionWorker.perform_async(user.phone_number)
      end
   end
end
