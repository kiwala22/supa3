class GamerWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  sidekiq_options retry: false

  def perform
    gamers = CSV.read("/tmp/gamers_supa3_update.csv")

    #gamers.shift

    gamers_arr = []

    gamers.each do |tb|
      gamers_arr << {phone_number: tb[1], created_at: tb[3]}
    end

    gamers_arr.each do |x|
      Gamer.create(phone_number: x[:phone_number], created_at: x[:created_at])
    end
  end
end
