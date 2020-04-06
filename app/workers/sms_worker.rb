class SmsWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options queue: "default"
  sidekiq_options retry: false

  require 'send_sms'

  sidekiq_throttle({
     # Allow maximum 20 concurrent jobs of this class at a time.
     :concurrency => { :limit => 20 }
  })

  def perform(phone_number, message)
    SendSMS.process_sms_now(transaction: false, receiver: phone_number, content: message, sender_id: ENV['DEFAULT_SENDER_ID'])
  end
end
