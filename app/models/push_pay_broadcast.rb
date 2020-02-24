class PushPayBroadcast < ApplicationRecord
   audited

   validates :phone_number, :amount, presence: true
   paginates_per 50

end
