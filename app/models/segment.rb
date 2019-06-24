class Segment < ApplicationRecord

   def self.update_segments
      segment_summary = Gamer.order('segment ASC').group(:segment).count().except!(nil)
      @segment = Segment.new(segment_summary.transform_keys!(&:downcase))
      if @segment.save
         return true
      else
         return false
      end
   end
end
