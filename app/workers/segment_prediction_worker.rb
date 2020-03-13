class SegmentPredictionWorker
   include Sidekiq::Worker
   include Sidekiq::Throttled::Worker

   sidekiq_throttle({
       # Allow maximum 10 concurrent jobs of this class at a time.
       :concurrency => { :limit => 20 }
     })

   sidekiq_options queue: "low"
   sidekiq_options retry: 3
   require "httparty"

   def perform(id)
      gamer = Gamer.find(id)
      tickets = Ticket.where("phone_number = ? and created_at >= ?", gamer.phone_number, (Time.now - 90.days)).order("created_at DESC")
      if tickets.blank?
        gamer.update_attributes(segment: "G")
      else
        ticket_time = tickets.first.created_at
        segment = find_segment(ticket_time)
        gamer.update_attributes(segment: segment)
      end
   end

   def find_segment(ticket_time)
      days = ((Time.now - ticket_time)/1.days).to_i
      start_of_week = Time.now.beginning_of_week
      this_week = ticket_time >= start_of_week
      case
      when days <= 7 && this_week == true
         return "A"
      when days <= 7 && this_week == false
         return "B"
      when days >= 8 && days <= 14
         return "C"
      when days >= 15 && days <= 30
         return "D"
      when days >= 31 && days <= 60
         return "E"
      else
         return "F"
      end
   end
end
