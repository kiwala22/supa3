class Gamer < ApplicationRecord

   validates :phone_number, uniqueness: true
   validates :phone_number, presence: true
   paginates_per 50
end
