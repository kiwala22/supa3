module MobileMoney
	class MtnUganda

		require 'openssl'
		require 'json'
		require 'uri'
		require 'net/http'

		@@sub_key  = "12e0c6ecfb5f4a4788f44bd1fc65f81c"

		def self.request_payments(amount, ext_reference, phone_number )
			url = "https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay" 
			callback_url = ""

			uri = URI(url)

			req = Net::HTTP::Post.new(uri)

			## Set the headers
			#set transactions callback url
			req['X-Callback-Url'""] = callback_url

			#set the transaction reference
			req['X-Reference-Id'] = ext_reference

			#set Enviroment
			req['X-Target-Environment'] = ""

			#set content type
			req['Content-Type'] = "application/json"

			#set the subscription keys
			req['Ocp-Apim-Subscription-Key'] = @@sub_key

			request_body = {
				amount: amount,
			   currency: "UGX",
			   externalId: ext_reference,
			   payer: {
			   	partyIdType: "MSISDN",
			   	partyId: phone_number
			  	},
			  	payerMessage: "SUPA 3",
			  	payeeNote: "SUPA 3"
			}

			req.body = request_body.to_json

			res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

			  http.request(req)

			end

			case res.code

			when '202'
				response = {}
				return response

			else
				response = {}
				return response	
			end

		end

		def self.payment_status(ext_reference)

			
		end

		def self.make_transfer(amount, ext_reference, phone_number )
			token = process_token
			if token
				url = "https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay" 
				sub_key  = "12e0c6ecfb5f4a4788f44bd1fc65f81c"
				callback_url = ""

				uri = URI(url)

				req = Net::HTTP::Post.new(uri)

				## Set the headers
				#set transactions callback url
				req['X-Callback-Url'] = callback_url

				#set the transaction reference
				req['X-Reference-Id'] = ext_reference

				#set Enviroment
				req['X-Target-Environment'] = ""

				#set content type
				req['Content-Type'] = "application/json"

				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@sub_key

				request_body = {
					amount: amount,
				   currency: "UGX",
				   externalId: ext_reference,
				   payer: {
				   	partyIdType: "MSISDN",
				   	partyId: phone_number
				  	},
				  	payerMessage: "SUPA 3",
				  	payeeNote: "SUPA 3"
				}

				req.body = request_body.to_json

				res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

				  http.request(req)

				end

				case res.code

				when '202'
					response = {}
					return response

				else
					response = {}
					return response	
				end
			end
			
		end

		def self.transfer_status(ext_reference)

			
		end

		def process_token
			api_user = ApiUser.last()
			if api_user
				#process the token and return the token
				api_id = api_user.api_id
				api_key  = api_user.api_key

				url = "https://sandbox.momodeveloper.mtn.com/collection/token/" 
				
				uri = URI(url)

				req = Net::HTTP::Post.new(uri)

				## Set the headers

				#set Authourization
				req['Authourization'] = Base64.strict_encode64("#{api_id}:#{api_key}")

				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@sub_key

				request_body = {
					
				}

				req.body = request_body.to_json

				res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

				  http.request(req)

				end

				case res.code

				when '200'
					return res.body['access_token']

				else
					return ''
				end
			else
				return ''
			end

		end

		def self.register_api_user(user_id)
			api_user = ApiUser.find_by(api_id: user_id)
			url = "https://sandbox.momodeveloper.mtn.com/v1_0/apiuser"
			uri = URI(url)

			req = Net::HTTP::Post.new(uri)

			#set the transaction reference
			req['X-Reference-Id'] = user_id

			#set content type
			req['Content-Type'] = "application/json"

			#set the subscription keys
			req['Ocp-Apim-Subscription-Key'] = @@sub_key

			request_body = {
				providerCallbackHost: "betcity.co.ug"
			}

			req.body = request_body.to_json

			res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

			  http.request(req)

			end

			case res.code

			when '201'
				api_user.update_attributes(registered: true)
				return true

			else
				return false	
			end

		end

		def self.receive_api_key(user_id)
			api_user = ApiUser.find_by(api_id: user_id)
			url = "https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/#{user_id}/apikey"
			uri = URI(url)

			req = Net::HTTP::Post.new(uri)


			#set the subscription keys
			req['Ocp-Apim-Subscription-Key'] = @@sub_key


			res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

			  http.request(req)

			end

			result = JSON.parse(res.body)

			case res.code

			when '201'
				api_key = result['apiKey']
				return api_key

			else
				return nil	
			end

		end
			
	end	
	
end