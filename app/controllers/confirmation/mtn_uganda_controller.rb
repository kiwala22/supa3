class Confirmation::MtnUgandaController < ApplicationController
	before_action :authenticate_source, :if => proc {Rails.env.production?}
	skip_before_action :verify_authenticity_token, raise: false

	require 'logger'
	@@logger ||= Logger.new("#{Rails.root}/log/mtn_mobile_money.log")
	@@logger.level = Logger::ERROR

	def create
		request_body = Hash.from_xml(request.body.read)
		Rails.logger.debug(request_body)
		#check the incoming body
		if request_body.has_key?("paymentrequest")
			namespace = request_body['paymentrequest']["xmlns:ns0"]
			@transaction = Collection.new(
				ext_transaction_id: request_body['paymentrequest']["transactionid"],
				phone_number: request_body['paymentrequest']["accountholderid"][3..-8],
				receiving_fri: request_body['paymentrequest']["receivingfri"][4..-4],
				amount: request_body['paymentrequest']["amount"]["amount"],
				currency: request_body['paymentrequest']["amount"]["currency"],
				message: request_body['paymentrequest']["message"],
				status: 'PENDING',
				network: "MTN Uganda"
			)
			if @transaction.save
				status = "PENDING"
				transaction_id = @transaction.ext_transaction_id
				MtnCollectionWorker.perform_async(@transaction.transaction_id, @transaction.ext_transaction_id, "SUCCESS")
			else
				#check if it is existing
				collection = Collection.find_by(ext_transaction_id: @transaction.ext_transaction_id)
				if collection.present?
					status = "COMPLETED"
					transaction_id = collection.ext_transaction_id
				else
					status = "FAILED"
					transaction_id = @transaction.ext_transaction_id
					#log the error
					@@logger.error(@transaction.errors.full_messages)
				end
			end
			render xml: "<?xml version='1.0' encoding='UTF-8'?><ns0:paymentresponse xmlns:ns0='#{namespace}'><providertransactionid>#{transaction_id}</providertransactionid><message>#{status}</message><status>#{status}</status></ns0:paymentresponse>"
		end
	rescue StandardError => e
  			@@logger.error(e.message)
	end

	protected

    def authenticate_source
      @accepted_ips = ["10.156.144.21", "10.156.191.21"] #test ips removed "212.88.97.59", "129.205.27.35", "10.156.145.219"
      unauthourized_source unless @accepted_ips.include? source_ip
    end

    def unauthourized_source
      render xml: {error: 'Unauthorized'}.to_xml, status: 401
    end

    def source_ip
        request.env['REMOTE_ADDR'] || request.env["HTTP_X_FORWARDED_FOR"] || request.env['HTTP_X_REAL_IP']
    end

end
