class JackpotController < ApplicationController

  def index
    authorize! :index, :revenue, :message => "You are not allowed to view this page..."
    #consider only tickets for the last 7 days
    @q = Ticket.where('created_at >= ?', (Time.now - 7.days)).ransack(params[:q])
    @tickets = @q.result(distinct: true).order("RANDOM()").first(20).page params[:page]
    @search_params = params[:q]
  end
end
