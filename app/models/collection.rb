class Collection < ApplicationRecord
	audited
	validates :transaction_id, uniqueness: true
	validates :ext_transaction_id, uniqueness: true
	validates_length_of :phone_number, :is => 12, :message => "number should be 12 digits long."
	validates_format_of :phone_number, :with => /\A[256]/, :message => "number should start with 256."
	before_create :generate_references, on: [ :create ]

	require 'csv'

	def self.send_daily_report
		collections = Collection.where("created_at <= ? AND created_at >= ?", Date.yesterday.end_of_day, Date.yesterday.beginning_of_day)
		collection_csv = CSV.generate do |csv|
			csv << ["Id","Ext Transaction","Transaction","Currency","Amount","Phone Number","Status","Created At","Updated At","Network"]
			collections.each do |collection|
				csv << [ collection.id, collection.ext_transaction_id, collection.transaction_id, collection.currency, collection.amount, collection.phone_number, collection.status, collection.created_at, collection.updated_at, collection.network  ]
			end
		end

		#call the mailer for deivery
		CollectionsMailer.daily_report(collection_csv).deliver_now

	end

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
