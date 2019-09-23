class TicketAnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    labels = []
    #tickets = []
    mtn_stats = []
    airtel_stats = []
    undef_stats = []

    ((Date.today - 21) .. Date.today).each do |f|
        labels.push(f.to_s)
        ticket_stats = Ticket.where("created_at <= ? AND created_at >= ?", f.end_of_day, f.beginning_of_day).group(:network).count
        if ticket_stats.key?("MTN Uganda")
          mtn_stats.push(ticket_stats["MTN Uganda"])
        else
          mtn_stats.push(0)
        end

        if ticket_stats.key?("Airtel Uganda")
          airtel_stats.push(ticket_stats["Airtel Uganda"])
        else
          airtel_stats.push(0)
        end

        if ticket_stats.key?("UNDEFINED")
          undef_stats.push(ticket_stats["UNDEFINED"])
        else
          undef_stats.push(0)
        end
    end
    gon.labels = labels
    gon.mtn = mtn_stats
    gon.airtel = airtel_stats
    gon.undef = undef_stats
  end
end
