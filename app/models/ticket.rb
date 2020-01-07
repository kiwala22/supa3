class Ticket < ApplicationRecord
   paginates_per 100
   belongs_to :gamer
   require "send_sms"

   def self.to_csv
     attributes = %w{id first_name last_name phone_number reference created_at}

     CSV.generate(headers: true) do |csv|
       csv << attributes

       all.each do |ticket|
         csv << attributes.map{ |attr| ticket.send(attr) }
       end
     end
   end
end
