class JackpotController < ApplicationController

  def index
    authorize! :index, :revenue, :message => "You are not allowed to view this page..."
  end

  def draws
    date = DateTime.strptime(params[:start_date],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
    gamers = (params[:gamers]).to_i
    @results = Ticket.where("created_at >= ?", date)
    @tickets = @results.sample(gamers)

    respond_to do |format|
      format.html
      format.csv {send_data @tickets.to_csv, filename: "jackpot_tickets-#{Date.today}.csv" }
    end
  end
end
