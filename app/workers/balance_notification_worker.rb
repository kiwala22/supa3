class BalanceNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  sidekiq_options retry: false

  require 'send_sms'
  require 'mobile_money/mtn_ecw'
  require 'mobile_money/airtel_uganda'

  def perform
    threshold = 200000
    message_content = "Hello BetCity, your payout balances are currently below threshold level, please top up. Thank you."
    users = ["256785724466"]
    mtn_balance = MobileMoney::MtnEcw.get_payout_balance
    airtel_balance = MobileMoney::AirtelUganda.get_payout_balance
    if (mtn_balance != nil || mtn_balance != false || mtn_balance != true ) && (airtel_balance != nil || airtel_balance != false || airtel_balance != true)
      @mtn_balance = mtn_balance[:amount]
      @airtel_balance = airtel_balance[:amount]
      if @mtn_balance.to_i < threshold || @airtel_balance.gsub(/,/, '').to_i < threshold
        users.each do |user|
          #send a notification message to each user
          SendSMS.process_sms_now(transaction: false, receiver: user, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])
        end
      end
    end
  end
end
