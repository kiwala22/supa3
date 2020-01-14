class CollectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :index, :collection, :message => "You are not allowed to view this page..."
    @q = Collection.all.ransack(params[:q])
    @collections = @q.result(distinct: true).order("created_at DESC").page params[:page]
    @search_params = params[:q]
  end
end
