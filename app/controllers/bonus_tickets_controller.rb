class BonusTicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bonus_ticket, only: [:destroy]

  load_and_authorize_resource

  def index
    @bonus_tickets = BonusTicket.all.order("created_at DESC").page params[:page]
  end

  def new
    @bonus_ticket = BonusTicket.new()
  end

  def create
    @bonus_ticket = BonusTicket.new(
      segment: bonus_ticket_params[:segment],
      game: bonus_ticket_params[:game],
      expiry: DateTime.strptime(bonus_ticket_params[:expiry],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
      )
    if @bonus_ticket.save
      flash[:notice] = 'Bonus Ticket Promotion created successfully...'
      redirect_to action: "index"
   else
      #show to error notice and show index
      flash.now[:alert] = @bonus_ticket.errors
      render action: "new"
    end

  end

  def destroy
    @bonus_ticket.destroy
    flash[:notice] = "Bonus Ticket Promotion successfully deleted.."
    redirect_to action: "index"
  end

  private

  def set_bonus_ticket
    @bonus_ticket = BonusTicket.find(params[:id])
  end

  def bonus_ticket_params
    params.require(:bonus_ticket).permit(:segment, :game, :multiplier, :expiry)
  end
end
