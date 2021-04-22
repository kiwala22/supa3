require 'rails_helper'
require 'sidekiq/testing'

def prediction_creation
  Gamer.create({
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone_number: "256786481312",
    supa3_segment: "A",
    supa5_segment: "B",
    network: "MTN"
  })
  gamer = Gamer.last.id

  probability = rand()
  tickets = rand(0.0..20.0)

  target = (tickets.to_f.round(2) + 3).to_i

  Prediction.create({
    tickets: tickets ,
    probability: probability,
    target: target,
    gamer_id: gamer,
    rewarded: "No"
  })
end

describe "Promotional SMS is sent", type: "request" do

  before(:each) do
    Gamer.skip_callback(:create, :after, :update_user_info)
  end

  after(:each) do
    Gamer.set_callback(:create, :after, :update_user_info)
  end

  it "if gamer has target still greater than tickets " do
    # First create the gamer and their corresponding prediction
    prediction_creation()

    expect{
      PromotionalSmsWorker.perform_async()
    }.to change(PromotionalSmsWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      PromotionalSmsWorker.drain
    end

    message = CGI.unescape(Message.last.message)

    name = Gamer.last.first_name
    target = Prediction.last.target

    puts message

    expect(message).to eq("#{name}, play #{target} tickets this week and get back an instant reward of 20% of amount played. Thank you for playing SUPA3.")

  end
end
