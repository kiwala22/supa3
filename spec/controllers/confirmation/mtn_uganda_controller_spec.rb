require 'rails_helper'

RSpec.describe "mtn confirmation", type: :request do

	describe "POST create" do
		it "returns status success for well formed request" do
				uri = URI.parse "http://localhost:3000/confirmation/mtn"
				xml = "<?xml version='1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>266</transactionid><accountholderid>ID:256776582036/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>275</message><extension/></ns4:paymentrequest>"
				request = Net::HTTP::Post.new uri
				request.body = xml
				request.content_type = 'application/xml'
				response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
				expect(response.code).to eq('200')

				#check response body
				result = Hash.from_xml(response.body)
				puts result
		end

		# it "returns failed for similar or duplicate EXT IDS" do
		# 	request.env['content_type'] = 'application/xml'
  # 			request.env['RAW_POST_DATA'] =  "<?xml version=1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>2637538</transactionid><accountholderid>ID:256779999719/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>256890, 8901</message><extension /></ns4:paymentrequest>"
  # 			post :create


		# end

		# it "returns failed for similar or duplicate INT IDS" do
		# 	request.env['content_type'] = 'application/xml'
  # 			request.env['RAW_POST_DATA'] =  "<?xml version=1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>2637538</transactionid><accountholderid>ID:256779999719/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>256890, 8901</message><extension /></ns4:paymentrequest>"
  # 			post :create

		# end

		# it  "returns failed for wrong formated phone number" do
		# 	request.env['content_type'] = 'application/xml'
  # 			request.env['RAW_POST_DATA'] =  "<?xml version=1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>2637538</transactionid><accountholderid>ID:256779999719/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>256890, 8901</message><extension /></ns4:paymentrequest>"
  # 			post :create

		# end

		# it "saves collection when response is received" do
		# 	request.env['content_type'] = 'application/xml'
  # 			request.env['RAW_POST_DATA'] =  "<?xml version=1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>2637538</transactionid><accountholderid>ID:256779999719/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>256890, 8901</message><extension /></ns4:paymentrequest>"
  # 			post :create

		# end

		# it "creates tickets successfully when response is received" do
		# 	request.env['content_type'] = 'application/xml'
  # 			request.env['RAW_POST_DATA'] =  "<?xml version=1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>2637538</transactionid><accountholderid>ID:256779999719/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>256890, 8901</message><extension /></ns4:paymentrequest>"
  # 			post :create

		# end

	end

end
