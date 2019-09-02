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
         #send the message to BulkApiWorker to process the messages
         phone_number = gamer.phone_number
         BulkApiWorker.perform_async(sender_id, phone_number, content)
         contacts = (contacts + 1)
      end
      @broadcast.update_attributes(contacts: contacts, status: "SUCCESS")
   end
end
