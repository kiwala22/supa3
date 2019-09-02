class BulkApiWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  sidekiq_options retry: false

  require 'send_sms'

  def perform(sender_id, phone_number, content)
    SendSMS.process_sms_now(receiver: phone_number, content: content, sender_id: sender_id)
  end
end
