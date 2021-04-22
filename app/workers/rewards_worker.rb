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
    RewardDisbursementWorker.perform_async(gamer_id, win, target)

  end

end
