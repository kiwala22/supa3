class Confirmation::AirtelMerchantPayController < ApplicationController
  before_action :authenticate_source, :if => proc {Rails.env.production?}
	skip_before_action :verify_authenticity_token, raise: false

	require 'logger'
	@@logger ||= Logger.new("#{Rails.root}/log/airtel_mobile_money.log")
	@@logger.level = Logger::ERROR


  def create
      request_body = Hash.from_xml(request.body.read)
    	Rails.logger.debug(request_body)
      if request_body['COMMAND']['TYPE'] == "CALLBCKREQ"
        push_pay_broadcast = PushPayBroadcast.find_by(transaction_id: request_body['COMMAND']["EXTTRID"])
        if push_pay_broadcast
          case request_body['COMMAND']["TXNSTATUS"]
          when "200"
            push_pay_broadcast.update_attributes(status: "COMPLETED", ext_transaction_id: request_body['COMMAND']["TXNID"])
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
            render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>CALLBCKRESP</TYPE><TXNID>#{push_pay_broadcast.ext_transaction_id}</TXNID><EXTTRID>#{push_pay_broadcast.transaction_id}</EXTTRID><TXNSTATUS>200</TXNSTATUS><MESSAGE>Transaction is successful</MESSAGE></COMMAND>"
          else
            push_pay_broadcast.update_attributes(status: "FAILED", ext_transaction_id: request_body['COMMAND']["TXNID"])
            render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>CALLBCKRESP</TYPE><TXNID>#{push_pay_broadcast.ext_transaction_id}</TXNID><EXTTRID>#{push_pay_broadcast.transaction_id}</EXTTRID><TXNSTATUS>300</TXNSTATUS><MESSAGE>Transaction has failed</MESSAGE></COMMAND>"
          end
        else
            render xml: "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>CALLBCKRESP</TYPE><TXNSTATUS>300</TXNSTATUS><MESSAGE>Transaction has failed</MESSAGE></COMMAND>"
        end
      end
    rescue StandardError => e
      @@logger.error(e.message)
  end

  protected

	def authenticate_source
		@accepted_ips = ["41.223.86.43","41.223.86.50","41.223.86.51","41.223.86.52","41.223.86.34", "172.22.77.136","172.22.77.137","172.22.77.138","172.22.77.135","172.22.77.145","172.22.77.147","172.22.77.148","172.22.77.151","172.22.77.152","172.22.77.153" ]
		unauthourized_source unless @accepted_ips.include? source_ip
	end

	def unauthourized_source
		render xml: {error: 'Unauthorized'}.to_xml, status: 401
	end

	def source_ip
		request.env['REMOTE_ADDR'] || request.env["HTTP_X_FORWARDED_FOR"] || request.env['HTTP_X_REAL_IP']
  end
end
