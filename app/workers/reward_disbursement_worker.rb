class RewardDisbursementWorker
	include Sidekiq::Worker
	sidekiq_options queue: "high"
	sidekiq_options retry: false

	require "mobile_money/mtn_ecw"
	require "mobile_money/airtel_uganda"

	def perform(gamer_id, amount)
		@gamer = Gamer.find(gamer_id)
		@disbursement = Disbursement.new(phone_number: @gamer.phone_number, currency: "UGX", amount: amount, status: "PENDING", message: "Reward")
		if @gamer && @disbursement.save
			case @gamer.phone_number

			when /^(25678|25677|25639)/
				#process mtn disbursement
				result = MobileMoney::MtnEcw.make_disbursement(@gamer.first_name, @gamer.last_name, @gamer.phone_number, amount, @disbursement.transaction_id)
				if result
					if result[:status] == '200'
						#update attributes for disbusement such as the network and ticket confirmation
	    				@disbursement.update_attributes(status: "SUCCESS", ext_transaction_id: result[:ext_transaction_id], network: "MTN Uganda")
							@gamer.prediction.update(rewarded: "Yes")
	    			else
	    				@disbursement.update_attributes(status: "FAILED", ext_transaction_id: result[:ext_transaction_id], network: "MTN Uganda")
	    			end
					else
						@disbursement.update_attributes(status: "FAILED", network: "MTN Uganda")
    			end
    		when /^(25675|25670)/
    			#Airtel disbursement
    			result = MobileMoney::AirtelUganda.make_disbursement(@gamer.phone_number, amount, @disbursement.transaction_id)
    			if result
    				if result[:status] == '200'
						#update attributes for disbusement such as the network and ticket confirmation
	    				@disbursement.update_attributes(status: "SUCCESS", ext_transaction_id: result[:ext_transaction_id], network: "Airtel Uganda")
	    			else
	    				@disbursement.update_attributes(status: "FAILED", ext_transaction_id: result[:ext_transaction_id], network: "Airtel Uganda")
	    			end
					else
						@disbursement.update_attributes(status: "FAILED", network: "Airtel Uganda")
    			end
    		end
		end
	end
end
