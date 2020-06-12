class Segment < ApplicationRecord
  #method to create segments
  def self.update_segments
    segment_summary = Gamer.order('segment ASC').group(:segment).count().except!(nil)
    @segment = Segment.new(segment_summary.transform_keys!(&:downcase))
    if @segment.save
       @segment.update_attributes(created_at: Time.now)
       return true
    else
       return false
    end
  end
end
