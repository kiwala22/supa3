require 'rails_helper'
require 'sidekiq/testing'

def prediction_creation
  Gamer.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, phone_number: "256703452234", supa3_segment: "A", supa5_segment: "B", network: "AIRTEL")
  gamer = Gamer.last.id

  probability = rand()
  tickets = rand(0.0..20.0)

  target = (tickets.to_f.round(2) + 3).to_i

  Prediction.create(tickets: tickets , probability: probability,  target: target, gamer_id: gamer, created_at: Date.today-12.days, updated_at: Date.today-12.days, rewarded: "No")
end

describe "Promotional SMS is sent", type: "request" do

  it "if gamer has target still greater than tickets " do
    # First create the gamer and their corresponding prediction
    prediction_creation()

    expect{
      PromotionalSmsWorker.perform_async()
    }.to change(PromotionalSmsWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      PromotionalSmsWorker.drain
    end
  end
end
