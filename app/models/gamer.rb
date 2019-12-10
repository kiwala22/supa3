class Gamer < ApplicationRecord

   require "send_sms"
   validates :phone_number, uniqueness: true
   validates :phone_number, presence: true
   paginates_per 50

   has_many :tickets
   after_create :send_welcome_message

   #method to send a message to a new gamer
   private
   def send_welcome_message
     message = "#{self.first_name}, Welcome to SUPA3."
     SendSMS.process_sms_now(transaction: true, receiver: self.phone_number, content: message, sender_id: ENV['DEFAULT_SENDER_ID'])
   end
end
