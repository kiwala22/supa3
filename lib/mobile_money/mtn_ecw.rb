module MobileMoney
	class MtnEcw

		require 'openssl'
		require 'json'
		require 'uri'
		require 'net/http'
		require 'logger'

		@@logger ||= Logger.new("#{Rails.root}/log/mobile_money.log")
		@@logger.level = Logger::ERROR

		@@fri = "fri:12345@supa3.sp7/SP"

		@@username = "SUPA3.sp7" #test credentials
		@@password = "ABc123456!" #test credentials

		def self.make_disbursement(first_name, last_name, phone_number, amount, transaction_id)
			url = "https://f5-test.mtn.co.ug:8017/poextvip/v1/sptransfer"
			req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns0:sptransferrequest xmlns:ns0='http://www.ericsson.com/em/emm/serviceprovider/v1_0/backend'><sendingfri>FRI:#{@@username}/USER</sendingfri><receivingfri>FRI:#{phone_number}/MSISDN</receivingfri><amount><amount>#{amount}</amount><currency>UGX</currency></amount><providertransactionid>#{transaction_id}</providertransactionid><name><firstname>#{first_name}</firstname><lastname>#{last_name}</lastname></name><sendernote>Winner Payout</sendernote><receivermessage>You have received UGX #{amount} from Supa3.</receivermessage></ns0:sptransferrequest>"
			uri = URI.parse(url)
			http = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)
			request.basic_auth(@@username, @@password)
			request.content_type = 'text/xml'
			request.body = req_xml
			http.use_ssl = true
			http.ssl_version = :TLSv1_2
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			http.cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.join("config/134_209_22_183.crt")))
			http.key = http.key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/134_209_22_183.key")))
			http.ca_file = Rails.root.join("config/m3_external_cert_CA.crt").to_s
			http.set_debug_output($stdout) # to be removed later
			res = http.request(request)
			result = Hash.from_xml(res.body)
			if result.has_key?("sptransferresponse")
				return {ext_transaction_id: result['sptransferresponse']['transactionid'], status: res.code}
			else
				return nil
			end

		rescue StandardError => e
			@@logger.error(e.message)
			false
		end

		# def self.transaction_status(ext_reference_id)
		# 	url = "https://f5-test.mtn.co.ug:8017/poextvip/v1/gettransactionstatus"
		# 	req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns2:gettransactionstatusrequest xmlns:ns2='http://www.ericsson.com/em/emm/financial/v1_1'><referenceid>#{ext_reference_id}</referenceid></ns2:gettransactionstatusrequest>"
		# 	uri = URI.parse(url)
		# 	http = Net::HTTP.new(uri.host, uri.port)
		# 	request = Net::HTTP::Post.new(uri.request_uri)
		# 	request.basic_auth(@@username, @@password)
		# 	request.content_type = 'text/xml'
		# 	request.body = req_xml
		# 	http.use_ssl = true
		# 	http.ssl_version = :TLSv1_2
		# 	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		# 	http.cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.join("config/134_209_22_183.crt")))
		# 	http.key = http.key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/134_209_22_183.key")))
		# 	http.ca_file = Rails.root.join("config/m3_external_cert_CA.crt").to_s
		# 	res = http.request(request)
		# 	result = Hash.from_xml(res.body)
		# 	if result.has_key?("gettransactionstatusresponse")
		# 		return {amount: result['gettransactionstatusresponse']['amount'], currency: result['gettransactionstatusresponse']['currency']}
		# 	else
		# 		return nil
		# 	end
		#
		# rescue StandardError => e
		# 	@@logger.error(e.message)
		# 	false
		# end

		def self.get_account_info(phone_number)
			url = "https://f5-test.mtn.co.ug:8017/poextvip/v1/getaccountholderinfo"
			req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns0:getaccountholderinforequest xmlns:ns0='http://www.ericsson.com/em/emm/provisioning/v1_2'><identity>ID:#{phone_number}/MSISDN</identity></ns0:getaccountholderinforequest>"
			uri = URI.parse(url)
			http = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)
			request.basic_auth(@@username, @@password)
			request.content_type = 'text/xml'
			request.body = req_xml
			http.use_ssl = true
			http.ssl_version = :TLSv1_2
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			http.cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.join("config/134_209_22_183.crt")))
			http.key = http.key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/134_209_22_183.key")))
			http.ca_file = Rails.root.join("config/m3_external_cert_CA.crt").to_s
			res = http.request(request)
			result = Hash.from_xml(res.body)
			if result.has_key?("getaccountholderinforesponse")
				return {mssidn: result['getaccountholderinforesponse']['accountholderbasicinfo']['mssidn'], first_name: result['getaccountholderinforesponse']['accountholderbasicinfo']['first_name'], surname: result['getaccountholderinforesponse']['accountholderbasicinfo']['surname']}
			else
				return nil
			end

		rescue StandardError => e
			@@logger.error(e.message)
			false
		end

		def self.get_balance
			url = "https://f5-test.mtn.co.ug:8017/poextvip/v1/getbalance"
			#fri = @@fri
			req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns2:getbalancerequest xmlns:ns2='http://www.ericsson.com/em/emm/financial/v1_0'><fri>FRI:#{@@username}/USER</fri></ns2:getbalancerequest>"
			uri = URI.parse(url)
			http = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Post.new(uri.request_uri)
			request.basic_auth(@@username, @@password)
			request.content_type = 'text/xml'
			request.body = req_xml
			http.use_ssl = true
			http.ssl_version = :TLSv1_2
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			http.cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.join("config/134_209_22_183.crt")))
			http.key = http.key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/134_209_22_183.key")))
			http.ca_file = Rails.root.join("config/m3_external_cert_CA.crt").to_s
			res = http.request(request)
			result = Hash.from_xml(res.body)
			if result.has_key?("getbalanceresponse")
				return {amount: result['getbalanceresponse']['balance']['amount'], currency: result['getbalanceresponse']['balance']['currency']}
			else
				return nil
			end

		rescue StandardError => e
			@@logger.error(e.message)
			false
		end

		def self.included(base)
			base.send :helper_method, :get_balance if base.respond_to? :helper_method
		end

	end

end
