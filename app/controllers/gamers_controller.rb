class GamersController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   def index
      @q = Gamer.ransack(params[:q])
      @gamers = @q.result.order("created_at DESC")
      @search_params = params[:q]
      respond_to do |format|
         format.html { @gamers = @gamers.page params[:page] }
         format.csv { send_data @gamers.to_csv, filename: "Gamers-#{Time.now.to_datetime}.csv" }
      end
   end

   private
   def sent_sms_params
       params.permit(:search_params)
   end
end
