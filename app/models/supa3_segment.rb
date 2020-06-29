class Supa3Segment < ApplicationRecord

  def self.update_segments
    segment_summary = Gamer.order('supa3_segment ASC').group(:supa3_segment).count().except!(nil)
    @segment = Supa3Segment.new(segment_summary.transform_keys!(&:downcase))
    if (@segment.update_attributes(created_at: Time.now) && @segment.save)
       return true
    else
       return false
    end
  end
end
