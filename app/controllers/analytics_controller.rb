class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  
  def index
     @gamers = Gamer.all.order("created_at DESC").page params[:page]
     labels = (0.0..1.0).step(0.1).to_a.map!{|f| f.round(1)}
     game_counts = []
     labels.each do |f|
       people_count = Gamer.where('probability >= ? AND probability <= ?', f, (f+0.09)).count()
       game_counts << people_count
     end

     gon.labels = labels
     gon.game_counts = game_counts
  end
end
