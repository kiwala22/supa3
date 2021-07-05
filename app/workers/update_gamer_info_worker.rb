class UpdateGamerInfoWorker
   include Sidekiq::Worker
   include Sidekiq::Throttled::Worker

   sidekiq_throttle({
       # Allow maximum 10 concurrent jobs of this class at a time.
       :concurrency => { :limit => 10 }
     })

   sidekiq_options queue: "low"
   sidekiq_options retry: false

   require "mobile_money/mtn_ecw"

   def perform(gamer_id)
    ## Find the gamer to be updated
    gamer = Gamer.find(gamer_id)

    ## First update gamer names and network
    gamer.update_attributes(network: "AIRTEL")
    # result = MobileMoney::MtnEcw.get_account_info(gamer.phone_number)
    # if result
    #   gamer.update_attributes(network: "AIRTEL", first_name: result[:first_name], last_name: result[:surname])
    # end

    ## Find all gamer tickets and update network field
    tickets = gamer.tickets.update_all(network: "Airtel Uganda")

    ## Find gamer pending Disbursements and process re-payments for them
    Disbursement.where("phone_number = ? and status = ?", gamer.phone_number, "PENDING").each do |payment|
      RepaymentWorker.perform_async(gamer_id, payment.amount)
    end

   end
end
