module SendSMS
   require 'net/http'
   require 'uri'
   require "cgi"
   require "httparty"

   def self.process_sms_now(transaction: true, receiver:, content:, sender_id: nil, args: {})

      if args[:append_to].present?
         content = content+args[:append_to]
      end

      content = CGI.escape(content)
      parameters = []
      parameters << "to=#{receiver}" if receiver.present?
      parameters << "message=#{content}" if content.present?
      parameters << "from=#{sender_id}" if sender_id.present?

      if transaction == true
         parameters << "token=#{ENV['GAME_SMS_API_TOKEN']}"
         message_params = parameters.join("&")
         message_url = "#{ENV['SMS_BASE_URL']}"+"#{message_params}"
         #save message as a game message
         Message.create(to: receiver, from: sender_id, message: content, sms_type: "Game")
      end
      if transaction == false
         parameters << "token=#{ENV['BULK_SMS_API_TOKEN']}"
         message_params = parameters.join("&")
         message_url = "#{ENV['SMS_BULK_URL']}"+"#{message_params}"
         #save message as a broadcast message
         Message.create(to: receiver, from: sender_id, message: content, sms_type: "Broadcast")
      end

      ##use net http
      uri = URI(message_url)
      request = Net::HTTP::Get.new(uri)
      response  = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
      end

      if response.code == '200'
         return true
      else
         return false
      end
   rescue StandardError => e
      Rails.logger.error(e.message)
      false
   end
end
