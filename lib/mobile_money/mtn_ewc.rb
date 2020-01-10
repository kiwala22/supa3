module MobileMoney
	class MtnEcw

		require 'openssl'
		require 'json'
		require 'uri'
		require 'net/http'

		def self.make_disbursement(f)
			
		end

		def self.transaction_status(ext_reference_id)
			url = ""
			req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns2:gettransactionstatusrequest xmlns:ns2='http://www.ericsson.com/em/emm/financial/v1_1'><referenceid>#{ext_reference_id}</referenceid></ns2:gettransactionstatusrequest>"
			uri = URI.parse(url)
	        http = Net::HTTP.new(uri.host, uri.port)
	        request = Net::HTTP::Post.new(uri.request_uri)
	        request.content_type = 'text/xml'
	        request.body = req_xml
	        http.use_ssl = true
	        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	        res = http.request(request)
	        result = Hash.from_xml(res.body)
	        if result.has_key?("gettransactionstatusresponse")
	        	return {amount: result['getbalanceresponse']['amount'], currency: result['getbalanceresponse']['currency']}
	        else
	        	return nil
	        end
		end

		def self.get_account_info(phone_number)
			url = ""
			req_xml = "<?xml version="1.0" encoding='UTF-8'?><ns0:getaccountholderinforequest xmlns:ns0='http://www.ericsson.com/em/emm/provisioning/v1_2'><identity>ID:#{phone_number}/MSISDN</identity></ns0:getaccountholderinforequest>"
			uri = URI.parse(url)
	        http = Net::HTTP.new(uri.host, uri.port)
	        request = Net::HTTP::Post.new(uri.request_uri)
	        request.content_type = 'text/xml'
	        request.body = req_xml
	        http.use_ssl = true
	        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	        res = http.request(request)
	        result = Hash.from_xml(res.body)
	        if result.has_key?("getaccountholderinforesponse")
	        	return {mssidn: result['getaccountholderinforesponse']['accountholderbasicinfo'['mssidn'], first_name: result['getaccountholderinforesponse']['accountholderbasicinfo'['first_name'], surname: result['getaccountholderinforesponse']['accountholderbasicinfo'['surname']}
	        else
	        	return nil
	        end
			
		end

		def self.get_balance(fri)
			url = ""
			fri = ""
			req_xml = "<?xml version="1.0" encoding='UTF-8'?><ns2:getbalancerequest xmlns:ns2='http://www.ericsson.com/em/emm/financial/v1_0'><fri>#{fri}</fri></ns2:getbalancerequest>"
			uri = URI.parse(url)
	        http = Net::HTTP.new(uri.host, uri.port)
	        request = Net::HTTP::Post.new(uri.request_uri)
	        request.content_type = 'text/xml'
	        request.body = req_xml
	        http.use_ssl = true
	        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	        res = http.request(request)
	        result = Hash.from_xml(res.body)
	        if result.has_key?("getbalanceresponse")
	        	return {amount: result['getbalanceresponse']['amount'], currency: result['getbalanceresponse']['currency']}
	        else
	        	return nil
	        end
			
		end

	end

end