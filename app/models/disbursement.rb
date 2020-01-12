class Disbursement < ApplicationRecord
	validates :transaction_id, uniqueness: true
	before_create :generate_references, on: [ :create ]

	private
	def generate_references
		loop do
			transaction_id = SecureRandom.hex(10)
			break self.transaction_id = transaction_id unless Disbursement.where(transaction_id: transaction_id).exists?

		end
		
	end
end
