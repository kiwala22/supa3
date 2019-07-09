class DrawsController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token


    def index
        @q = Draw.all.ransack(params[:q])
        @draws = @q.result(distinct: true).order("created_at DESC").page params[:page]
        @search_params = params[:q]
    end
end
