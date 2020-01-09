class JackpotController < ApplicationController
  before_action :authenticate_user!
  #assign tickets object to global variable
  $tickets
  def index
    authorize! :index, :jackpot, :message => "You are not allowed to view this page..."
  end

  def draws
    start_date = DateTime.strptime(params[:start_date],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
    end_date = DateTime.strptime(params[:end_date],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
    gamers = (params[:gamers]).to_i
    $tickets = Ticket.where("created_at >= ? and created_at <= ?", start_date, end_date).order("RANDOM()").limit(gamers)
  end

  def download_tickets
    #pass whole tickets object for download
    respond_to do |format|
      format.html
      format.csv { send_data $tickets.to_csv, filename: "JackPot-tickets #{Date.today}.csv" }
    end
  end
end
