class Confirmation::MtnUgandaController < ApplicationController
	before_action :authenticate_source, :if => proc {Rails.env.production?}
	skip_before_action :verify_authenticity_token, raise: false

	require 'logger'
	@@logger ||= Logger.new("#{Rails.root}/log/mobile_money.log")
	@@logger.level = Logger::ERROR

	def create
		request_body = Hash.from_xml(request.body.read)
		Rails.logger.debug(request_body)
		#check the incoming body
		if request_body.has_key?("paymentrequest")
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
				#log the error
				@@logger.error(@transaction.errors.full_messages)
			end
			render body: "<?xml version='1.0' encoding='UTF-8'?><ns2:paymentresponse xmlns:ns2='http://www.ericsson.com/em/emm/serviceprovider /v1_0/backend'><providertransactionid>#{@transaction.transaction_id}</providertransactionid><scheduledtransactionid></scheduledtransactionid><newbalance><amount>0</amount><currency>UGX</currency></newbalance><paymenttoken /><message /><status>PENDING</status></ns2:paymentresponse>"
		end
	rescue StandardError => e
  			@@logger.error(e.message)
	end

	protected

    def authenticate_source
      @accepted_ips = ["212.88.97.59", "129.205.27.35", "10.156.145.219", "10.156.144.21", "10.156.191.21"]
      unauthourized_source unless @accepted_ips.include? source_ip
    end

    def unauthourized_source
      render xml: {error: 'Unauthorized'}.to_xml, status: 401
    end

    def source_ip
        request.env['REMOTE_ADDR'] || request.env["HTTP_X_FORWARDED_FOR"] || request.env['HTTP_X_REAL_IP']
    end

end
