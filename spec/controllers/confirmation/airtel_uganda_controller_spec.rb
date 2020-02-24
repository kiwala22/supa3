require 'rails_helper'

RSpec.describe Confirmation::AirtelUgandaController, type: :controller do
	describe "POST create" do
		it "returns status success for well formed request and saves collection" do
			uri = URI.parse "http://localhost:3000/confirmation/airtel"
			ext_id = (rand(1..100000000)).to_i
			xml = "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>STANPAY</TYPE><MOBTXNID>#{ext_id}</MOBTXNID><AMOUNT>15000</AMOUNT><REFERENCE>845</REFERENCE><BILLERCODE>TESTME</BILLERCODE><USERNAME>skyline</USERNAME><PASSWORD>skyline</PASSWORD><MSISDN>256704422320</MSISDN></COMMAND>"
			request = Net::HTTP::Post.new uri
			request.body = xml
			request.content_type = 'application/xml'
			expect {
				@@response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
			}.to change(Collection, :count).by(1)
			result = Hash.from_xml(@@response.body)
			expect(response.code).to eq('200')
			expect(result['COMMAND']['TXNSTATUS']).to eq('200')
			expect(result['COMMAND']['MESSAGE']).to eq("Transaction is successful")
		end

		it "returns failed for similar or duplicate EXT IDS" do
			uri = URI.parse "http://localhost:3000/confirmation/airtel"
			ext_id = Collection.last.ext_transaction_id
			xml = "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>STANPAY</TYPE><MOBTXNID>#{ext_id}</MOBTXNID><AMOUNT>15000</AMOUNT><REFERENCE>845</REFERENCE><BILLERCODE>TESTME</BILLERCODE><USERNAME>skyline</USERNAME><PASSWORD>skyline</PASSWORD><MSISDN>256704422320</MSISDN></COMMAND>"
			request = Net::HTTP::Post.new uri
			request.body = xml
			request.content_type = 'application/xml'
			expect {
				@@response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
			}.to change(Collection, :count).by(0)
			result = Hash.from_xml(@@response.body)
			expect(response.code).to eq('200')
			expect(result['COMMAND']['TXNSTATUS']).to eq('200')
			expect(result['COMMAND']['MESSAGE']).to eq("Transaction is successful")
		end
		#
		# it "returns failed for similar or duplicate INT IDS" do
		#
		# end
		#
		# it  "returns failed for wrong formated phone number" do
		# 	uri = URI.parse "http://localhost:3000/confirmation/airtel"
		# 	ext_id = (rand(1..100000000)).to_i
		# 	xml = "<?xml version='1.0' encoding='UTF-8'?><COMMAND><TYPE>STANPAY</TYPE><MOBTXNID>#{ext_id}</MOBTXNID><AMOUNT>15000</AMOUNT><REFERENCE>845</REFERENCE><BILLERCODE>TESTME</BILLERCODE><USERNAME>skyline</USERNAME><PASSWORD>skyline</PASSWORD><MSISDN>04422320</MSISDN></COMMAND>"
		# 	request = Net::HTTP::Post.new uri
		# 	request.body = xml
		# 	request.content_type = 'application/xml'
		# 	expect {
		# 		@@response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request request }
		# 	}.to change(Collection, :count).by(0)
		# 	result = Hash.from_xml(@@response.body)
		# 	expect(response.code).to eq('200')
		# 	expect(result['COMMAND']['TXNSTATUS']).to eq('400')
		# 	expect(result['COMMAND']['MESSAGE']).to eq("Transaction has failed")
		# end

		# it "returns status success for well formed merchant push request and saves collection" do
		# 	uri = URI.parse "http://localhost:3000/confirmation/airtel"
		#
		# end
	end
end
