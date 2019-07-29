class TicketsController < ApplicationController
   before_action :authenticate_user!, except: [:create]
   skip_before_action :verify_authenticity_token
   load_and_authorize_resource

   def index
      @q = Ticket.all.ransack(params[:q])
      @tickets = @q.result(distinct: true).order("created_at DESC").page params[:page]
      @search_params = params[:q]
   end

   def new
   end

   def create
      #pick api data and respond, push the data to library through a worker
      if params[:phone_number].present? && params[:data].present? && params[:amount].present?
         phone_number = params[:phone_number]
         data = params[:data]
         amount = params[:amount]
         TicketWorker.perform_async(phone_number, data, amount)
         respond_to do |format|
            format.json { render json: {status: "Success"}, status: 200 }
            format.xml { render xml: {status: "Success", :xml => "<?xml version='1.0' encoding='utf-8'?>"}, status: 200 }
         end
      else
         respond_to do |format|
            format.json { render json: {status: "Failed"}, status: 400 }
            format.xml { render xml: {status: "Failed", :xml => "<?xml version='1.0' encoding='utf-8'?>"}, status: 400 }
         end
      end
   end

   def import

   end
   private
   def sent_sms_params
       params.permit(:search_params)
   end
end
