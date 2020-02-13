class CollectionsController < ApplicationController
  before_action :authenticate_user!

  require 'mobile_money/mtn_ecw'
  require 'mobile_money/airtel_uganda'

  def index
    authorize! :index, :collection, :message => "You are not allowed to view this page..."
    @q = Collection.all.ransack(params[:q])
    @collections = @q.result(distinct: true).order("created_at DESC").page params[:page]
    @search_params = params[:q]

    mtn_balance = MobileMoney::MtnEcw.get_collection_balance
    if mtn_balance == false || mtn_balance == nil
      @mtn_collections = "N/A"
    else
      @mtn_collections = mtn_balance[:amount]
    end
    airtel_balance = MobileMoney::AirtelUganda.get_collection_balance
    if airtel_balance == false || airtel_balance == nil
      @airtel_collections = "N/A"
    else
      @airtel_collections = airtel_balance[:amount]
    end
  end
end
