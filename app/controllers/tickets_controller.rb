class TicketsController < ApplicationController
   before_action :authenticate_user!
   load_and_authorize_resource

   def index
      @q = Ticket.all.ransack(params[:q])
      @tickets = @q.result(distinct: true).order("created_at DESC").page params[:page]

   end

   def new


   end

   def create
      #pick api data and respond, push the data to library through a worker
      if tickets_params[:phone_number].present? & tickets_params[:data].present? & tickets_params[:amount].present?
         phone_number = tickets_params[:phone_number]
         data = tickets_params[:data]
         amount = tickets_params[:amount]
         TicketWorker.perform_async(phone_number: phone_number, data: data, amount: amount)
         respond_to do |format|
            format.json { render status: 200}
            format.xml {render status: 200, :xml => "<?xml version='1.0' encoding='utf-8'?>"}
         end
      else
         respond_to do |format|
            format.json { render status: 400}
            format.xml {render status: 400, :xml => "<?xml version='1.0' encoding='utf-8'?><"}
         end
      end

   end

   def import

   end

   private

   def tickets_params
      params.permit(:phone_number, :data, :amount)
   end
end
