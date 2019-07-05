class YoPayments

	require 'openssl'
	require 'json'
	require 'httparty'
	require "base64"

	@@url = "https://paymentsapi1.yo.co.ug/ybs/task.php"
  @@api_username = "100888662547"
  @@api_password = "WhN3-z9ox-b6p6-su2a-QKNr-Uvax-DOXW-VYj5"


	def self.make_deposit(phone_number, amount, payment_reference, loans='True')
		if loans = 'True'
			narrative = "Loan #{payment_reference} payment to SkySente"
		else
			narrative = "Deposit from SkySente"
		end
		yo_transaction = YoTransaction.new(recipient: phone_number, amount: amount, reference: payment_reference, narration: narrative, status: "PENDING")
		yo_transaction.save
		xml = "<?xml version='1.0' encoding='UTF-8'?><AutoCreate><Request><APIUsername>#{@@api_username}</APIUsername><APIPassword>#{@@api_password}</APIPassword><Method>acdepositfunds</Method><Amount>#{amount}</Amount><Account>#{phone_number}</Account><Narrative>#{narrative}</Narrative><ExternalReference>#{payment_reference}</ExternalReference><ProviderReferenceText>Thank you for using Skyline SMS</ProviderReferenceText></Request></AutoCreate>"

		uri = URI.parse(@@url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        request.content_type = 'text/xml'
        request.body = xml
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.request(request)
        result = Hash.from_xml(response.body)

        if result["AutoCreate"]["Response"]["Status"] == "OK" && result["AutoCreate"]["Response"]["TransactionStatus"] == "SUCCEEDED"
					yo_transaction.update_attributes(status: "SUCCESS")
					response = {status: "SUCCESS", message: "SUCCESS", reference: result[:TransactionReference]  }
					response

        else
					yo_transaction.update_attributes(status: "FAILED")
					response = {status: "FAILED", message: "FAILED", reference: result[:TransactionReference]  }
					response
        end


	end

	def self.collect_payment(phone_number, amount, payment_reference, loans='True')
		if loans = 'True'
			narrative = "Loan #{payment_reference} repayment to SkySente"
		else
			narrative = "Withdraw request from SkySente"
		end
		yo_transaction = YoTransaction.new(recipient: phone_number, amount: amount, reference: payment_reference, narration: narrative,status: "PENDING")
		yo_transaction.save
		xml = "<?xml version='1.0' encoding='UTF-8'?><AutoCreate><Request><APIUsername>#{@@api_username}</APIUsername><APIPassword>#{@@api_password}</APIPassword><Method>acwithdrawfunds</Method><Amount>#{amount}</Amount><Account>#{phone_number}</Account><Narrative>#{narrative}</Narrative><ExternalReference>#{payment_reference}</ExternalReference><ProviderReferenceText>Thank you for using Skyline SMS</ProviderReferenceText></Request></AutoCreate>"


		uri = URI.parse(@@url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri)
        request.content_type = 'text/xml'
        request.body = xml
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.request(request)
        result = Hash.from_xml(response.body)

        if result["AutoCreate"]["Response"]["Status"] == "OK" && result["AutoCreate"]["Response"]["TransactionStatus"] == "SUCCEEDED"
					yo_transaction.update_attributes(status: "SUCCESS")
					response = {status: "SUCCESS", message: "SUCCESS", reference: result[:TransactionReference]  }
					response

        else
					yo_transaction.update_attributes(status: "FAILED")
        	response = {status: "FAILED", message: "FAILED", reference: result[:TransactionReference]  }
					response

        end


	end


	def self.decode_signature(signature)
      decoded_signature = Base64.decode64(signature)
      certificate =    OpenSSL::X509::Certificate.new(File.read(Rails.root.join("public/certificate.pem")))
      return string
  end


end
