class DisbursementsController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :index, :disbursement, :message => "You are not allowed to view this page..."
    @q = Disbursement.all.ransack(params[:q])
    @disbursements = @q.result(distinct: true).order("created_at DESC").page params[:page]
    @search_params = params[:q]
  end
end
