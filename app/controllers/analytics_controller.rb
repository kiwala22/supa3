class AnalyticsController < ApplicationController
   before_action :authenticate_user!

   def index
      # gamers = Gamer.order('segment ASC').group(:segment).count()
      # gon.labels = gamers.keys
      # gon.counts = gamers.values

      segment_labels = Segment.column_names
      segment_labels = segment_labels.delete_if{ |i| ["id", "created_at", "updated_at"].include?(i)}
      gon.segment_labels = segment_labels.map(&:upcase)

      segments = Segment.order("created_at ASC").last(30)

      series = []
      segment_labels.each do |label|
         series << {"#{label}": segments.pluck("#{label}")}
      end

      dates = segments.pluck(:created_at)
      gon.dates = dates.map {|e| e.strftime("%d/%m/%y")}


      series = series.map { |e| reformat_hash(e)  }

      gon.series = series

      p series

   end

   def reformat_hash(f)
      return {
          name:f.keys.join().upcase,
          type:'line',
          data:f.values[0]
      }
   end



end
