class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def index
    @reference = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:ticket_count)
    ((Date.today - 30)..Date.today).each do |date|
      @date = date
      @draw = Draw.where("draw_time > ? AND draw_time <= ?", date.to_time, Time.now)
      @tickets = @draw.sum(:ticket_count)
      @users = @draw.sum(:users)
      @ticket_change = @tickets - @reference
    end
  end
end
