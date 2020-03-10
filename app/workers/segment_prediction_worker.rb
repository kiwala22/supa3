class SegmentPredictionWorker
   include Sidekiq::Worker
   sidekiq_options queue: "low"
   sidekiq_options retry: 3
   require "httparty"

   def perform()
      Gamer.find_each(batch_size: 1000) do |gamer|
         tickets = Ticket.where(gamer_id: id).order("created_at DESC")
         if tickets.blank?
            gamer.update_attributes(segment: "G")
         else
            days = ((Time.now - tickets.first.created_at)/1.days).to_i
            segment = find_segment(days)
            gamer.update_attributes(segment: segment)
         end
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
