class Ticket < ApplicationRecord
   audited
   paginates_per 100
   belongs_to :gamer
   require "send_sms"

  #  after_create :process_rewards

   def self.to_csv
     CSV.generate do |csv|
       column_names = %w(first_name last_name phone_number reference data amount number_matches win_amount keyword created_at)
       csv << column_names
       all.each do |result|
         csv << result.attributes.values_at(*column_names)
       end
     end
   end


   ##Method to check if a gamer has hit the target and get their reward

   def process_rewards
     gamer = Gamer.find(self.gamer_id)
     number_tickets_in_week = gamer.tickets.where("created_at >= ?", Time.now.beginning_of_week).count()

     if (gamer.prediction.present? && gamer.prediction.target >= 3)
       if ((number_tickets_in_week >= gamer.prediction.target) && gamer.prediction.rewarded != "Yes")
         RewardsWorker.perform_async(gamer.id, gamer.prediction.target)
       end
     end
   end

end
