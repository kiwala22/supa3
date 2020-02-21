class TicketsController < ApplicationController
   before_action :authenticate_user!
   skip_before_action :verify_authenticity_token
   load_and_authorize_resource

   def index
      #consider only the last 10000 tickets for quick results
      @q = Ticket.limit(1000).ransack(params[:q])
      @tickets = @q.result.order("created_at DESC").page params[:page]
      @search_params = params[:q]
   end

   def update
     #method to recall disbursement that did not initially process
     gamer_id = params[:gamer]
     ticket_id = params[:id]
     win_amount = (params[:amount]).to_i
     #after receiving the parameters, we recall the disbursement worker to create new disbursements
     if win_amount >= 200000
        win_amount = (win_amount * 0.85).to_i
     end
     DisbursementWorker.perform_async(gamer_id, win_amount, ticket_id)
     respond_to do |format|
       flash.now[:notice] = "Ticket has been paid."
       format.html
       format.json
       format.js   { render :layout => false }
     end
   end

   # def new
   # end
   #
   # def create
   #    #pick api data and respond, push the data to library through a worker
   #    if params[:phone_number].present? && params[:data].present? && params[:amount].present?
   #       phone_number = params[:phone_number]
   #       data = params[:data]
   #       amount = params[:amount]
   #       TicketWorker.perform_async(phone_number, data, amount)
   #       respond_to do |format|
   #          format.json { render json: {status: "Success"}, status: 200 }
   #          format.xml { render xml: {status: "Success", :xml => "<?xml version='1.0' encoding='utf-8'?>"}, status: 200 }
   #       end
   #    else
   #       respond_to do |format|
   #          format.json { render json: {status: "Failed"}, status: 400 }
   #          format.xml { render xml: {status: "Failed", :xml => "<?xml version='1.0' encoding='utf-8'?>"}, status: 400 }
   #       end
   #    end
   # end
   #
   # def import
   #
   # end
   private
   def ticket_params
       params.permit(:search_params, :gamer, :amount)
   end
end
