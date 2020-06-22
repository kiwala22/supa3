class Confirmation::AirtelUgandaController < ApplicationController
	#before_action :authenticate_source, :if => proc {Rails.env.production?}
	skip_before_action :verify_authenticity_token, raise: false

	require 'logger'
	@@logger ||= Logger.new("#{Rails.root}/log/airtel_mobile_money.log")
	@@logger.level = Logger::ERROR

	def create
		req = (request.body.read).gsub('&', '')
		Rails.logger.debug(req)
		request_body = Hash.from_xml(req)
		Rails.logger.debug(request_body)
		if request_body['COMMAND']['TYPE'] == "STANPAY"
			@transaction = Collection.new(
				ext_transaction_id: request_body['COMMAND']["MOBTXNID"],
				phone_number: request_body['COMMAND']["MSISDN"],
				receiving_fri: request_body['COMMAND']["BILLERCODE"],
				amount: request_body['COMMAND']["AMOUNT"],
				currency: "UGX",
				message: request_body['COMMAND']["REFERENCE"],
				status: 'SUCCESS',
				network: "Airtel Uganda"
			)
			if @transaction.save
				## perhaps check that transaction is not a duplicate # done with uniqueness on ext_transaction_id
				AirtelCollectionWorker.perform_async(@transaction.transaction_id)
				render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><PARTTXNID>#{@transaction.transaction_id}</PARTTXNID><TYPE>STANPAY</TYPE><MOBTXNID>#{@transaction.ext_transaction_id}</MOBTXNID><TXNSTATUS>200</TXNSTATUS><MESSAGE>Transaction is successful</MESSAGE></COMMAND>"
			else
				#check if it already existing
				collection = Collection.find_by(ext_transaction_id: @transaction.ext_transaction_id)
				if (collection.present? && collection.status == "SUCCESS")
					render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><PARTTXNID>#{collection.transaction_id}</PARTTXNID><TYPE>STANPAY</TYPE><MOBTXNID>#{collection.ext_transaction_id}</MOBTXNID><TXNSTATUS>200</TXNSTATUS><MESSAGE>Transaction is successful</MESSAGE></COMMAND>"
				elsif (collection.present? && collection.status == "FAILED")
					render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><PARTTXNID>#{collection.transaction_id}</PARTTXNID><TYPE>STANPAY</TYPE><MOBTXNID>#{collection.ext_transaction_id}</MOBTXNID><TXNSTATUS>300</TXNSTATUS><MESSAGE>Transaction has failed</MESSAGE></COMMAND>"
				else
					render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><PARTTXNID>#{@transaction.transaction_id}</PARTTXNID><TYPE>STANPAY</TYPE><MOBTXNID>#{@transaction.ext_transaction_id}</MOBTXNID><TXNSTATUS>400</TXNSTATUS><MESSAGE>Transaction has failed</MESSAGE></COMMAND>"
					@@logger.error(@transaction.errors.full_messages)
				end
			end
		elsif request_body['COMMAND']['TYPE'] == "MERCHPAYMENTPUSH"
			push_pay_broadcast = PushPayBroadcast.find_by(ext_transaction_id: request_body['COMMAND']["TXNID"] , transaction_id: request_body['COMMAND']["EXTTRID"] )
			if push_pay_broadcast
				case request_body['COMMAND']["TXNSTATUS"]
				when "200"
					push_pay_broadcast.update_attributes(status: "SUCCESS")
					#process the collection
					@transaction = Collection.new()
					@transaction.ext_transaction_id = request_body['COMMAND']["TXNID"]
					@transaction.phone_number = push_pay_broadcast.phone_number
					@transaction.receiving_fri = ""
					@transaction.amount = push_pay_broadcast.amount
					@transaction.currency = "UGX"
					@transaction.message = push_pay_broadcast.data
					@transaction.status = 'SUCCESS'
					@transaction.network = "Airtel Uganda"

					if @transaction.save
						## perhaps check that transaction is not a duplicate # done with uniqueness on ext_transaction_id
						AirtelCollectionWorker.perform_async(@transaction.transaction_id)
					end

					render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>MERCHPAYRESP</TYPE><TXNSTATUS>Transaction Status</TXNSTATUS><MESSAGE>Transaction is successful</MESSAGE></COMMAND>"
				else
					push_pay_broadcast.update_attributes(status: "FAILED")
					render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>MERCHPAYRESP</TYPE><TXNSTATUS>400</TXNSTATUS><MESSAGE>Transaction has failed</MESSAGE></COMMAND>"
				end
			else
					render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>MERCHPAYRESP</TYPE><TXNSTATUS>400</TXNSTATUS><MESSAGE>Transaction has failed</MESSAGE></COMMAND>"
			end

		end

	rescue StandardError => e
		@@logger.error(e.message)
	end

	protected

	def authenticate_source
		@accepted_ips = ["41.223.86.50","41.223.86.51","41.223.86.52","41.223.86.34", "172.22.77.136","172.22.77.137","172.22.77.138","172.22.77.135","172.22.77.145","172.22.77.147","172.22.77.148","172.22.77.151","172.22.77.152","172.22.77.153" ]
		unauthourized_source unless @accepted_ips.include? source_ip
	end

	def unauthourized_source
		render xml: {error: 'Unauthorized'}.to_xml, status: 401
	end

	def source_ip
		request.env['REMOTE_ADDR'] || request.env["HTTP_X_FORWARDED_FOR"] || request.env['HTTP_X_REAL_IP']
	end
end
