require 'net/http'
require 'securerandom'

def generate_random_data
   random_numbers = []
   while random_numbers.length != 3
        random_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
   end
   return random_numbers.join(" ")
end

50.times {
    uri = URI.parse("http://localhost:3000/tickets?")
     numbers = ["256776582036", "256752148252", "256792148252"]
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"phone_number" => numbers.sample, "data" => generate_random_data, "amount" => 1000})

    response = http.request(request)
}
