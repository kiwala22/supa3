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
       if tickets.blank? && user.created_at < segment_check_time
         user.update_attributes(segment: "F")
       else
         #convert tickets and results to json
         payload = {'tickets' => tickets, 'results' => results}.to_json(:except => :id)
         #make request to AI server
         response = HTTParty.post(base_url, {body: payload ,headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}})
         result = JSON.parse(response.body)
         result = result["result"].round(2)
         segment = find_segment(result)
         user.update_attributes(segment: segment)
       end
    end

    def find_segment(result)
       case
       when result >= 0.80
         return "A"
       when result < 0.80 && result >= 0.60
         return "B"
       when result < 0.60 && result >= 0.40
         return "C"
       when result < 0.40 && result >= 0.20
         return "D"
       when result < 0.2
         return "E"
       else
         return "F"
       end
    end
 end
