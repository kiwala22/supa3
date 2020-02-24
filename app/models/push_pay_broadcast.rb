class PushPayBroadcast < ApplicationRecord
   audited
   attr_accessor :list, :message
   validates :phone_number, :amount, presence: true
   paginates_per 50
end
