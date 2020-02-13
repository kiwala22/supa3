class Confirmation::AirtelUgandaController < ApplicationController
	before_action :authenticate_source, :if => proc {Rails.env.production?}
	skip_before_action :verify_authenticity_token, raise: false

	require 'logger'
	@@logger ||= Logger.new("#{Rails.root}/log/airtel_mobile_money.log")
	@@logger.level = Logger::ERROR

	def create
		request_body = Hash.from_xml(request.body.read)
		Rails.logger.debug(request_body)
		@transaction = Collection.new()
		@transaction.ext_transaction_id = request_body['COMMAND']["MOBTXNID"]
		phone_number = request_body['COMMAND']["MSISDN"]
		@transaction.phone_number = "256" + phone_number
		@transaction.receiving_fri = request_body['COMMAND']["BILLERCODE"]
		@transaction.amount = request_body['COMMAND']["AMOUNT"]
		@transaction.currency = "UGX"
		@transaction.message = request_body['COMMAND']["REFERENCE"]
		@transaction.status = 'SUCCESS'
		@transaction.network = "Airtel Uganda"
		if @transaction.save
			## perhaps check that transaction is not a duplicate # done with uniqueness on ext_transaction_id
			AirtelCollectionWorker.perform_async(@transaction_id)
			render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><PARTTXNID>#{@transaction.transaction_id}</PARTTXNID><TYPE>STANPAY</TYPE><MOBTXNID>#{@transaction.ext_transaction_id}</MOBTXNID><TXNSTATUS>200</TXNSTATUS><MESSAGE>Transaction is successful</MESSAGE></COMMAND>"
		else
			render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><PARTTXNID>#{@transaction.transaction_id}</PARTTXNID><TYPE>STANPAY</TYPE><MOBTXNID>#{@transaction.ext_transaction_id}</MOBTXNID><TXNSTATUS>400</TXNSTATUS><MESSAGE>Transaction has failed</MESSAGE></COMMAND>"
			@@logger.error(@transaction.errors.full_messages)
		end

	rescue StandardError => e
  			@@logger.error(e.message)
	end

	protected

    def authenticate_source
      @accepted_ips = ["41.223.86.34", "172.22.77.136","172.22.77.137","172.22.77.138","172.22.77.135","172.22.77.145","172.22.77.147","172.22.77.148","172.22.77.151","172.22.77.152","172.22.77.153" ]
      unauthourized_source unless @accepted_ips.include? source_ip
    end

    def unauthourized_source
      render xml: {error: 'Unauthorized'}.to_xml, status: 401
    end

    def source_ip
        request.env['REMOTE_ADDR'] || request.env["HTTP_X_FORWARDED_FOR"] || request.env['HTTP_X_REAL_IP']
    end
end
