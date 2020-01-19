class GamerWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"
  sidekiq_options retry: false

  def perform
    gamers = CSV.read("/tmp/gamers_supa3.csv")

    #gamers.shift

    gamers_arr = []

    gamers.each do |tb|
      gamers_arr << {phone_number: tb[1], segment: tb[7]}
    end

    gamers_arr.each do |x|
      Gamer.create(phone_number: x[:phone_number], segment: x[:segment])
    end
  end
end
