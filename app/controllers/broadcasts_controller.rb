class BroadcastsController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   def index
      @broadcasts = current_user.broadcasts.order("created_at DESC").page params[:page]
      respond_to do |format|
        format.html
        format.csv  { render csv: @broadcasts.to_csv, filename: "Broadcasts #{Date.today}" }
      end
   end

   def new
      @broadcast = Broadcast.new()
   end

   def create
      @broadcast = Broadcast.new(message: broadcast_params['message'], lower_perc: broadcast_params['lower_perc'], upper_perc: broadcast_params['upper_perc'] ,status: "PENDING", user_id: current_user.id)
      if @broadcast.save
         #trigger worker & return route to reset_index
         BroadcastWorker.perform_async(@broadcast.id)
         redirect_to action: "index", notice: 'Broadcast Successful. Processing.....'
      else
         #show to error notice and show index
         render action: "new"
         flash[:error] = "Broadcast Failed"
      end
   end

   private
   def broadcast_params
      params.require(:broadcast).permit(:message, :lower_perc, :upper_perc)
   end
end
