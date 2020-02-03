class AirtelCollectionWorker
	include Sidekiq::Worker
	sidekiq_options queue: "critical"
	sidekiq_options retry: false

	require 'openssl'
	require 'json'
	require 'uri'
	require 'net/http'
	require 'logger'

	@@logger ||= Logger.new("#{Rails.root}/log/mobile_money.log")
	@@logger.level = Logger::ERROR

	def perform(transaction_id)
    	@collection =  Collection.find_by(transaction_id: transaction_id)
    	TicketWorker.perform_async(@collection.phone_number,@collection.message, @collection.amount)
    rescue StandardError => e
  			@@logger.error(e.message)
    end
end
