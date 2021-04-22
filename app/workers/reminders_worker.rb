class RemindersWorker

  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_throttle({
      :concurrency => { :limit => 50 }
    })

  sidekiq_options queue: "low"
  require "send_sms"

  def perform(target, gamer_id)
    gamer = Gamer.find(gamer_id)

    message = ", Reminder to hit your target of #{target} tickets this week to win a bonus of 20% amount played. You have not yet played any tickets this week. Thank you for playing #{ENV['GAME']}"

    if gamer.first_name != nil
      message_content = gamer.first_name + message
    else
      message_content = "Hi" + message
    end
    SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])

  end

end
