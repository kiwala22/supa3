class RemindersWorker

  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_throttle({
      :concurrency => { :limit => 50 }
    })

  sidekiq_options queue: "low"
  sidekiq_options retry: 3
  require "send_sms"

  def perform(target, gamer_id)
    gamer = Gamer.find(gamer_id)

    ##Find count of tickets for the gamer in the past 7 days
    tickets_count_in_week = gamer.tickets.select(:id).where("created_at >= ?", (Time.now.beginning_of_week)).count()

    ##Check if the target has not been hit yet,
    ##If not, process the reminder sms
    if target.to_i > tickets_count_in_week
      if gamer.first_name != nil
        message_content = gamer.first_name + ", Reminder to hit your target of #{target} this week to win a bonus of 20% your total ticket spend, current tickets total this week is still at #{tickets_count_in_week}. Thank you for playing #{ENV['GAME']}"
      else
        message_content = "Hi, Reminder to hit your target of #{target} this week to win a bonus of 20% your total ticket spend, current tickets total this week is still at #{tickets_count_in_week}. Thank you for playing #{ENV['GAME']}"
      end
      SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])

    end

  end

end
