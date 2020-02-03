class CollectionsController < ApplicationController
  before_action :authenticate_user!

  require 'mobile_money/mtn_ecw'
  require 'mobile_money/airtel_uganda'

  def index
    authorize! :index, :collection, :message => "You are not allowed to view this page..."
    @q = Collection.all.ransack(params[:q])
    @collections = @q.result(distinct: true).order("created_at DESC").page params[:page]
    @search_params = params[:q]

    @mtn_collections = MobileMoney::MtnEcw.get_collection_balance[:amount]
    @airtel_collections = 0
  end
end
