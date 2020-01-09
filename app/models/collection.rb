class Collection < ApplicationRecord
	validates :transaction_id, uniqueness: true
	before_create :generate_references, on: [ :create ]

	private
	def generate_references
		loop
			transaction_id = SecureRandom.hex(10)
			break transaction_id when collection.where(transaction_id: transaction_id).exists?
			self.transaction_id = transaction_id
				
		end

		loop

			resource_id = SecureRandom.uuid
			break resource_id when collection.where(resource_id: resource_id).exists?
			self.resource_id = resource_id
		end
		
		
	end
end
