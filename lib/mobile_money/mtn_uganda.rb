module MobileMoney
	class MtnOpenApi

		require 'openssl'
		require 'json'
		require 'uri'
		require 'net/http'

		@@collection_sub_key  = "12e0c6ecfb5f4a4788f44bd1fc65f81c"
		@@transfer_sub_key= "53e3bdbf26a747469dde718aa722689c"
		@@collection_user_id = ApiUser.where(user_type: "collections").last.api_id
		@@transfer_user_id = ApiUser.where(user_type: "transfer").last.api_id

		def self.request_payments(amount, ext_reference, phone_number )
			token = process_request_token(@@collection_user_id)
			if token
				url = "https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay" 
				callback_url = "http://betcity.co.ug"

				uri = URI(url)

				req = Net::HTTP::Post.new(uri)

				## Set the headers
				#set token
				req['Authorization'] = "Bearer #{token}"

				#set transactions callback url
				req['X-Callback-Url'""] = callback_url

				#set the transaction reference
				req['X-Reference-Id'] = ext_reference

				#set Enviroment
				req['X-Target-Environment'] = "sandbox"

				#set content type
				req['Content-Type'] = "application/json"

				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@collection_sub_key

				request_body = {
					amount: amount,
				   currency: "EUR",
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

				return res.code
			else
				return nil
			end

		end

		def self.check_collection_status(ext_reference)
			token = process_request_token(@@collection_user_id)
			if token
				url = "https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay/#{ext_reference}" 

				uri = URI(url)

				req = Net::HTTP::Get.new(uri)

				## Set the headers
				#set token
				req['Authorization'] = "Bearer #{token}"

				#set Enviroment
				req['X-Target-Environment'] = "sandbox"

				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@collection_sub_key

				res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

				  http.request(req)

				end
				result = JSON.parse(res.body)
				return result
			else
				return nil
			end
			
		end

		def self.check_collections_balance
			token = process_request_token(@@collection_user_id)
			if token
				url = "https://sandbox.momodeveloper.mtn.com/collection/v1_0/account/balance" 

				uri = URI(url)

				req = Net::HTTP::Get.new(uri)

				## Set the headers
				#set token
				req['Authorization'] = "Bearer #{token}"

				#set Enviroment
				req['X-Target-Environment'] = "sandbox"

				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@collection_sub_key


				res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

				  http.request(req)

				end
				result = JSON.parse(res.body)
				return result
			else
				return nil
			end
		end

		def self.make_transfer(amount, ext_reference, phone_number )
			token = process_transfer_token(@@transfer_user_id)
			if token
				url = "https://sandbox.momodeveloper.mtn.com/disbursement/v1_0/transfer" 
				callback_url = "http://betcity.co.ug"

				uri = URI(url)

				req = Net::HTTP::Post.new(uri)

				## Set the headers
				#set token
				req['Authorization'] = "Bearer #{token}"

				#set transactions callback url
				req['X-Callback-Url'] = callback_url

				#set the transaction reference
				req['X-Reference-Id'] = ext_reference

				#set Enviroment
				req['X-Target-Environment'] = "sandbox"

				#set content type
				req['Content-Type'] = "application/json"

				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@transfer_sub_key

				request_body = {
					amount: amount,
				   currency: "EUR",
				   externalId: ext_reference,
				   payee: {
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

				return res.code
				p res

			else
				return nil
			end
			
		end

		def self.check_transfer_status(ext_reference)
			token = process_request_token(@@transfer_user_id)
			if token
				url = "https://sandbox.momodeveloper.mtn.com/disbursement/v1_0/transfer/#{ext_reference}" 

				uri = URI(url)

				req = Net::HTTP::Get.new(uri)

				## Set the headers
				#set token
				req['Authorization'] = "Bearer #{token}"

				#set Enviroment
				req['X-Target-Environment'] = "sandbox"

				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@transfer_sub_key


				res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

				  http.request(req)

				end
				result = JSON.parse(res.body)
				return result
			else
				return nil
			end
			
		end

		def self.check_disbursement_balance
			token = process_transfer_token(@@collection_user_id)
			if token
				url = "https://sandbox.momodeveloper.mtn.com/disbursement/v1_0/account/balance" 

				uri = URI(url)

				req = Net::HTTP::Get.new(uri)

				## Set the headers
				#set token
				req['Authorization'] = "Bearer #{token}"

				#set Enviroment
				req['X-Target-Environment'] = "sandbox"

				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@transfer_sub_key


				res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

				  http.request(req)

				end
				result = JSON.parse(res.body)
				return result
			else
				return nil
			end
		end

		def self.process_request_token(user_id)
			api_user = ApiUser.find_by(api_id: user_id)
			if api_user
				#process the token and return the token
				api_id = api_user.api_id
				api_key  = api_user.api_key

				url = "https://sandbox.momodeveloper.mtn.com/collection/token/" 
				
				uri = URI(url)

				req = Net::HTTP::Post.new(uri)

				## Set the headers

				#set Authourization
				req['Authourization'] = req.basic_auth(api_id, api_key)
		
				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@collection_sub_key
				
				res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

				  http.request(req)

				end
				result = JSON.parse(res.body)
				p result
				case res.code

				when '200'
					return result['access_token']

				else
					return nil
				end
			else
				return nil
			end

		end

		def self.process_transfer_token(user_id)
			api_user = ApiUser.find_by(api_id: user_id)
			if api_user
				#process the token and return the token
				api_id = api_user.api_id
				api_key  = api_user.api_key

				url = "https://sandbox.momodeveloper.mtn.com/disbursement/token/" 
				
				uri = URI(url)

				req = Net::HTTP::Post.new(uri)

				## Set the headers

				#set Authourization
				req['Authourization'] = req.basic_auth(api_id, api_key)
		
				#set the subscription keys
				req['Ocp-Apim-Subscription-Key'] = @@transfer_sub_key
				
				res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') do |http|

				  http.request(req)

				end
				result = JSON.parse(res.body)
				p result
				case res.code

				when '200'
					return result['access_token']

				else
					return nil
				end
			else
				return nil
			end

		end

		def self.register_api_user(user_id)
			api_user = ApiUser.find_by(api_id: user_id)
			if api_user.user_type == 'collections'
				sub_key = @@collection_sub_key
			end
			if api_user.user_type == 'transfer'
				sub_key = @@transfer_sub_key
			end
			url = "https://sandbox.momodeveloper.mtn.com/v1_0/apiuser"
			uri = URI(url)

			req = Net::HTTP::Post.new(uri)

			#set the transaction reference
			req['X-Reference-Id'] = user_id

			#set content type
			req['Content-Type'] = "application/json"

			#set the subscription keys
			req['Ocp-Apim-Subscription-Key'] = sub_key

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
			if api_user.user_type == 'collections'
				sub_key = @@collection_sub_key
			end
			if api_user.user_type == 'transfer'
				sub_key = @@transfer_sub_key
			end
			api_user = ApiUser.find_by(api_id: user_id)
			url = "https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/#{user_id}/apikey"
			uri = URI(url)

			req = Net::HTTP::Post.new(uri)


			#set the subscription keys
			req['Ocp-Apim-Subscription-Key'] = sub_key


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