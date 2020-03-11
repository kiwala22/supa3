class SegmentPredictionWorker
   include Sidekiq::Worker
   include Sidekiq::Throttled::Worker

   sidekiq_throttle({
       # Allow maximum 10 concurrent jobs of this class at a time.
       :concurrency => { :limit => 10 }
     })

   sidekiq_options queue: "low"
   sidekiq_options retry: 3
   require "httparty"

   def perform(id)
      gamer = Gamer.find(id)
      tickets = Ticket.where("phone_number = ? and created_at >= ?", gamer.phone_number, (Time.now - 90.days)).order("created_at DESC")
      if tickets.blank?
        gamer.update_attributes(segment: "F")
      else
        days = ((Time.now - tickets.first.time)/1.days).to_i
        segment = find_segment(days)
        gamer.update_attributes(segment: segment)
      end
   end

   def find_segment(days)
      case days
      when 0..7
         return "A"
      when 8..14
         return "B"
      when 15..30
         return "C"
      when 31..60
         return "D"
      when 61..90
         return "E"
      else
         return "F"
      end
   end
end
