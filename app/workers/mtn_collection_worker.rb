class MtnCollectionWorker
	include Sidekiq::Worker
	sidekiq_options queue: "high"
	sidekiq_options retry: false

	require 'openssl'
	require 'json'
	require 'uri'
	require 'net/http'
	require 'logger'

	def perform(transaction_id, ext_transaction_id, status)
    	@collection =  Collection.find_by(transaction_id: transaction_id) 
    	if @collection && status == 'SUCCESSFUL'
    		#send request and mark status as successful
    		url = "https://10.156.145.219:8017/poextvip/v1/paymentcompletedequest"
			req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns2:paymentcompletedequest xmlns:ns2='http://www.ericsson.com/em/emm/serviceprovider/v1_0/backend'><providertransactionid>#{transaction_id}</providertransactionid><scheduledtransactionid></scheduledtransactionid><newbalance><amount>0</amount><currency>UGX</currency></newbalance><paymenttoken/><message>#{Thank you for playing SUPA 3}</message><status>SUCCESSFUL</status></ns2:paymentcompletedequest>"
			uri = URI.parse(url)
	        http = Net::HTTP.new(uri.host, uri.port)
	        request = Net::HTTP::Post.new(uri.request_uri)
	        request.content_type = 'text/xml'
	        request.body = req_xml
	        http.use_ssl = true
	        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	        res = http.request(request)
	        result = Hash.from_xml(res.body)
	        if res.code == '200'
	        	@collection.update_attributes(status: status)
    			TicketWorker.perform_async(@collection.phone_number,@collection.message, @collection.amount)
    		end
        elsif @collection && status == 'FAILED'
        	#send request and mark status as successful
    		url = "https://10.156.145.219:8017/poextvip/v1/paymentcompletedequest"
			req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns0:paymentcompletedrequest xmlns:ns0='http://www.ericsson.com/em/emm/serviceprovider/v1_0/backend'><transactionid>#{ext_transaction_id}</transactionid><providertransactionid>#{transaction_id}</providertransactionid><message /><status>FAILED</status></ns0:paymentcompletedrequest>"
			uri = URI.parse(url)
	        http = Net::HTTP.new(uri.host, uri.port)
	        request = Net::HTTP::Post.new(uri.request_uri)
	        request.content_type = 'text/xml'
	        request.body = req_xml
	        http.use_ssl = true
	        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	        res = http.request(request)
	        result = Hash.from_xml(res.body)
	        if res.code == '200'
	        	@collection.update_attributes(status: status)
    		end
    		
    	end
    end
end
