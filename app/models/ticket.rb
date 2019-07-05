class Ticket < ApplicationRecord
   paginates_per 100
   belongs_to :gamer

   require "send_sms"

   def self.run_draws
      # Pick start and stop time
      start_time = Time.now().beginning_of_minute
      end_time = Time.now
      DrawWorker.perform_async(start_time, end_time)
   end
end
