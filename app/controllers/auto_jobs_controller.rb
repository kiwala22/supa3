class AutoJobsController < ApplicationController
    before_action :authenticate_user!, except: [:process_broadcasts, :run_predictions, :update_segments, :run_draws]
    skip_before_action :verify_authenticity_token

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
end
