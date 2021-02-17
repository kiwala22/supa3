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
     tickets = gamer.tickets.select(:created_at, :game).where("created_at >= ?", (Time.now - 90.days)).order("created_at DESC")

     ##Data manipulation
     supa3 = tickets.where("game = ?",'supa3').first
     supa5 = tickets.where("game = ?",'supa5').first

     ##Work out segment for supa3
     if supa3.blank?
       gamer.update_attributes(supa3_segment: "G")
     else
       supa3_ticket_time = supa3.created_at
       segment = find_segment(supa3_ticket_time)
       gamer.update_attributes(supa3_segment: segment)
     end

     ##Work out segment for supa5
     if supa5.blank?
       gamer.update_attributes(supa5_segment: "G")
     else
       supa5_ticket_time = supa5.created_at
       segment = find_segment(supa5_ticket_time)
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
