class BroadcastWorker
   include Sidekiq::Worker
   sidekiq_options queue: "default"
   sidekiq_options retry: false

   require 'send_sms'

   def perform(broadcast_id)
      @broadcast = Broadcast.find(broadcast_id)
      @gamers = Gamer.where(segment: @broadcast.segment.split(","))
      contacts = 0
      sender_id = "SUPA3"
      content = @broadcast.message
      @gamers.each do |gamer|
         #send the message to message library
         if SendSMS.process_sms_now(transaction: false, receiver: gamer.phone_number, content: @broadcast.message, sender_id: sender_id)
            contacts = (contacts + 1)
         end
      end
      @broadcast.update_attributes(contacts: contacts, status: "SUCCESS")
   end
end
