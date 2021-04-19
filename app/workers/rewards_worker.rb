class RewardsWorker

  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_throttle({
      :concurrency => { :limit => 10 }
    })

  sidekiq_options queue: "low"
  sidekiq_options retry: false

  def perform(gamer_id, target)
    gamer = Gamer.find(gamer_id)

    ##Find amount the past 7 days
    amount_in_week = gamer.tickets.where("created_at >= ?", (Time.now.beginning_of_week)).sum(:amount).to_i

    #Run reward functionality here
    win = (amount_in_week * 0.20)

    ##Call the reward disbursement
    RewardDisbursementWorker.perform_async(gamer_id, win)

    ##Process the sms
    if gamer.first_name != nil
      message_content = gamer.first_name + ", CONGRATS you have been rewarded with #{win} for hitting your weekly target of #{target} tickets. Thank you for playing #{ENV['GAME']}"
    else
      message_content = "Hi, CONGRATS you have been rewarded with #{win} for hitting your weekly target of #{target} tickets. Thank you for playing #{ENV['GAME']}"
    end
    SendSMS.process_sms_now(receiver: gamer.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
  end

end
