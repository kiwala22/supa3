class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def index
    ((Date.today - 30)..Date.today).each do |date|
      @date = date
      @draw = Draw.where("draw_time > ? AND draw_time <= ?" date.to_time, Time.now)
      ref = @draw.first
      #still to implement ticket changes
      @tickets = @draw.sum(:ticket_count)
      @users = @draw.sum(:users)
    end
  end
end
