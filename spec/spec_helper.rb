# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'
require 'capybara/rspec'
require 'capybara/email/rspec'
SimpleCov.start
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'shoulda/matchers'
require 'webmock/rspec'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Capybara::DSL

  config.before(:each) do
    stub_request(:any, /skylinesms.com/).
      to_return(status: 200, body: "Success", headers: {})

    stub_request(:any, /f5.mtn.co.ug/).
      to_return(status: "200", body: '{"status": "200", "ext_transaction_id": "36782873099"}', headers: {})

    stub_request(:any, /172.27.77.145/).
      to_return(status: "200", body: '{"status": "200", "ext_transaction_id": "36782873099"}', headers: {})

    prob = rand()
    tickets = rand(0.0..7.0)
    stub_request(:any, "http://35.239.55.28/predict").
      to_return(status: 200, body: %{{"probability": "#{prob}", "tickets": "#{tickets}"}}, headers: {})
  end

end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
