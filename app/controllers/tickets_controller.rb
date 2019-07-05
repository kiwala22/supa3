class TicketsController < ApplicationController
   before_action :authenticate_user!, except: [:create]
   skip_before_action :verify_authenticity_token
   load_and_authorize_resource

   def index
      @q = Ticket.all.ransack(params[:q])
      @tickets = @q.result(distinct: true).order("created_at DESC").page params[:page]

   end

   def new
   end

   def create
      #pick api data and respond, push the data to library through a worker
      if params[:phone_number].present? & params[:data].present? & params[:amount].present?
         phone_number = params[:phone_number]
         data = params[:data]
         amount = params[:amount]
         TicketWorker.perform_async(phone_number: phone_number, data: data, amount: amount)
         respond_to do |format|
            format.html {render body: nil}
            format.json { render status: 200}
            format.xml {render status: 200, :xml => "<?xml version='1.0' encoding='utf-8'?>"}
         end
      else
         respond_to do |format|
            format.html {render body: nil}
            format.json { render status: 400}
            format.xml {render status: 400, :xml => "<?xml version='1.0' encoding='utf-8'?><"}
         end
      end

   end

   def import

   end
end
