module MobileMoney
	class AirtelUganda

		require 'openssl'
		require 'json'
		require 'uri'
		require 'net/http'
		require 'logger'

		@@logger ||= Logger.new("#{Rails.root}/log/mobile_money.log")
		@@logger.level = Logger::ERROR

		@@payer_phone_number = ''
		@@user_name = ''
		@@password = ''
		@@pin = ''



		def self.make_disbursement(phone_number, amount, transaction_id)
			phone_number = phone_number[3..-1]
			url = "http://172.16.1.109:5555/Mobiquity?LOGIN=#{@@user_name}&PASSWORD=#{@@password}&REQUEST_GATEWAY_CODE=WEB&REQUEST_GATEWAY_TYPE=WEB&requestText="
			req_xml = "<?xml version='1.0' encoding='UTF-8'?><COMMAND><SNDINSTRUMENT>12</SNDINSTRUMENT><MSISDN>#{@@payer_phone_number}</MSISDN><PAYID>12</PAYID><SNDPROVIDER>101</SNDPROVIDER><language>en</language><RCVINSTRUMENT>12</RCVINSTRUMENT><LANGUAGE2>1</LANGUAGE2><PAYID2>12</PAYID2><LANGUAGE1>1</LANGUAGE1><PAYID1>12</PAYID1><PROVIDER1>101</PROVIDER1><PIN>#{@@pin}</PIN><PROVIDER2>101</PROVIDER2><RCVPROVIDER>101</RCVPROVIDER><IS_MERCHANT_CASHIN>Y</IS_MERCHANT_CASHIN><MERCHANT_TXN_ID>#{transaction_id}</MERCHANT_TXN_ID><PROVIDER>101</PROVIDER><BPROVIDER>101</BPROVIDER><PIN_CHECK>FALSE</PIN_CHECK><TYPE>RCIREQ</TYPE><AMOUNT>#{amount}</AMOUNT><MSISDN2>#{phone_number}</MSISDN2><interfaceId>TRANSFERTO</interfaceId><USERNAME>#{@@user_name}</USERNAME><PASSWORD>#{@@password}</PASSWORD></COMMAND>"
			uri = URI.parse(url)
	        http = Net::HTTP.new(uri.host, uri.port)
	        request = Net::HTTP::Post.new(uri.request_uri)
	        request.content_type = 'text/xml'
	        request.body = req_xml
	        http.use_ssl = true
	        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	        res = http.request(request)
	        result = Hash.from_xml(res.body)
	        if result.has_key?("COMMAND")
	        	return {ext_transaction_id: result['COMMAND']['TXNID'], status: result['COMMAND']['TXNSTATUS'] , message: result['COMMAND']['MESSAGE'] }
	        else
	        	return nil
	        end

	    rescue StandardError => e
  			@@logger.error(e.message)
		end

		def self.check_transaction_status(ext_transaction_id)
			url = "http://172.16.1.109:5555/Mobiquity?LOGIN=#{@@user_name}&PASSWORD=#{@@password}&REQUEST_GATEWAY_CODE=EXT001&REQUEST_GATEWAY_TYPE=EXTSYS"
			req_xml = "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>TXNEQREQ</TYPE><interfaceId>Oltranz</interfaceId><EXTTRID>#{ext_transaction_id}</EXTTRID><TRID></TRID></COMMAND>"
			uri = URI.parse(url)
	        http = Net::HTTP.new(uri.host, uri.port)
	        request = Net::HTTP::Post.new(uri.request_uri)
	        request.content_type = 'text/xml'
	        request.body = req_xml
	        http.use_ssl = true
	        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	        res = http.request(request)
	        result = Hash.from_xml(res.body)
	        if result.has_key?("COMMAND")
	        	return {status: result['COMMAND']['TXNSTATUS'], message: result['COMMAND']['MESSAGE'] }
	        else
	        	return nil
	        end

	    rescue StandardError => e
  			@@logger.error(e.message)
		end

	end

end
