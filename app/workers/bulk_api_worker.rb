class BulkApiWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"
  sidekiq_options retry: false
  require 'net/http'
  require 'uri'
  require "cgi"
  require "httparty"

  def perform(sender_id, phone_number, content)
  end
end
