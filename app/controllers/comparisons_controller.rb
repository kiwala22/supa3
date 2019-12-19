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
      draws = Draw.where("draw_time >= ? AND draw_time <= ?", time_ref.beginning_of_day, time_ref)
      ticket_count = draws.sum(:ticket_count)
      mtn_count = draws.sum(:mtn_tickets)
      airtel_count = draws.sum(:airtel_tickets)
      ticket_revenue = draws.sum(:revenue)
      ticket_payout = draws.sum(:payout)
      gross_revenue = (ticket_revenue - ticket_payout)
      rtp = (ticket_payout / ticket_revenue)* 100
      users = draws.sum(:users)
      new_users = draws.sum(:new_users)


      obj = {date: date, tickets: ticket_count, mtn_count: mtn_count, airtel_count: airtel_count, 
            ticket_revenue:ticket_revenue, ticket_payout: ticket_payout, gross_revenue: gross_revenue , rtp: rtp ,users: users, new_users: new_users}
      @series.push(obj)
    end
  end
end
