class Payment < ApplicationRecord
   audited

   validates :phone_number, :amount, presence: true
   attr_accessor :list
   paginates_per 50

end
