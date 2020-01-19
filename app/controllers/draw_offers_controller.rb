class DrawOffersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_draw_offer, only: [:destroy]

  def index
    authorize! :index, :draw_offer, :message => "You are not allowed to view this page..."
    @draw_offers = DrawOffer.all.order("created_at DESC").page params[:page]
  end

  def new
    @draw_offer = DrawOffer.new()
  end

  def create
    @draw_offer = DrawOffer.new(
      multiplier_one: draw_offer_params[:multiplier_one],
      multiplier_two: draw_offer_params[:multiplier_two],
      multiplier_three: draw_offer_params[:multiplier_three],
      segment: draw_offer_params[:segment],
      expiry_time: DateTime.strptime(draw_offer_params[:expiry_time],'%d %B %Y - %I:%M %p').to_datetime.strftime("%Y-%m-%d %H:%M:%S")
    )
    if @draw_offer.save
      flash[:notice] = 'Promotion created successfully...'
      redirect_to action: "index"
   else
      #show to error notice and show index
      flash.now[:alert] = @draw_offer.errors
      render action: "new"
    end
  end

  def destroy
    @draw_offer.destroy
    flash[:notice] = "Promotion successfully deleted.."
    redirect_to action: "index"
  end

  private
  def set_draw_offer
    @draw_offer = DrawOffer.find(params[:id])
  end

  def draw_offer_params
    params.require(:draw_offer).permit(:multiplier_one, :multiplier_two, :multiplier_three, :expiry_time, :segment)
  end

end
