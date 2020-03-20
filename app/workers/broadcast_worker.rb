class BroadcastWorker
   include Sidekiq::Worker
   include Sidekiq::Throttled::Worker

   sidekiq_throttle({
       # Allow maximum 10 concurrent jobs of this class at a time.
       :concurrency => { :limit => 10 },
 	    # Allow maximum 40 jobs being processed within one second window.
 	    :threshold => { :limit => 40, :period => 1.second }
     })


   sidekiq_options queue: "default"
   sidekiq_options retry: false

   require 'send_sms'

   def perform(phone_number, message)
      SendSMS.process_sms_now(transaction: false, receiver: phone_number, content: message, sender_id: ENV['DEFAULT_SENDER_ID'])
   end
end
