class AnalyticsController < ApplicationController
   before_action :authenticate_user!

   def index
      #gamers = Gamer.order('segment ASC').group(:segment).count()
      supa3_gamers = Gamer.order('supa3_segment ASC').group(:supa3_segment).count()
      supa5_gamers = Gamer.order('supa5_segment ASC').group(:supa5_segment).count()
      gon.labels = supa3_gamers.keys
      gon.supa3_counts = supa3_gamers.values
      gon.supa5_counts = supa5_gamers.values

      segment_labels = Segment.column_names
      segment_labels = segment_labels.delete_if{ |i| ["g", "id", "created_at", "updated_at"].include?(i)}
      gon.segment_labels = segment_labels.map(&:upcase)

      supa3_segments = Supa3Segment.order("created_at ASC").last(30)

      supa3_series = []
      segment_labels.each do |label|
         supa3_series << {"#{label}": supa3_segments.pluck("#{label}")}
      end

      supa5_segments = Supa5Segment.order("created_at ASC").last(30)

      supa5_series = []
      segment_labels.each do |label|
         supa5_series << {"#{label}": supa5_segments.pluck("#{label}")}
      end

      dates = supa3_segments.pluck(:created_at)
      gon.dates = dates.map {|e| e.strftime("%d/%m/%y")}

      supa3_series = supa3_series.map { |e| reformat_hash(e)  }
      gon.supa3_series = supa3_series

      supa5_series = supa5_series.map { |e| reformat_hash(e)  }
      gon.supa5_series = supa5_series


   end

   def reformat_hash(f)
      return {
          name:f.keys.join().upcase,
          type:'line',
          data:f.values[0]
      }
   end



end
