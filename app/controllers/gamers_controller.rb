class GamersController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   def index
      @q = Gamer.all.ransack(params[:q])
      @gamers = @q.result.order("created_at DESC").page params[:page]
      @search_params = params[:q]
   end

   private
   def sent_sms_params
       params.permit(:search_params)
   end
end
