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
			@transaction = Collection.new()
			@transaction.ext_transaction_id = request_body['paymentrequest']["transactionid"]
			@transaction.phone_number = request_body['paymentrequest']["accountholderid"]
			@transaction.receiving_fri = request_body['paymentrequest']["receivingfri"]
			@transaction.amount = request_body['paymentrequest']["amount"]["amount"]
			@transaction.currency = request_body['paymentrequest']["amount"]["currency"]
			@transaction.message = request_body['paymentrequest']["message"]
			@transaction.status = 'PENDING'
			@transaction.network = "MTN Uganda"
			if @transaction.save
				#respond to the request
				render body: "<?xml version='1.0' encoding='UTF-8'?><ns2:paymentresponse xmlns:ns2='http://www.ericsson.com/em/emm/serviceprovider /v1_0/backend'><providertransactionid>#{@transaction.transaction_id}</providertransactionid><scheduledtransactionid></scheduledtransactionid><newbalance><amount>0</amount><currency>UGX</currency></newbalance><paymenttoken /><message /><status>PENDING</status></ns2:paymentresponse>"
			end
		elsif request_body.has_key?("paymentcompletedrequest")
			transaction_id = request_body['paymentcompletedrequest']['providertransactionid']
			status = request_body['paymentcompletedrequest']['status']
			ext_transaction_id = request_body['paymentcompletedrequest']['transactionid']
			#run a worker to process the confirmation and update the transaction
			MtnCollectionWorker.perform_async(transaction_id, ext_transaction_id, status)
			#respond
			render :nothing => true, :status => 200, :content_type => 'text/xml'

		end
	rescue StandardError => e
  			logger.error(e.message)
	end
end
