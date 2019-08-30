class TicketAnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    labels = []
    tickets = []

    ((Date.today - 21) .. Date.today).each do |f|
        labels.push(f.to_s)
        ticket = Ticket.where("created_at <= ? AND created_at >= ?", f.end_of_day, f.beginning_of_day).count
        tickets.push(ticket)
    end
    gon.labels = labels
    gon.tickets = tickets
  end
end
