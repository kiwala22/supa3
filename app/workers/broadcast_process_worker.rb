class BroadcastProcessWorker
  # include Sidekiq::Worker
  # sidekiq_options queue: "default"
  # sidekiq_options retry: false
  #
  # def perform
  #   jobs = Broadcast.where('status = ? AND execution_time <= ?', "PENDING", Time.now)
  #   if !jobs.empty?
  #      jobs.each do |job|
  #         #first update the status of the message and then push it to the worker
  #         job.update_attribute(:status, "PROCESSING")
  #         if !job.segment.nil?
  #           gamers = Gamer.where(segment: job.segment.split(","))
  #         end
  #         if !job.predicted_revenue_lower.nil? && job.predicted_revenue_upper.nil?
  #           lower = job.predicted_revenue_lower
  #           gamers = Gamer.where("predicted_revenue >= ?",lower)
  #         end
  #         if !job.predicted_revenue_lower.nil? && !job.predicted_revenue_upper.nil?
  #           lower = job.predicted_revenue_lower
  #           upper = job.predicted_revenue_upper
  #           gamers = Gamer.where("predicted_revenue >= ? and predicted_revenue <= ?",lower, upper)
  #         end
  #         contacts = 0
  #         gamers.each do |gamer|
  #           if !gamer.first_name.nil?
  #             message = gamer.first_name + ", " + job.message
  #           else
  #             message = job.message
  #           end
  #           BroadcastWorker.perform_async(gamer.phone_number, message)
  #           contacts = (contacts + 1)
  #         end
  #         job.update_attributes(contacts: contacts, status: "SUCCESS")
  #      end
  #   end
  # end
end
