class MtnCollectionWorker
	include Sidekiq::Worker
	sidekiq_options queue: "high"
	sidekiq_options retry: false

	def perform(transaction_id, ext_transaction_id, status)
    	@collection =  Collection.find_by(transaction_id: transaction_id) 
    	if @collection
    		@collection.update_attributes(status: status)
    		if status == 'SUCCESSFUL'
    			TicketWorker.perform_async(@collection.phone_number,@collection.message, @collection.amount)
    		end
    	end
end
