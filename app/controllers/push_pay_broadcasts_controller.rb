class PushPayBroadcastsController < ApplicationController
  def index
  end

  def new
    @push_pay_broadcast = PushPayBroadcast.new()
  end

  def create
  end
end
