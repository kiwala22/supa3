class JackpotController < ApplicationController
   before_action :authenticate_user!
   # authorize_resource :class => false
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

   def supa5_draws
      render layout: false
   end

   def big_five_winners
      start_date = DateTime.strptime(params[:start_date],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
      end_date = DateTime.strptime(params[:end_date],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
      gamers = (params[:gamers]).to_i
      @tickets = Ticket.where("created_at >= ? and created_at <= ? AND game = ?", start_date, end_date, "Supa5").order("RANDOM()").limit(gamers)
      @start = params[:start_date]
      @end  = params[:end_date]
      #persist the winners
      @tickets.each do |winner|
        Jackpot.create(first_name: winner.first_name, last_name: winner.last_name, phone_number: winner.phone_number, ticket_id: winner.id, ticket_reference: winner.reference, game: "Supa5")
      end
      respond_to do |format|
         format.js
       end
   end

   def supa_five_jackpot
      start_date = DateTime.strptime(params[:start_date],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
      end_date = DateTime.strptime(params[:end_date],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
      winning_number = params[:first] + params[:second] + params[:third] + params[:fourth] + params[:fifth]
      winning_number = winning_number.gsub(/\s+/, '')
      @winners = Ticket.where("created_at >= ? and created_at <= ? AND game = ? AND data = ?", start_date, end_date, "Supa5", winning_number).order("RANDOM()").limit(1)
      @winners.each do |winner|
        Jackpot.create(first_name: winner.first_name, last_name: winner.last_name, phone_number: winner.phone_number, ticket_id: winner.id, ticket_reference: winner.reference, game: "Supa5", jackpot: true)
      end
      respond_to do |format|
         format.js
       end

   end

   def download_tickets
      #pass whole tickets object for download
      respond_to do |format|
         format.html
         format.csv { send_data $tickets.to_csv, filename: "JackPot-tickets #{Date.today}.csv" }
      end
   end
end
