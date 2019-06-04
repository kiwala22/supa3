class SegmentPredictionWorker
   include Sidekiq::Worker
   require "httparty"
   def perform(phone_number)
      user = Gamer.find_by(phone_number: phone_number)
      base_url = "http://34.73.226.237/predict"
      time_limit = (Time.now - 90.days).to_i
      tickets = Ticket.where("phone_number = ? AND time >= ?", phone_number, time_limit)
      if tickets.blank?
         user.update_attributes(segment: "F")
      else
         #make request to AI server
         request_json = {'data' => tickets}.to_json
         response = HTTParty.post(base_url, {body: request_json,headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}})
         result = JSON.parse(response.body)
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
