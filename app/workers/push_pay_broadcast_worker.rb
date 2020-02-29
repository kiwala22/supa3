class PushPayBroadcastWorker
	include Sidekiq::Worker
	include Sidekiq::Throttled::Worker

	sidekiq_options queue: "low"
	sidekiq_options retry: false

	sidekiq_throttle({
	    # Allow maximum 10 concurrent jobs of this class at a time.
	    :concurrency => { :limit => 2 },
	    # Allow maximum 3 jobs being processed within one second window.
	    :threshold => { :limit => 3, :period => 1.second }
  	})


	require "mobile_money/mtn_ecw"
	require "mobile_money/airtel_uganda"

	def perform(broadcast_id, message)
      @broadcast = PushPayBroadcast.find(broadcast_id)
      phone_number = @broadcast.phone_number
      data = generate_random_data()
      data = "PUSHPAY" + data
      transaction_id = generate_references
      @broadcast.update_attributes(status: "PROCESSING", data: data, transaction_id: transaction_id)
      result = MobileMoney::AirtelUganda.push_merchantpay_request(phone_number, transaction_id, message, data)
      if result && result[:status] == "200"
         @broadcast.update_attributes(ext_transaction_id: result[:ext_transaction_id], status: "COMPLETED")
      else
         @broadcast.update_attributes(status: "FAILED")
      end

	end

   def generate_random_data()
      random_numbers = []
      while random_numbers.length != 3
           random_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
      end
      return random_numbers.join("")
   end

   def generate_references
		loop do
			transaction_id = SecureRandom.hex(10)
			break transaction_id unless PushPayBroadcast.where(transaction_id: transaction_id).exists?
		end
	end
end
