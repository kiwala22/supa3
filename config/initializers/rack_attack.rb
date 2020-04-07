class Rack::Attack
  ### Throttle Spammy Clients ###
  # Throttle all requests by IP (60rpm)
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip # unless req.path.start_with?('/assets')
  end

  ### Prevent Brute-Force Login Attacks ###
  # Throttle POST requests to /login by IP address
  # For Admins
  throttle('admin logins/ip', limit: 5, period: 20.seconds) do |req|
   if req.path == '/squirrel/login' && req.post?
     req.ip
   end
 end

 # For Users
 throttle('user logins/ip', limit: 5, period: 20.seconds) do |req|
  if req.path == '/' && req.post?
    req.ip
  end
end

 # Throttle POST requests to /login by email param
 # For Admins
 throttle("admin logins/email", limit: 5, period: 20.seconds) do |req|
   if req.path == '/squirrel/login' && req.post?
     # return the email if present, nil otherwise
     req.params['email'].presence
   end
 end

 # For Users
 throttle("user logins/email", limit: 5, period: 20.seconds) do |req|
   if req.path == '/' && req.post?
     # return the email if present, nil otherwise
     req.params['email'].presence
   end
 end

 ### Prevent Brute-Force Login Attacks on Sidekiq Page
 # Throttle POST requests to /sidekiq by IP address
 throttle('sidekiq/ip', limit: 5, period: 20.seconds) do |req|
   if req.path == '/rabbit' && req.post?
     req.ip
   end
 end

 ### Custom Throttle Response ###
 # We make the attacker believe they broke us
 self.throttled_response = lambda do |env|
   [ 503, {}, ['SUCCESS']]
  end
end
