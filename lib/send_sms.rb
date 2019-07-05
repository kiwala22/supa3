module SendSMS
   require 'net/http'
   require 'uri'
   require "cgi"
   require "httparty"

   def self.process_sms_now(receiver:, content:, sender_id: nil, args: {})

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

      message_url = "#{ENV['SMS_BASE_URL']}"+"#{message_params}"

      response = HTTParty.get(message_url)

      if response.code == 200
         return True
      else
         return False
      end

   end
end
