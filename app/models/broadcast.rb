class Broadcast < ApplicationRecord
  belongs_to :user
  validates :execution_time, :message,:status,:segment, presence: true

  def self.process_broadcasts
     #find the broadcasts with a status of "PENDING"
     jobs = Broadcast.where('status = ? AND execution_time <= ?', "PENDING", Time.now)
     if !jobs.empty?
       jobs.each do |job|
          #first update the status of the message and then push it to the worker
          job.update_attribute(:status, "PROCESSING")
          BroadcastWorker.perform_async(job.id)
       end
     end
  end
end
