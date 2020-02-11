class MtnCollectionWorker
	include Sidekiq::Worker
	sidekiq_options queue: "critical"
	sidekiq_options retry: false

	require 'openssl'
	require 'json'
	require 'uri'
	require 'net/http'
	require 'logger'
	require "send_sms"

	@@logger ||= Logger.new("#{Rails.root}/log/mobile_money.log")
	@@logger.level = Logger::ERROR

	def perform(transaction_id, ext_transaction_id, status)
		@username = "SUPA3.sp7" #test credentials
		@password = "ABc123456!" #test credentials
		@collection =  Collection.find_by(transaction_id: transaction_id)
		if @collection && @collection.status != "SUCCESSFUL"
			if status == 'SUCCESS'
				if @collection.amount.to_i > 50000
					#send request and mark status as successful
					url = "https://10.156.144.21:8006/poextvip/v1/paymentcompleted"
					req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns4:paymentcompletedrequest xmlns:ns4='http://www.ericsson.com/em/emm/serviceprovider/v1_0/backend' xmlns:op='http://www.ericsson.com/em/emm/v1_0/common' xmlns:xs='http://www.w3.org/2001/XMLSchema' version='1.0'><transactionid>#{@collection.ext_transaction_id}</transactionid><providertransactionid>#{@collection.transaction_id}</providertransactionid><status>FAILED</status></ns4:paymentcompletedrequest>"
					uri = URI.parse(url)
					http = Net::HTTP.new(uri.host, uri.port)
					request = Net::HTTP::Post.new(uri.request_uri)
					request.basic_auth(@username, @password)
					request.content_type = 'text/xml'
					request.body = req_xml
					http.use_ssl = true
					http.ssl_version = :TLSv1_2
					http.verify_mode = OpenSSL::SSL::VERIFY_NONE
					http.cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.join("config/prod/134_209_22_183.crt")))
					http.key = http.key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/prod/134_209_22_183.key")))
					http.ca_file = Rails.root.join("config/m3_external_cert_CA.crt").to_s
					#http.set_debug_output($stdout)
					res = http.request(request)
					result = Hash.from_xml(res.body)
					if res.code == '200' && result.has_key?("paymentcompletedresponse")
						@collection.update_attributes(status: "FAILED")
					end
					message_content = "Your recent wager of UGX.#{@collection.amount} exceeded the maximum of UGX.50000. Please reduce the amount and try again"
		         SendSMS.process_sms_now(receiver: @collection.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])

				elsif @collection.amount.to_i < 1000
					#send request and mark status as successful
					url = "https://10.156.144.21:8006/poextvip/v1/paymentcompleted"
					req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns4:paymentcompletedrequest xmlns:ns4='http://www.ericsson.com/em/emm/serviceprovider/v1_0/backend' xmlns:op='http://www.ericsson.com/em/emm/v1_0/common' xmlns:xs='http://www.w3.org/2001/XMLSchema' version='1.0'><transactionid>#{@collection.ext_transaction_id}</transactionid><providertransactionid>#{@collection.transaction_id}</providertransactionid><status>FAILED</status></ns4:paymentcompletedrequest>"
					uri = URI.parse(url)
					http = Net::HTTP.new(uri.host, uri.port)
					request = Net::HTTP::Post.new(uri.request_uri)
					request.basic_auth(@username, @password)
					request.content_type = 'text/xml'
					request.body = req_xml
					http.use_ssl = true
					http.ssl_version = :TLSv1_2
					http.verify_mode = OpenSSL::SSL::VERIFY_NONE
					http.cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.join("config/prod/134_209_22_183.crt")))
					http.key = http.key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/prod/134_209_22_183.key")))
					http.ca_file = Rails.root.join("config/m3_external_cert_CA.crt").to_s
					#http.set_debug_output($stdout)
					res = http.request(request)
					result = Hash.from_xml(res.body)
					if res.code == '200' && result.has_key?("paymentcompletedresponse")
						@collection.update_attributes(status: "FAILED")
					end
					message_content = "Your recent wager of UGX.#{@collection.amount} is below the minimum of UGX.1000. Please increase the amount and try again"
		         SendSMS.process_sms_now(receiver: @collection.phone_number, content: message_content, sender_id: ENV['DEFAULT_SENDER_ID'])


				elsif @collection.amount.to_i.between?(1000,50000)
					#send request and mark status as successful
					url = "https://10.156.144.21:8006/poextvip/v1/paymentcompleted"
					req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns4:paymentcompletedrequest xmlns:ns4='http://www.ericsson.com/em/emm/serviceprovider/v1_0/backend' xmlns:op='http://www.ericsson.com/em/emm/v1_0/common' xmlns:xs='http://www.w3.org/2001/XMLSchema' version='1.0'><transactionid>#{@collection.ext_transaction_id}</transactionid><providertransactionid>#{@collection.transaction_id}</providertransactionid><status>COMPLETED</status></ns4:paymentcompletedrequest>"
					uri = URI.parse(url)
					http = Net::HTTP.new(uri.host, uri.port)
					request = Net::HTTP::Post.new(uri.request_uri)
					request.basic_auth(@username, @password)
					request.content_type = 'text/xml'
					request.body = req_xml
					http.use_ssl = true
					http.ssl_version = :TLSv1_2
					http.verify_mode = OpenSSL::SSL::VERIFY_NONE
					http.cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.join("config/prod/134_209_22_183.crt")))
					http.key = http.key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/prod/134_209_22_183.key")))
					http.ca_file = Rails.root.join("config/m3_external_cert_CA.crt").to_s
					#http.set_debug_output($stdout)
					res = http.request(request)
					result = Hash.from_xml(res.body)
					if res.code == '200' && result.has_key?("paymentcompletedresponse")
						@collection.update_attributes(status: status)
						TicketWorker.perform_async(@collection.phone_number,@collection.message, @collection.amount)
					end
				end

			elsif status == 'FAILED'
				#send request and mark status as successful
				url = "https://10.156.144.21:8006/poextvip/v1/paymentcompleted"
				req_xml = "<?xml version='1.0' encoding='UTF-8'?><ns4:paymentcompletedrequest xmlns:ns4='http://www.ericsson.com/em/emm/serviceprovider/v1_0/backend' xmlns:op='http://www.ericsson.com/em/emm/v1_0/common' xmlns:xs='http://www.w3.org/2001/XMLSchema' version='1.0'><transactionid>#{@collection.ext_transaction_id}</transactionid><providertransactionid>#{@collection.transaction_id}</providertransactionid><status>FAILED</status></ns4:paymentcompletedrequest>"
				uri = URI.parse(url)
				http = Net::HTTP.new(uri.host, uri.port)
				request = Net::HTTP::Post.new(uri.request_uri)
				request.basic_auth(@username, @password)
				request.content_type = 'text/xml'
				request.body = req_xml
				http.use_ssl = true
				http.ssl_version = :TLSv1_2
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
				http.cert = OpenSSL::X509::Certificate.new(File.read(Rails.root.join("config/prod/134_209_22_183.crt")))
				http.key = http.key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join("config/prod/134_209_22_183.key")))
				http.ca_file = Rails.root.join("config/m3_external_cert_CA.crt").to_s
				#http.set_debug_output($stdout)
				res = http.request(request)
				result = Hash.from_xml(res.body)
				if res.code == '200' && result.has_key?("paymentcompletedresponse")
					@collection.update_attributes(status: status)
				end

			end
		end
	rescue StandardError => e
		@@logger.error(e.message)
		false
	end
end
