class Collection < ApplicationRecord
	validates :transaction_id, uniqueness: true
	before_create :generate_references, on: [ :create ]

	private
	def generate_references
		loop do
			transaction_id = SecureRandom.hex(10)
			break self.transaction_id = transaction_id unless Collection.where(transaction_id: transaction_id).exists?

		end

		loop do

			resource_id = SecureRandom.uuid
			break self.resource_id = resource_id unless Collection.where(resource_id: resource_id).exists?

		end
		
		
	end
end
