class GamersController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   def index
      @q = Gamer.all.ransack(params[:q])
      @gamers = @q.result(distinct: true).order("created_at DESC").page params[:page]
   end
end
