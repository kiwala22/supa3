class BroadcastWorker
   include Sidekiq::Worker
   #include Sidekiq::Throttled::Worker

   sidekiq_options queue: "default"
   sidekiq_options retry: false

   #require 'send_sms'

   # sidekiq_throttle({
   #    # Allow maximum 10 concurrent jobs of this class at a time.
   #    :concurrency => { :limit => 10 }
   # })

   def perform(broadcast_id)
      @broadcast = Broadcast.find(broadcast_id)

      #Process Mtn broadcasts only
      if @broadcast.network == "MTN"
        if !@broadcast.segment.nil?
          if @broadcast.game == "Supa3"
            @gamers = Gamer.where("supa3_segment IN (?) and phone_number ~* ?",  @broadcast.segment.split(","), "^(25677|25678|25639|25676)")
            sender_id = ENV['DEFAULT_SENDER_ID']
          end
          if @broadcast.game == "Supa5"
            @gamers = Gamer.where("supa5_segment IN (?) and phone_number ~* ?",  @broadcast.segment.split(","), "^(25677|25678|25639|25676)")
            sender_id = ENV['DEFAULT_SENDER_ID']
          end
        end

        if !@broadcast.predicted_revenue_lower.nil? && @broadcast.predicted_revenue_upper.nil?
          lower = @broadcast.predicted_revenue_lower
          @gamers = Gamer.where("predicted_revenue >= ? and phone_number ~* ?",lower, "^(25677|25678|25639|25676)")
          sender_id = ENV['DEFAULT_SENDER_ID']
        end
        if !@broadcast.predicted_revenue_lower.nil? && !@broadcast.predicted_revenue_upper.nil?
          lower = @broadcast.predicted_revenue_lower
          upper = @broadcast.predicted_revenue_upper
          @gamers = Gamer.where("predicted_revenue >= ? and predicted_revenue <= ? and phone_number ~* ?",lower, upper, "^(25677|25678|25639|25676)")
          sender_id = ENV['DEFAULT_SENDER_ID']
        end
        contacts = 0
        @gamers.each do |gamer|
           #check if a gamer has a name or not
           if !gamer.first_name.nil?
             message = gamer.first_name + ", " + @broadcast.message
           else
             message = @broadcast.message
           end
           #send the message to message library through sms worker
           SmsWorker.perform_async(gamer.phone_number, message, sender_id)
           contacts = (contacts + 1)
        end
        @broadcast.update_attributes(contacts: contacts, status: "SUCCESS")
      end

      #Process Airtel broadcasts only
      if @broadcast.network == "AIRTEL"
        if !@broadcast.segment.nil?
          if @broadcast.game == "Supa3"
            @gamers = Gamer.where("supa3_segment IN (?) and phone_number ~* ?",  @broadcast.segment.split(","), "^(25670|25675|25674)")
            sender_id = ENV['DEFAULT_SENDER_ID']
          end
          if @broadcast.game == "Supa5"
            @gamers = Gamer.where("supa5_segment IN (?) and phone_number ~* ?",  @broadcast.segment.split(","), "^(25670|25675|25674)")
            sender_id = ENV['DEFAULT_SENDER_ID']
          end
        end

        if !@broadcast.predicted_revenue_lower.nil? && @broadcast.predicted_revenue_upper.nil?
          lower = @broadcast.predicted_revenue_lower
          @gamers = Gamer.where("predicted_revenue >= ? and phone_number ~* ?",lower, "^(25670|25675|25674)")
          sender_id = ENV['DEFAULT_SENDER_ID']
        end
        if !@broadcast.predicted_revenue_lower.nil? && !@broadcast.predicted_revenue_upper.nil?
          lower = @broadcast.predicted_revenue_lower
          upper = @broadcast.predicted_revenue_upper
          @gamers = Gamer.where("predicted_revenue >= ? and predicted_revenue <= ? and phone_number ~* ?",lower, upper, "^(25670|25675|25674)")
          sender_id = ENV['DEFAULT_SENDER_ID']
        end
        contacts = 0
        @gamers.each do |gamer|
          ##No need to check names for Airtel network
           message = @broadcast.message

           #send the message to message library through sms worker
           SmsWorker.perform_async(gamer.phone_number, message, sender_id)
           contacts = (contacts + 1)
        end
        @broadcast.update_attributes(contacts: contacts, status: "SUCCESS")
      end

      #Process for both networks
      if @broadcast.network == "ALL"
        if !@broadcast.segment.nil?
          if @broadcast.game == "Supa3"
            @gamers = Gamer.where(supa3_segment: @broadcast.segment.split(","))
            sender_id = ENV['DEFAULT_SENDER_ID']
          end
          if @broadcast.game == "Supa5"
            @gamers = Gamer.where(supa5_segment: @broadcast.segment.split(","))
            sender_id = ENV['DEFAULT_SENDER_ID']
          end
        end
        if !@broadcast.predicted_revenue_lower.nil? && @broadcast.predicted_revenue_upper.nil?
          lower = @broadcast.predicted_revenue_lower
          @gamers = Gamer.where("predicted_revenue >= ?",lower)
          sender_id = ENV['DEFAULT_SENDER_ID']
        end
        if !@broadcast.predicted_revenue_lower.nil? && !@broadcast.predicted_revenue_upper.nil?
          lower = @broadcast.predicted_revenue_lower
          upper = @broadcast.predicted_revenue_upper
          @gamers = Gamer.where("predicted_revenue >= ? and predicted_revenue <= ?",lower, upper)
          sender_id = ENV['DEFAULT_SENDER_ID']
        end
        contacts = 0
        @gamers.each do |gamer|
           #check if a gamer has a name or not
           if !gamer.first_name.nil?
             message = gamer.first_name + ", " + @broadcast.message
           else
             message = @broadcast.message
           end
           #send the message to message library through sms worker
           SmsWorker.perform_async(gamer.phone_number, message, sender_id)
           contacts = (contacts + 1)
        end
        @broadcast.update_attributes(contacts: contacts, status: "SUCCESS")
      end
   end
end
