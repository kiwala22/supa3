class PaymentWorker
	include Sidekiq::Worker
	sidekiq_options queue: "high"
	sidekiq_options retry: false

	require "mobile_money/mtn_ecw"
	require "mobile_money/airtel_uganda"

	def perform(payment_id, amount)
		@payment = Payment.find(payment_id)
		@disbursement = Disbursement.new(phone_number: @payment.phone_number, currency: "UGX", amount: amount, status: "PENDING")
		if @payment && @disbursement.save
			case @payment.phone_number

			when /^(25678|25677|25639)/
				#process mtn disbursement
				result = MobileMoney::MtnEcw.make_disbursement(@payment.first_name, @payment.last_name, @payment.phone_number, amount, @disbursement.transaction_id)
				if result
					if result[:status] == '200'
						#update attributes for disbusement such as the network and ticket confirmation
						@disbursement.update_attributes(status: "SUCCESS", ext_transaction_id: result[:ext_transaction_id], network: "MTN Uganda")
						@payment.update_attributes(status: "SUCCESS")
					else
						@disbursement.update_attributes(status: "FAILED", ext_transaction_id: result[:ext_transaction_id], network: "MTN Uganda")
					end
				end
			when /^(25675|25670)/
				#Airtel disbursement
				result = MobileMoney::AirtelUganda.make_disbursement(@payment.phone_number, amount, @disbursement.transaction_id)
				if result
					if result[:status] == '200'
						#update attributes for disbusement such as the network and ticket confirmation
						@disbursement.update_attributes(status: "SUCCESS", ext_transaction_id: result[:ext_transaction_id], network: "Airtel Uganda")
						@payment.update_attributes(status: "SUCCESS")
					else
						@disbursement.update_attributes(status: "FAILED", ext_transaction_id: result[:ext_transaction_id], network: "Airtel Uganda")
					end
				end
			end

		end
	end
end
