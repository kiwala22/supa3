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

  end
end
