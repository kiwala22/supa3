class UpdateGamerInfoWorker
   include Sidekiq::Worker
   include Sidekiq::Throttled::Worker

   sidekiq_throttle({
       # Allow maximum 10 concurrent jobs of this class at a time.
       :concurrency => { :limit => 10 }
     })
     
   sidekiq_options queue: "low"
   sidekiq_options retry: false

   require "mobile_money/mtn_ecw"

   def perform()
      # Gamer.where(first_name: nil, last_name: nil).find_in_batches(batch_size: 500) do |gamers|
      #    Gamer.transaction do
      #       gamers.each do |gamer|
      #          if gamer.phone_number =~ /^(25678|25677|25639)/
      #             info = MobileMoney::MtnEcw.get_account_info(gamer.phone_number)
      #             if info
      #                gamer.update_attributes(first_name: info[:first_name], last_name: info[:surname])
      #             end
      #          end
      #       end
      #    end
      # end
      (Ticket.where.not(time: nil) && Ticket.where("time != created_at")).find_each(batch_size: 1000) do |ticket|
         ticket.update_attributes(created_at: ticket.time)
      end
   end
end
