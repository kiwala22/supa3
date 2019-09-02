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
      parameters << "token=#{ENV['SMS_API_TOKEN']}"

      message_params = parameters.join("&")

      if transaction = true
        message_url = "#{ENV['SMS_BASE_URL']}"+"#{message_params}"
        #save message as a game message
        Message.create(to: receiver, from: sender_id, message: content, type: "Game")
      end
      if transaction = false
        message_url = "#{ENV['SMS_BULK_URL']}"+"#{message_params}"
        #save message as a broadcast message
        Message.create(to: receiver, from: sender_id, message: content, type: "Broadcast")
      end
      response = HTTParty.get(message_url)

      if response.code == 200
         return true
      else
         return false
      end

   end
end
