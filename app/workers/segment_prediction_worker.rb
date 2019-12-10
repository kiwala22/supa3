class SegmentPredictionWorker
    include Sidekiq::Worker
    sidekiq_options queue: "low"
    sidekiq_options retry: 3
    require "httparty"

    def perform(id)
       user = Gamer.find(id)
       base_url = "http://167.71.136.242/predict"
       time_limit = (Time.now - 90.days)
       segment_check_time = (Time.now - 30.days)
       tickets = Ticket.select("phone_number, amount, time").where("phone_number = ? and time >= ?", user.phone_number, time_limit).order(time: :desc) # do not use select, just pull all of them, and simply remove unwanted columns
       results = Result.select("phone_number, matches, time").where("phone_number = ? and time >= ?", user.phone_number, time_limit).order(time: :desc) # same as above since not indexed
       bulk = Bulk.select("phone_number, time").where("phone_number = ? and time >= ?", user.phone_number, time_limit).order(time: :desc)
       if tickets.blank? && user.created_at < segment_check_time
         user.update_attributes(segment: "F", predicted_revenue: 0)
       else
         #convert tickets and results to json
         payload = {'tickets' => tickets, 'results' => results, 'bulk' => bulk}.to_json(:except => :id)
         #make request to AI server
         response = HTTParty.post(base_url, {body: payload ,headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}})
         result = JSON.parse(response.body)
         probability = result["probability"].round(2)
         revenue = (result["revenue"]).to_i
         segment = find_segment(probability)
         user.update_attributes(segment: segment, predicted_revenue: revenue)
       end
    end

    def find_segment(probability)
       case
       when probability >= 0.80
         return "A"
       when probability < 0.80 && probability >= 0.60
         return "B"
       when probability < 0.60 && probability >= 0.40
         return "C"
       when probability < 0.40 && probability >= 0.20
         return "D"
       when probability < 0.2
         return "E"
       else
         return "F"
       end
    end
 end
