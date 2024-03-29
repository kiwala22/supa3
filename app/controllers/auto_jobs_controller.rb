class AutoJobsController < ApplicationController
   before_action :authenticate_user!, except: [:promotional_sms, :quick_script, :process_broadcasts, :run_predictions, :update_segments, :run_draws, :generate_daily_reports, :low_credit_notification, :extract_ggr_figures, :send_ggr_figures_mail, :run_target_reminders, :run_ai_predictions, :update_user_info]
   skip_before_action :verify_authenticity_token
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


   # Update prediction rewarded column at start of week
   def quick_script
     AiPredictionScriptWorker.perform_async
     render body: nil
   end

   # Run promotional sms for gamers about their weekly targets
   def promotional_sms
     PromotionalSmsWorker.perform_async
     render body: nil
   end

   def run_predictions
    PredictionWorker.perform_async
    render body: nil
   end


   # Run AI predictions from AI server
   def run_ai_predictions
     AiPredictionWorker.perform_async
     render body: nil
   end

   # Run reminders for gamers greater than 0 targets
   def run_target_reminders
     Prediction.reminders
     render body: nil
   end

   def update_segments
      #Segment.update_segments
      Supa3Segment.update_segments
      Supa5Segment.update_segments
      render body: nil
   end

   def extract_ggr_figures
     Collection.send_weekly_report
     Disbursement.send_weekly_report
     render body: nil
   end

   def send_ggr_figures_mail
     NotifierMailer.figures_email.deliver_now
     render body: nil
   end

   def run_draws
      # Pick start and stop time
      start_time = Time.now.localtime.beginning_of_minute - 10.minutes
      end_time = Time.now.localtime

      DrawWorker.perform_async(start_time, end_time)
      Supa5DrawWorker.perform_async(start_time, end_time)
      render body: nil
   end

   # def create_gamers
   #    GamerWorker.perform_async
   #    render body: nil
   # end

   # def update_tickets
   #    UpdateTicketsWorker.perform_async
   #    render body: nil
   # end

   # def update_results
   #    UpdateResultsWorker.perform_async
   #    render body: nil
   # end

   def update_user_info
      Gamer.where("phone_number ~* ?", "^(25674)").find_each(batch_size: 10) do |gamer|
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
