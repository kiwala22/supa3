class AiSegmentPredictionWorker
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_throttle({
      :concurrency => { :limit => 15 }
    })

  sidekiq_options queue: "low"
  sidekiq_options retry: 3
  require "httparty"

  def perform(gamer_id)
    gamer = Gamer.find(gamer_id)

    base_url = "http://35.239.55.28/predict"

    tickets = gamer.tickets.select(:amount, :number_matches, :win_amount, :gamer_id, :created_at, :game).where("created_at >= ?", (Time.now - 90.days)).order("created_at DESC")

    ##Convert tickets to json
    payload = { 'tickets' => tickets }.to_json(:except => :id)

    ##Make request to AI server
    response = HTTParty.post(base_url, {body: payload ,headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}})

    result = JSON.parse(response.body)

    ##Results from AI server
    probability = result["probability"].round(2)
    tickets = result["tickets"].round(2)

    if probability < 0.4
      target = 0
      prediction = Prediction.create_with(tickets: tickets, probability: probability, target: target, gamer_id: gamer_id).find_or_create_by(gamer_id: gamer_id).update(tickets: tickets, probability: probability, target: target)
    end

    if probability >= 0.4
      target = find_target(tickets)
      prediction = Prediction.create_with(tickets: tickets, probability: probability, target: target, gamer_id: gamer_id).find_or_create_by(gamer_id: gamer_id).update(tickets: tickets, probability: probability, target: target)
    end

  end

  def find_target(tickets)
    target = (tickets + 3).round()

    return target
  end

end
