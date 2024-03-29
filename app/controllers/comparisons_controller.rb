class ComparisonsController < ApplicationController
  before_action :authenticate_user!

  authorize_resource :class => false
  def index
    @series = []
    # reference = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:ticket_count)
    # payout_ref = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:payout)
    # revenue_ref = Draw.where("draw_time > ? AND draw_time <= ?", Date.today.to_time, Time.now).sum(:revenue)
    # rtp_ref = payout_ref / revenue_ref

    time_now = Time.now
    @current_time = time_now
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
      new_users = draws.sum(:new_users)


      obj = {date: date, tickets: ticket_count, mtn_count: mtn_count, airtel_count: airtel_count,
            ticket_revenue: ticket_revenue, ticket_payout: ticket_payout, gross_revenue: gross_revenue , rtp: rtp ,new_users: new_users}
      @series.push(obj)

      #iterate all array objects, add change columns
      ref_obj = @series[0]
      @series.each do |f|

        f[:ticket_change] = f[:tickets] > 0 ? ((ref_obj[:tickets] - f[:tickets]) * 100 /  f[:tickets]) : 0
        #f[:ticket_change] = (ref_obj[:tickets] - f[:tickets]) /  f[:tickets]
        f[:mtn_change] = f[:mtn_count] > 0 ? ((ref_obj[:mtn_count] - f[:mtn_count]) * 100 /  f[:mtn_count]) : 0
        #f[:mtn_change] = (ref_obj[:mtn_count] - f[:mtn_count]) /  f[:mtn_count]
        f[:airtel_change] = f[:airtel_count] > 0 ? ((ref_obj[:airtel_count] - f[:airtel_count]) * 100 /  f[:airtel_count]) : 0
        #f[:airtel_change] = (ref_obj[:airtel_count] - f[:airtel_count]) /  f[:airtel_count]
        f[:revenue_change] = f[:ticket_revenue] > 0 ? ((ref_obj[:ticket_revenue] - f[:ticket_revenue]) * 100 /  f[:ticket_revenue]) : 0
        #f[:revenue_change] = (ref_obj[:ticket_revenue] - f[:ticket_revenue]) /  f[:ticket_revenue]
        f[:payout_change] = f[:ticket_payout] > 0 ? ((ref_obj[:ticket_payout] - f[:ticket_payout]) * 100 /  f[:ticket_payout]) : 0
        #f[:payout_change] = (ref_obj[:ticket_payout] - f[:ticket_payout]) /  f[:ticket_payout]
        f[:gross_change] = f[:gross_revenue] > 0 ? ((ref_obj[:gross_revenue] - f[:gross_revenue]) * 100 /  f[:gross_revenue]) : 0
        #f[:gross_change] = (ref_obj[:gross_revenue] - f[:gross_revenue]) /  f[:gross_revenue]
        f[:rtp_change] = f[:rtp] > 0 ? (( f[:rtp] - ref_obj[:rtp]) /  f[:rtp]) * 100 : 0
        #f[:rtp_change] = (ref_obj[:rtp] - f[:rtp]) /  f[:rtp]
        f[:new_users_change] = f[:new_users] > 0 ? ((ref_obj[:new_users] - f[:new_users]) * 100 /  f[:new_users]) : 0
        #f[:new_users_change] = (ref_obj[:new_users] - f[:new_users]) /  f[:new_users]

      end

    end
  end
end
