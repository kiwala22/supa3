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
      supa3_tickets = Ticket.where("phone_number = ? and created_at >= ? and game = ?", gamer.phone_number, (Time.now - 90.days), "Supa3").order("created_at DESC")
      supa5_tickets = Ticket.where("phone_number = ? and created_at >= ? and game = ?", gamer.phone_number, (Time.now - 90.days), "Supa5").order("created_at DESC")
      
      if supa3_tickets.blank?
        gamer.update_attributes(supa3_segment: "G")
      else
        ticket_time = supa3_tickets.first.created_at
        segment = find_segment(ticket_time)
        gamer.update_attributes(supa3_segment: segment)
      end

      if supa5_tickets.blank?
        gamer.update_attributes(supa5_segment: "G")
      else
        ticket_time = supa5_tickets.first.created_at
        segment = find_segment(ticket_time)
        gamer.update_attributes(supa5_segment: segment)
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
