class BroadcastWorker
   include Sidekiq::Worker
   sidekiq_options queue: "default"
   sidekiq_options retry: false

   require "send_sms"

   def perform(broadcast_id)
      @broadcast = Broadcast.find(broadcast_id)
      @gamers = Gamer.where(segment: @broadcast.segment )
      contacts = 0
      @gamers.each do |gamer|
         #Send Marketing Message from external reusable library
         if SendSMS.process_sms_now(receiver: gamer.phone_number, content: @broadcast.message, sender_id: ENV['DEFAULT_SENDER_ID'])
            contacts = (contacts + 1)
         end
      end
      @broadcast.update_attributes(contacts: contacts, status: "SUCCESS")
   end
end
