class Collection < ApplicationRecord
	audited
	validates :transaction_id, uniqueness: true
	validates :ext_transaction_id, uniqueness: true
	validates_length_of :phone_number, :is => 12, :message => "number should be 12 digits long."
	validates_format_of :phone_number, :with => /\A[256]/, :message => "number should start with 256."
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
