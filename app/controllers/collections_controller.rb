class CollectionsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  require 'mobile_money/mtn_ecw'
  require 'mobile_money/airtel_uganda'

  def index
    @q = Collection.limit(1000).ransack(params[:q])
    @collections = @q.result.order("created_at DESC")
    @search_params = params[:q]

    mtn_balance = MobileMoney::MtnEcw.get_collection_balance
    if mtn_balance == false || mtn_balance == nil || mtn_balance == true
      @mtn_collections = "N/A"
    else
      @mtn_collections = mtn_balance[:amount]
    end
    airtel_balance = MobileMoney::AirtelUganda.get_collection_balance
    if airtel_balance == false || airtel_balance == nil || airtel_balance == true
      @airtel_collections = "N/A"
    else
      @airtel_collections = airtel_balance[:amount]
    end
    respond_to do |format|
      format.html { @collections = @collections.page params[:page] }
      format.csv { send_data @collections.to_csv, filename: "Collections-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv" }
    end
  end

  #update method to reprocess pending collections
  def update
    #receive parameters from view and call the mtn collection worker
    #make a call to the mtn collection worker
    @collecton = Collection.find(params[:id])
    MtnCollectionWorker.perform_async(@collecton.transaction_id, @collecton.ext_transaction_id, "SUCCESS")
    respond_to do |format|
      flash.now[:notice] = "Collection Reprocessed."
      format.html
      format.json
      format.js   { render :layout => false }
    end
  end
end
