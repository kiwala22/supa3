class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  def index
    @series = []
    # reference = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:ticket_count)
    # payout_ref = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:payout)
    # revenue_ref = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:revenue)
    # rtp_ref = payout_ref / revenue_ref

    time_now = Time.now
    (0..30).each do |f|
      #data in consideration
      date = Date.today - f.days

      #date and time_reference
      time_ref = time_now - f.days
      #tickets
      #pull all the tickets at once
      tickets = Ticket.where("created_at <= ? AND created_at >= ?", time_ref, time_ref.beginning_of_day )
      ticket_count = tickets.count
      mtn_count = tickets.where(network: "MTN Uganda").count
      airtel_count = tickets.where(network: "Airtel Uganda").count
      ticket_revenue = tickets.sum(:amount)
      ticket_payout = tickets.sum(:win_amount)
      gross_revenue = (ticket_revenue - ticket_payout)
      rtp = (ticket_payout / ticket_revenue)* 100
      users = tickets.select('DISTINCT gamer_id').count()
      new_users = Gamer.where("created_at <= ? AND created_at >= ?", time_ref, time_ref.beginning_of_day).count

      # draws = Draw.where("draw_time > ? AND draw_time <= ?", date.beginning_of_day, date_now)
      # ticket_sum = draws.sum(:ticket_count)
      # payout = draws.sum(:payout)
      # revenue = draws.sum(:revenue)
      # rtp = (payout / revenue)* 100
      # users = draws.sum(:users)
      # ticket_change = ticket_sum - reference
      obj = {date: date, tickets: ticket_count, mtn_count: mtn_count, airtel_count: airtel_count, 
            ticket_revenue:ticket_revenue, ticket_payout: ticket_payout, gross_revenue: gross_revenue , rtp: rtp ,users: users, new_users: new_users}
      @series.push(obj)
    end
  end
end
