class AnalyticsController < ApplicationController
   before_action :authenticate_user!

   def index
      gamers = Gamer.group(:segment).count()
      gon.labels = gamers.keys
      gon.counts = gamers.values

      segment_labels = Segment.column_names
      segment_labels = segment_labels.delete_if{ |i| ["id", "created_at", "updated_at"].include?(i)}
      segment_labels = sements_labels.map(&:upcase)

      segments = Segment.order("created_at DESC").first(14)


   end

end
