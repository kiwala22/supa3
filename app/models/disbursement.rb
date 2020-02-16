class Disbursement < ApplicationRecord
	audited
	validates :transaction_id, uniqueness: true
	before_create :generate_references, on: [ :create ]
	require 'csv'

	def self.send_daily_report
		disbursements = Disbursement.where("created_at <= ? AND created_at >= ?", Date.yesterday.end_of_day, Date.yesterday.beginning_of_day)
		disbursement_csv = CSV.generate do |csv|
			csv << ["Id","Ext Transaction","Transaction","Currency","Amount","Phone Number","Status","Created At","Updated At","Network"]
			disbursements.each do |disbursement|
				csv << [ disbursement.id, disbursement.ext_transaction_id, disbursement.transaction_id, disbursement.currency, disbursement.amount, disbursement.phone_number, disbursement.status, disbursement.created_at, disbursement.updated_at, disbursement.network  ]
			end
		end

		#call the mailer for deivery
		DisbursementsMailer.daily_report(disbursement_csv).deliver_now
	end

	private
	def generate_references
		loop do
			transaction_id = SecureRandom.hex(10)
			break self.transaction_id = transaction_id unless Disbursement.where(transaction_id: transaction_id).exists?

		end

	end
end
