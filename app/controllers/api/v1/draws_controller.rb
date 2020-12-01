class Api::V1::DrawsController < ApplicationController
  before_action :authenticate_user
  before_action :authenticate_source, :if => proc {Rails.env.production?}
	require 'uri'
	require 'cgi'


  def index
    supa3_draws = Draw.where(game: "Supa3").last(5).as_json(only: [:id, :winning_number, :draw_time, :game])
    supa5_draws = Draw.where(game: "Supa5").last(5).as_json(only: [:id, :winning_number, :draw_time, :game])

    render json: {supa3: supa3_draws, supa5: supa5_draws}
  end



  protected

  def authenticate_user
    render json: {status: "Unauthorized. Invalid token."}  unless allowed_user
  end

  def allowed_user
    # find token. Check if valid.
			access_user_token = params[:token]
			user = AccessUser.find_by(token: access_user_token)
			if user
				true
			else
				false
			end
  end

  def authenticate_source
    @accepted_ips = []
    unauthourized_source unless @accepted_ips.include? source_ip
  end

  def unauthourized_source
    render json: {status: 'Unauthorized IP Address.'}
  end

  def source_ip
      request.env['REMOTE_ADDR'] || request.env["HTTP_X_FORWARDED_FOR"] || request.env['HTTP_X_REAL_IP']
  end


end
