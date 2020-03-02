class Ticket < ApplicationRecord
   audited
   paginates_per 100
   belongs_to :gamer
   require "send_sms"

   def self.to_csv
     CSV.generate do |csv|
       column_names = %w(first_name last_name phone_number reference data amount number_matches win_amount keyword created_at)
       csv << column_names
       all.each do |result|
         csv << result.attributes.values_at(*column_names)
       end
     end
   end
end
