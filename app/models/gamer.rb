class Gamer < ApplicationRecord

   require "send_sms"
   require "mobile_money/mtn_ecw"

   validates :phone_number, uniqueness: true
   validates :phone_number, presence: true
   paginates_per 50

   has_many :tickets
   after_create :update_user_info
   #after_create :send_welcome_message

   #method to send a message to a new gamer
   private

   def update_user_info
      case self.phone_number
      when /^(25678|25677|25639)/
         #update info
         result = MobileMoney.Ecw.get_account_info(self.phone_number)
         if result
            self.update_attributes(first_name: result[:first_name], last_name: result[:surname])
         end

      when /^(25675|25670)/
         #update user info
      end
      #send welcome message
      message = "Dear #{self.first_name}, Welcome to SUPA3."
      SendSMS.process_sms_now(transaction: true, receiver: self.phone_number, content: message, sender_id: ENV['DEFAULT_SENDER_ID'])

   end

   # def send_welcome_message
   #    message = "Dear #{self.first_name}, Welcome to SUPA3."
   #    SendSMS.process_sms_now(transaction: true, receiver: self.phone_number, content: message, sender_id: ENV['DEFAULT_SENDER_ID'])
   # end

end
