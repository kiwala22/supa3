class RewardsWorker

  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_throttle({
      :concurrency => { :limit => 50 }
    })

  sidekiq_options queue: "low"
  sidekiq_options retry: 3

  def perform(target, gamer_id)
    gamer = Gamer.find(gamer_id)

    ##Find count of tickets for the gamer in the past 7 days
    tickets = gamer.tickets.where("created_at >= ? AND  created_at <= ?", (Date.today.beginning_of_day - 7.days), (Date.today.end_of_day))
    tickets_count_7_days = tickets.count()
    amount_7_days = tickets.sum(:amount)

    ##Check if the target has  been hit yet,
    ##If yet, process the reward
    if tickets_count_7_days >= target.to_i
      #Run reward functionality here
      win = (amount_7_days * 0.20)
      RewardDisbursementWorker.perform_async(gamer_id, win)
      if gamer.first_name != nil
        message_content = gamer.first_name + ", You have been rewarded with #{win} for hitting your weekly target of #{target} tickets. Thank you for playing #{ENV['GAME']}"
      else
        message_content = "Hi, You have been rewarded with #{win} for hitting your weekly target of #{target} tickets. Thank you for playing #{ENV['GAME']}"
      end
      SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
    end
  end

end
