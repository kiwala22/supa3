class Confirmation::AirtelUgandaController < ApplicationController
	skip_before_action :verify_authenticity_token, raise: false

	require 'logger'
	logger = Logger.new('mobile_money.log')
	logger.level = Logger::ERROR

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
			## perhaps check that transaction is not a duplicate
			Rails.logger.debug(@transaction)
			TicketWorker.perform_async(@transaction.phone_number,@transaction.message, @transaction.amount)
			render body: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><PARTTXNID></PARTTXNID><TYPE>STANPAY</TYPE><MOBTXNID>123456789</MOBTXNID><TXNSTATUS>200</TXNSTATUS><MESSAGE>Transaction is successful</MESSAGE></COMMAND>"
		end

	rescue StandardError => e
  			logger.error(e.message)
	end
end
