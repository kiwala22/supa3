require 'rails_helper'
require 'sidekiq/testing'


def last_3_months_gamer
#create a gamer and tickets that were played in the last 3 months
  Gamer.create(first_name:Faker::Name.first_name, last_name:Faker::Name.last_name, phone_number:"256703452234", supa3_segment:"A", supa5_segment:"B", network:"AIRTEL")
  gamer = Gamer.last.id
  4.times do |index|
   Ticket.create({
    phone_number: "256703452234", amount: 1000, time: Date.today-(12+index).days,
     number_matches: 2, gamer_id: gamer, win_amount: 200, paid: true,
     data: "214", network:"AIRTEL", confirmation: true,
     first_name: Gamer.last.first_name, last_name: Gamer.last.last_name,
     winning_number:"941",  game: "supa3", supa3_segment:"A", supa5_segment:"B",
     created_at: Date.today-(12+index).days, updated_at: Date.today-(12+index).days
     })
   Prediction.create(tickets: 0.37 , probability: 0.58,  target: 10,
     gamer_id:gamer, created_at: Date.today-12.days, updated_at: Date.today-12.days, rewarded: "Yes")
 end
end

def last_3_months_non_gamer
  #create a gamer and tickets that were played more than 3 months back.
  Gamer.create(first_name:Faker::Name.first_name, last_name:Faker::Name.last_name, phone_number:"256703452234", supa3_segment:"A", supa5_segment:"B", network:"AIRTEL")
  gamer = Gamer.last.id
  2.times do |index|
     Ticket.create({
      phone_number: "256703452234", amount: 1000, time: Date.today-(12+index).days,
       number_matches: 2, gamer_id: gamer, win_amount: 200, paid: true,
       data: "396", network:"AIRTEL", confirmation: true,
       first_name: Gamer.last.first_name, last_name: Gamer.last.last_name,
       winning_number:"943",  game: "supa3", supa3_segment:"A",
       supa5_segment:"B", created_at: Date.today-(100+index).days,
       updated_at: Date.today-(100+index).days
       })
    end
  end

describe "AI-Segment Prediction", type: "request" do

  it "is created successfully if a Gamer exists and has played in the last 3-Months" do

    last_3_months_gamer()
    gamer = Gamer.last.id

    expect{
      AiPredictionWorker.perform_async()
    }.to change(AiPredictionWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      AiPredictionWorker.drain
    end

    puts("Process Completed")
    expect(Prediction.count).to eq(1)
    expect(Prediction.last.target).to be > 0
    expect(Prediction.last.probability).to be > 0.4
  end

  it "is not created if A Gamer hasnt Played in the last 3-Months" do
  
    last_3_months_non_gamer()  
    gamer = Gamer.last.id  

    expect{
      AiPredictionWorker.perform_async()
    }.to change(AiPredictionWorker.jobs, :size).by(1)
  
    Sidekiq::Testing.inline! do
      AiPredictionWorker.drain
    end
  
    expect(Prediction.count).to eq(1)
    expect(Prediction.last.target).to eq(0)
    expect(Prediction.last.probability).to eq(0)
    expect(Prediction.last.tickets).to eq(0)
  
    puts("Success")
  end

end
