class Ticket < ApplicationRecord
   paginates_per 100
   belongs_to :gamer

   require "send_sms"
end
