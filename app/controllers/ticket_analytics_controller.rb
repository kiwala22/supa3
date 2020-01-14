class TicketAnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    labels = []
    mtn_stats = []
    airtel_stats = []
    undef_stats = []

    ((Date.today - 21) .. Date.today).each do |f|
        labels.push(f.to_s)
        draws = Draw.where("draw_time >= ? AND draw_time <= ?", f.beginning_of_day, f.end_of_day)
        mtn_ticket_count = draws.sum(:mtn_tickets)
        mtn_stats.push(mtn_ticket_count)
        airtel_ticket_count = draws.sum(:airtel_tickets)
        airtel_stats.push(airtel_ticket_count)
        undefined_ticket_count = draws.sum(:undefined_tickets)
        undef_stats.push(undefined_ticket_count)
    end
    gon.labels = labels
    gon.mtn = mtn_stats
    gon.airtel = airtel_stats
    gon.undef = undef_stats
  end
end
