class DrawsController < ApplicationController
    before_action :authenticate_user!
    skip_before_action :verify_authenticity_token


    def index
        @q = Draw.limit(10000).ransack(params[:q])
        @draws = @q.result.order("created_at DESC").page params[:page]
        @search_params = params[:q]
    end

    private
    def draw_params
        params.permit(:search_params)
    end
end
