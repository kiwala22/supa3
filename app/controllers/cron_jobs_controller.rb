class CronJobsController < ApplicationController
    before_action :authenticate_user!, except: [:process_broadcasts, :run_predictions, :update_segments, :run_draws]
    skip_before_action :verify_authenticity_token
    load_and_authorize_resource

    def process_broadcasts
        Broadcast.process_broadcasts
        render body: nil
    end

    def run_predictions
        Gamer.run_predictions
        render body: nil
    end

    def update_segments
        Segment.update_segments
        render body: nil
    end

    def run_draws
        Ticket.run_draws
        render body: nil
    end
end
