class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def index
    @series = []
    reference = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:ticket_count)
    payout_ref = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:payout)
    revenue_ref = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:revenue)
    rtp_ref = payout_ref / revenue_ref
    time_reference = Time.now
    (0..30).each do |f|
      date = Date.today - f.days
      date_now = time_reference - f.days
      draws = Draw.where("draw_time > ? AND draw_time <= ?", date.beginning_of_day, date_now)
      ticket_sum = draws.sum(:ticket_count)
      payout = draws.sum(:payout)
      revenue = draws.sum(:revenue)
      rtp = payout / revenue
      users = draws.sum(:users)
      ticket_change = ticket_sum - reference
      obj = {date: date, tickets: ticket_sum, users: users, rtp_change: (rtp - rtp_ref), ticket_change: ticket_change}
      @series.push(obj)
    end
  end
end
