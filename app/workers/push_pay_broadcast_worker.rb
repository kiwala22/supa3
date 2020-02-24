class PushPayBroadcastWorker
	include Sidekiq::Worker
	sidekiq_options queue: "low"
	sidekiq_options retry: false

	require "mobile_money/mtn_ecw"
	require "mobile_money/airtel_uganda"

	def perform(broadcast_id, message)

	end
end
