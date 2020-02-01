class UpdateTicketsWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  sidekiq_options retry: false

  def perform
    tickets = CSV.read("/tmp/tickets_supa3.csv")

    tickets_arr = []
    tickets.each do |ticket|
      tickets_arr << {phone_number: ticket[0], amount: ticket[1], time: ticket[2]}
    end

    tickets_arr.each do |t|
      @gamer = Gamer.find_or_create_by(phone_number: t[:phone_number])
      Ticket.create(phone_number: t[:phone_number], amount: t[:amount], time: t[:time], gamer_id: @gamer.id)
    end
  end
end
