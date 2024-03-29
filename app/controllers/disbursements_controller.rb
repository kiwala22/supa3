class DisbursementsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  require 'mobile_money/mtn_ecw'
  require 'mobile_money/airtel_uganda'

  def index
    @q = Disbursement.limit(1000).ransack(params[:q])
    @disbursements = @q.result.order("created_at DESC")
    @search_params = params[:q]

    mtn_balance = MobileMoney::MtnEcw.get_payout_balance
    if mtn_balance == false || mtn_balance == nil || mtn_balance == true
      @mtn_payouts = "N/A"
    else
      @mtn_payouts = mtn_balance[:amount]
    end
    airtel_balance = MobileMoney::AirtelUganda.get_payout_balance
    if airtel_balance == false || airtel_balance == nil || airtel_balance == true
      @airtel_payouts = "N/A"
    else
      @airtel_payouts = airtel_balance[:amount]
    end
    respond_to do |format|
      format.html { @disbursements = @disbursements.page params[:page] }
      format.csv { send_data @disbursements.to_csv, filename: "Disbursements-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv" }
    end
  end
end
