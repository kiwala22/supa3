class AutoJobsController < ApplicationController
   before_action :authenticate_user!, except: [:process_broadcasts, :run_predictions, :update_segments, :run_draws, :create_gamers, :update_tickets, :update_results, :update_user_info, :generate_daily_reports, :low_credit_notification]
   skip_before_action :verify_authenticity_token
   require 'send_sms'

   def process_broadcasts
      BroadcastProcessWorker.perform_async
      render body: nil
   end

   def run_predictions
     Gamer.find_each(batch_size: 1000) do |gamer|
        SegmentPredictionWorker.perform_async(gamer.id)
     end
      render body: nil
   end

   def update_segments
      Segment.update_segments
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
      Gamer.find_each(batch_size: 1000) do |gamer|
        UpdateGamerInfoWorker.perform_async(gamer.id)
      end
      render body: nil
   end

   def generate_daily_reports
      Collection.send_daily_report
      Disbursement.send_daily_report
      render body: nil
   end

   def low_credit_notification
      #check balances on both payout accounts and check if any of them is below threshold level
      BalanceNotificationWorker.perform_async
      render body: nil
   end
end
