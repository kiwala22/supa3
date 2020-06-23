class BroadcastsController < ApplicationController
   before_action :authenticate_user!, except: [:process_broadcasts]
   before_action :set_broadcast, only: [:destroy]
   load_and_authorize_resource

   def index
      @broadcasts = Broadcast.all.order("created_at DESC").page params[:page]

   end

   def new
      @broadcast = Broadcast.new()
   end

   def create
      if broadcast_params[:method] == "PredictedRevenue"
        @broadcast = Broadcast.new(
           message: broadcast_params['message'],
           execution_time: DateTime.strptime(broadcast_params[:execution_time],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S"),
           predicted_revenue_lower: broadcast_params['predicted_revenue_lower'],
           predicted_revenue_upper: broadcast_params['predicted_revenue_upper'],
           status: "PENDING",
           method:  broadcast_params['method'],
           user_id: current_user.id)
       end
       if broadcast_params[:method] == "Segments"
         @broadcast = Broadcast.new(
            message: broadcast_params['message'],
            execution_time: DateTime.strptime(broadcast_params[:execution_time],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S"),
            segment: broadcast_params['segment'].join(","),
            status: "PENDING",
            method:  broadcast_params['method'],
            user_id: current_user.id)
       end
      if @broadcast.save
         flash[:notice] = 'Broadcast Successful. Processing.....'
         redirect_to action: "index"
      else
         #show to error notice and show index
         flash.now[:alert] = @broadcast.errors
         render action: "new"
      end
   end

   def destroy
      @broadcast.destroy
      flash[:notice] = 'Broadcast was successfully deleted.'
      redirect_to action: "index"

   end

   def process_broadcasts
      jobs = Broadcast.where('status = ? AND execution_time <= ?', "PENDING", Time.now)
      if !jobs.empty?
         jobs.each do |job|
            #first update the status of the message and then push it to the worker
            job.update_attribute(:status, "PROCESSING")
            BroadcastWorker.perform_async(job.id)
         end
      end
      render nothing: true, status: 200
   end

   def set_broadcast
      @broadcast = Broadcast.find(params[:id])
   end


   private
   def broadcast_params
      params.require(:broadcast).permit(:message, :execution_time, :status, :predicted_revenue_lower,
        :predicted_revenue_upper, :method, :segment => [])
   end
end
