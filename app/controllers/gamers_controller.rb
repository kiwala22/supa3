class GamersController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   def index
      if params[:q]
         params[:q][:combinator] = 'or'
         params[:q][:groupings] = []
         split_codes = params[:q][:phone_number_start].split(' ')
         params[:q][:phone_number_start].clear
         split_codes.each_with_index do |word, index|
           params[:q][:groupings][index] = {phone_number_start: word}
         end
     end
      @q = Gamer.ransack(params[:q])
      @gamers = @q.result.order("created_at DESC")
      @search_params = params[:q]
      respond_to do |format|
         format.html { @gamers = @gamers.page params[:page] }
         format.csv { send_data @gamers.to_csv, filename: "Gamers-first.csv" }
      end
   end

   private
   def sent_sms_params
       params.permit(:search_params)
   end
end
