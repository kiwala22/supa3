class BroadcastWorker
   include Sidekiq::Worker
   sidekiq_options queue: "default"
   sidekiq_options retry: false

   #include SendSMS
   require 'send_sms'

   def perform(broadcast_id)
      @broadcast = Broadcast.find(broadcast_id)
      @gamers = Gamer.where(segment: @broadcast.segment.split(","))
      contacts = 0
      @gamers.each do |gamer|
         #Creating a broadcast worker so as to separate game traffic from Bulk traffic
         #Send Marketing Message from external reusable library
         if SendSMS.process_sms_now(receiver: gamer.phone_number, content: @broadcast.message, sender_id: ENV['DEFAULT_SENDER_ID'])
            contacts = (contacts + 1)
         end
      end
      @broadcast.update_attributes(contacts: contacts, status: "SUCCESS")
   end
end
