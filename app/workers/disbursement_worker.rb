class DisbursementWorker
	include Sidekiq::Worker
	sidekiq_options queue: "high"
	sidekiq_options retry: false

	require "mobile_money/mtn_ecw"

	def perform(gamer_id, amount)
    	@gamer = Gamer.find(gamer_id)
    	@disbusement = Disbursement.new(phone_number: @gamer.phone_number, currency: "UGX", amount: amount, status: "PENDING")
    	if @gamer && @disbusement.save
    		case @gamer.phone_number

    		when /^(25678|25677|25639)/
    			#process mtn disbursement
    			result = MobileMoney::Ecw.make_disbursement(@gamer.first_name, @gamer.last_name, @gamer.phone_number, amount, @disbursement.transaction_id)
    			if result
						#update attributes for disbusement such as the network
    				@disbursement.update_attributes(status: "SUCCESS", ext_transaction_id: result[:ext_transaction_id], network: "MTN Uganda")
    			end
    		when /^(25675|25670)/
    			#Airtel disbursehment


    		end

    	end
	end
end
