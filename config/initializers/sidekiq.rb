require 'sidekiq'
require 'sidekiq/web'
require "sidekiq/throttled"
Sidekiq::Throttled.setup!

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["admin", "admin2013"]
end
