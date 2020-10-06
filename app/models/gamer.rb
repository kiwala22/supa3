class Gamer < ApplicationRecord
   audited
   require "send_sms"
   require "mobile_money/mtn_ecw"

   validates :phone_number, uniqueness: true
   validates :phone_number, presence: true
   paginates_per 50

   has_many :tickets
   after_create :update_user_info
   #after_create :send_welcome_message

   def self.to_csv
      CSV.generate do |csv|
        column_names = %w(first_name last_name phone_number supa3_segment)
        csv << column_names
        all.each do |result|
          csv << result.attributes.values_at(*column_names)
        end
      end
    end

   #method to send a message to a new gamer
   private

   def update_user_info
      case self.phone_number
      when /^(25678|25677|25639)/
         #update info
         result = MobileMoney::MtnEcw.get_account_info(self.phone_number)
         if result
            self.update_attributes(first_name: result[:first_name], last_name: result[:surname])
         end

      when /^(25675|25670)/
         #update user info
      end
      #send welcome message
      message = "Welcome to SUPA3! Win up to 200x your amount every 10 minutes, 24hrs a day. Are you ready to get that Supa Feeling?"
      SendSMS.process_sms_now(transaction: true, receiver: self.phone_number, content: message, sender_id: ENV['DEFAULT_SENDER_ID'])

   end

   # def send_welcome_message
   #    message = "Dear #{self.first_name}, Welcome to SUPA3."
   #    SendSMS.process_sms_now(transaction: true, receiver: self.phone_number, content: message, sender_id: ENV['DEFAULT_SENDER_ID'])
   # end

end
