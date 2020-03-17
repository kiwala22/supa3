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
		file_name =  "/var/www/html/supa_ai/shared/public/reports/collections-#{Date.yesterday.strftime('%d-%m-%Y')}.csv"
		pp file_name
		CSV.open(file_name, 'w') do |csv|
			csv << ["Id","Ext Transaction","Transaction","Currency","Amount","Phone Number","Status","Created At","Updated At","Network"]
			collections.each do |collection|
				csv << [ collection.id, collection.ext_transaction_id, collection.transaction_id, collection.currency, collection.amount, collection.phone_number, collection.status, collection.created_at, collection.updated_at, collection.network  ]
			end
		end

		Report.create(file_name: file_name.split("/").last , file_path: file_name)

	end

	def self.to_csv
		CSV.generate do |csv|
			column_names = %w(ext_transaction_id transaction_id currency amount phone_number status message created_at updated_at network)
			csv << column_names
			all.each do |result|
				csv << result.attributes.values_at(*column_names)
			end
		end
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
