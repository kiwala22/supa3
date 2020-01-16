class Confirmation::MtnUgandaController < ApplicationController
	skip_before_action :verify_authenticity_token, raise: false

	require 'logger'
	logger = Logger.new('mobile_money.log')
	logger.level = Logger::ERROR

	def create
		request_body = Hash.from_xml(request.body.read)
		Rails.logger.debug(request_body)
		#check the incoming body
		if request_body.has_key?("paymentrequest")
			Rails.logger.debug("I am happy")
			@transaction = Collection.new()
			@transaction.ext_transaction_id = request_body['paymentrequest']["transactionid"]
			@transaction.phone_number = request_body['paymentrequest']["accountholderid"][3..-8]
			@transaction.receiving_fri = request_body['paymentrequest']["receivingfri"][4..-4]
			@transaction.amount = request_body['paymentrequest']["amount"]["amount"]
			@transaction.currency = request_body['paymentrequest']["amount"]["currency"]
			@transaction.message = request_body['paymentrequest']["message"]
			@transaction.status = 'PENDING'
			@transaction.network = "MTN Uganda"
			if @transaction.save
				MtnCollectionWorker.perform_async(@transaction.transaction_id, @transaction.ext_transaction_id, "SUCCESS")
			else
				MtnCollectionWorker.perform_async(@transaction.transaction_id, @transaction.ext_transaction_id, "FAILED")
				#respond to the request
			end
			render body: "<?xml version='1.0' encoding='UTF-8'?><ns2:paymentresponse xmlns:ns2='http://www.ericsson.com/em/emm/serviceprovider /v1_0/backend'><providertransactionid>#{@transaction.transaction_id}</providertransactionid><scheduledtransactionid></scheduledtransactionid><newbalance><amount>0</amount><currency>UGX</currency></newbalance><paymenttoken /><message /><status>PENDING</status></ns2:paymentresponse>"
		end
	rescue StandardError => e
  			logger.error(e.message)
	end
end
