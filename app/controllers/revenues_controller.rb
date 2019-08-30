class RevenuesController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_user

    def index
        labels = []
        revenues = []
        payouts = []

        ((Date.today - 21) .. Date.today).each do |f|
            labels.push(f.to_s)
            revenue = Draw.where("created_at <= ? AND created_at >= ?", f.end_of_day, f.beginning_of_day).sum(:revenue)
            revenues.push(revenue.to_i)
            payout  = Draw.where("created_at <= ? AND created_at >= ?", f.end_of_day, f.beginning_of_day).sum(:payout)
            payouts.push(payout.to_i)
        end
        gon.labels = labels
        gon.revenues = revenues
        gon.payouts = payouts
    end

    private
    def verify_user
      if current_user.admin != true
        raise CanCan::AccessDenied
      end
    end
end
