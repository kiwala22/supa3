require 'rails_helper'

RSpec.describe "mtn confirmation", type: :request do

	describe "POST create" do
		it "returns status success for well formed request and saves collection" do
				uri = URI.parse "http://localhost:3000/confirmation/mtn"
				id = rand(1..100000000)
				ext_id = id.to_i
				xml = "<?xml version='1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>#{ext_id}</transactionid><accountholderid>ID:256776582036/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>275</message><extension/></ns4:paymentrequest>"
				request = Net::HTTP::Post.new uri
				request.body = xml
				request.content_type = 'application/xml'
				expect {
					response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
				}.to change(Collection, :count).by(1)
				expect(response.code).to eq('200')
		end

		it "returns failed for similar or duplicate EXT IDS" do
			#find an already existing external ID in the DB
			existing_id = (Collection.last.ext_transaction_id).to_i
			uri = URI.parse "http://localhost:3000/confirmation/mtn"
			xml = "<?xml version='1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>#{existing_id}</transactionid><accountholderid>ID:256776582036/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>275</message><extension/></ns4:paymentrequest>"
			request = Net::HTTP::Post.new uri
			request.body = xml
			request.content_type = 'application/xml'
			expect {
				response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
			}.to change(Collection, :count).by(0)
			expect(response.code).to eq('200')
		end


		it  "returns failed for wrong formated phone number" do
			uri = URI.parse "http://localhost:3000/confirmation/mtn"
			id = rand(1..100000000)
			ext_id = id.to_i
			xml = "<?xml version='1.0' encoding='UTF-8'?><ns4:paymentrequest xmlns:ns4='http://www.ericsson.com/em/emm//serviceprovider/v1_0/backend'><transactionid>#{ext_id}</transactionid><accountholderid>ID:0776582036/MSISDN</accountholderid><receivingfri>FRI:l1pbr18000001554@stanflexy.sp1/SP</receivingfri><amount><amount>15000.00</amount><currency>UGX</currency></amount><message>275</message><extension/></ns4:paymentrequest>"
			request = Net::HTTP::Post.new uri
			request.body = xml
			request.content_type = 'application/xml'
			expect {
				response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
			}.to change(Collection, :count).by(0)
			expect(response.code).to eq('200')
		end
	end
end
