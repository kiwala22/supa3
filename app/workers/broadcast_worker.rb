class BroadcastWorker
   include Sidekiq::Worker
   sidekiq_options queue: "default"
   sidekiq_options retry: false

   require 'send_sms'

   def perform(broadcast_id)
      @broadcast = Broadcast.find(broadcast_id)
      if !@broadcast.segment.nil?
        @gamers = Gamer.where(segment: @broadcast.segment.split(","))
      end
      if !@broadcast.predicted_revenue_lower.nil? && @broadcast.predicted_revenue_upper.nil?
        lower = @broadcast.predicted_revenue_lower
        @gamers = Gamer.where("predicted_revenue >= ?",lower)
      end
      if !@broadcast.predicted_revenue_lower.nil? && !@broadcast.predicted_revenue_upper.nil?
        lower = @broadcast.predicted_revenue_lower
        upper = @broadcast.predicted_revenue_upper
        @gamers = Gamer.where("predicted_revenue >= ? and predicted_revenue <= ?",lower, upper)
      end
      contacts = 0
      @gamers.each do |gamer|
         #send the message to message library
         if SendSMS.process_sms_now(transaction: false, receiver: gamer.phone_number, content: @broadcast.message, sender_id: ENV['DEFAULT_SENDER_ID'])
            contacts = (contacts + 1)
         end
      end
      @broadcast.update_attributes(contacts: contacts, status: "SUCCESS")
   end
end
