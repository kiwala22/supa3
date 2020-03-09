class SentMessagesWorker
    include Sidekiq::Worker
    sidekiq_options queue: "low"
    sidekiq_options retry: false

    def perform
        start_time  = Date.today.prev_day.beginning_of_day
        stop_time   = Date.today.prev_day.end_of_day
        SentMessage.where('created_at >= ? and created_at <= ?', start_time, stop_time).find_each(batch_size: 100) do |f|
            if f.message.downcase.include?("your lucky numbers") && f.message.downcase.include?("ugx")
                ticket_amount = (f.message.scan(/UGX.[0-9]*/).join()[4..-1].to_i)/200
                message = f.message.split(" ")
                ticket_id = (message[message.index("ID:")+1]).gsub(".", "")
                Ticket.create(phone_number: f.to, amount: ticket_amount, reference: ticket_id, time: f.created_at)
            end
            if f.message.downcase.include?("matched 0")
                BetcityResult.create(phone_number: f.to, matches: 0, time: f.created_at)
            end
            if f.message.downcase.include?("matched 1")
                BetcityResult.create(phone_number: f.to, matches: 1, time: f.created_at)
            end
            if f.message.downcase.include?("matched 2")
                BetcityResult.create(phone_number: f.to, matches: 2, time: f.created_at)
            end
            if f.message.downcase.include?("matched 3")
                BetcityResult.create(phone_number: f.to, matches: 3, time: f.created_at)
            end
        end
    end
end
