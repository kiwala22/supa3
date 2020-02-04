class DisbursementsController < ApplicationController
  before_action :authenticate_user!

  require 'mobile_money/mtn_ecw'
  require 'mobile_money/airtel_uganda'

  def index
    authorize! :index, :disbursement, :message => "You are not allowed to view this page..."
    @q = Disbursement.all.ransack(params[:q])
    @disbursements = @q.result(distinct: true).order("created_at DESC").page params[:page]
    @search_params = params[:q]

    mtn_balance = MobileMoney::MtnEcw.get_payout_balance
    if mtn_balance == false || mtn_balance == nil
      @payouts = "N/A"
    else
      @payouts = mtn_balance[:amount]
    end
    @airtel_payouts = 0
  end
end
