class BroadcastsController < ApplicationController
   before_action :authenticate_user!, except: [:process_broadcasts]
   load_and_authorize_resource

   def index
      @broadcasts = Broadcast.all.order("created_at DESC").page params[:page]

   end

   def new
      @broadcast = Broadcast.new()
   end

   def create
      p broadcast_params[:execution_time]
      @broadcast = Broadcast.new(
         message: broadcast_params['message'],
         execution_time: DateTime.strptime(broadcast_params[:execution_time],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S"),
         segment: broadcast_params['segment'],
         status: "PENDING",
         user_id: current_user.id)
      if @broadcast.save
         #trigger worker & return route to reset_index
         BroadcastWorker.perform_async(@broadcast.id)
         flash[:notice] = 'Broadcast Successful. Processing.....'
         redirect_to action: "index"
      else
         #show to error notice and show index
         flash.now[:alert] = @broadcast.errors.first
         render action: "new"
      end
   end
   def edit
   end

   def update
      if @broadcast.update(broadcast_params)
         redirect_to  broadcasts_path, notice: 'Broadcast was successfully updated.'
      else
         render :edit
      end
   end

   def destroy
      @broadcast.destroy
      flash[:notice] = 'Broadcast was successfully deleted.'
      redirect_to action: "index"

   end

   def process_broadcasts
      Broadcast.process_broadcasts
      render body: nil
   end

   # def process_broadcasts
   #    #find the broadcasts with a status of "PENDING"
   #    jobs = Broadcast.where('status = ? AND execution_time <= ?', "PENDING", Time.now)
   #    if !jobs.empty?
   #       jobs.each do |job|
   #          #first update the status of the message and then push it to the worker
   #          job.update_attribute(:status, "PROCESSING")
   #          BroadcastWorker.perform_async(job.id)
   #       end
   #    end
   #    render nothing: true, status: 200
   # end

   def set_broadcast
      @broadcast = Broadcast.find(params[:id])
   end


   private

   def broadcast_params
      params.require(:broadcast).permit(:message, :execution_time, :segment, :status)
   end
end
