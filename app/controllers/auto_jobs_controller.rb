class AutoJobsController < ApplicationController
   before_action :authenticate_user!, except: [:process_broadcasts, :run_predictions, :update_segments, :run_draws, :create_gamers, :update_tickets, :update_results, :update_user_info, :generate_daily_reports, :low_credit_notification]
   skip_before_action :verify_authenticity_token

   require 'mobile_money/mtn_ecw'
   require 'mobile_money/airtel_uganda'
   require 'send_sms'

   def process_broadcasts
      jobs = Broadcast.where('status = ? AND execution_time <= ?', "PENDING", Time.now)
      if !jobs.empty?
         jobs.each do |job|
            #first update the status of the message and then push it to the worker
            job.update_attribute(:status, "PROCESSING")
            BroadcastWorker.perform_async(job.id)
         end
      end
      render body: nil
   end

   def run_predictions
      Gamer.find_each(batch_size: 1000) do |user|
         SegmentPredictionWorker.perform_async(user.phone_number)
      end
      render body: nil
   end

   def update_segments
      segment_summary = Gamer.order('segment ASC').group(:segment).count().except!(nil)
      @segment = Segment.new(segment_summary.transform_keys!(&:downcase))
      if @segment.save
         return true
      else
         return false
      end
      render body: nil
   end

   def run_draws
      # Pick start and stop time
      start_time = Time.now.localtime.beginning_of_minute - 10.minutes
      end_time = Time.now.localtime

      DrawWorker.perform_async(start_time, end_time)
      render body: nil
   end

   def create_gamers
      GamerWorker.perform_async
      render body: nil
   end

   def update_tickets
      UpdateTicketsWorker.perform_async
      render body: nil
   end

   def update_results
      UpdateResultsWorker.perform_async
      render body: nil
   end

   def update_user_info
      UpdateGamerInfoWorker.perform_async
      render body: nil
   end

   def generate_daily_reports
      Collection.send_daily_report
      Disbursement.send_daily_report
      render body: nil
   end

   def low_credit_notification
      #check balances on both payout accounts and check if any of them is below threshold level
      threshold = 200000
      message_content = "Hello BetCity, your payout balances are currently below threshold level, please top up. Thank you."
      users = ["256786481312", "256776582036", "256785724466", "256704164444", "256771870788"]
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
      render body: nil
   end
end
