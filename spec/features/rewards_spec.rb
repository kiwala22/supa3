require 'rails_helper'
require 'sidekiq/testing'


def this_week_gamer
#create a gamer and tickets that were played in the last 3 months
  Gamer.create(first_name:Faker::Name.first_name, last_name:Faker::Name.last_name, phone_number:"256703452234", supa3_segment:"A", supa5_segment:"B", network:"AIRTEL")
  gamer = Gamer.last.id

  Prediction.create(tickets: 0.37 , probability: 0.58,  target: 10, gamer_id:gamer, created_at: Date.today-1.days, updated_at: Date.today-1.days, rewarded: "No")
  4.times do |index|
   Ticket.create({
    phone_number: "256703452234", amount: 1000, time: Date.today-(12+index).days,
     number_matches: 2, gamer_id: gamer, win_amount: 200, paid: true,
     data: "214", network:"AIRTEL", confirmation: true,
     first_name: Gamer.last.first_name, last_name: Gamer.last.last_name,
     winning_number:"941",  game: "supa3", supa3_segment:"A", supa5_segment:"B",
     created_at: Date.today-(index).days, updated_at: Date.today-(index).days
     })


 end
end

def last_week_gamer
  #create a gamer and tickets that were played more than 3 months back.
  Gamer.create(first_name:Faker::Name.first_name, last_name:Faker::Name.last_name, phone_number:"256703452234", supa3_segment:"A", supa5_segment:"B", network:"AIRTEL")
  gamer = Gamer.last.id

  Prediction.create(tickets: 0.37 , probability: 0.58,  target: 10, gamer_id:gamer, created_at: Date.today-8.days, updated_at: Date.today-8.days, rewarded: "No")
  2.times do |index|
     Ticket.create({
      phone_number: "256703452234", amount: 1000, time: Date.today-(8+index).days,
       number_matches: 2, gamer_id: gamer, win_amount: 200, paid: true,
       data: "396", network:"AIRTEL", confirmation: true,
       first_name: Gamer.last.first_name, last_name: Gamer.last.last_name,
       winning_number:"943",  game: "supa3", supa3_segment:"A",
       supa5_segment:"B", created_at: Date.today-(8+index).days,
       updated_at: Date.today-(8+index).days
       })
    end
  end

describe "Reward", type: "request" do

  it "is successful if a gamer played this week." do

    this_week_gamer()
    gamer = Gamer.last.id

    expect{
      RewardsWorker.perform_async(gamer)
    }.to change(RewardsWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      RewardsWorker.drain
    end

    sleep(2)
    expect(Disbursement.count).to eq(1)
    expect(Disbursement.last.message).to be("Reward")
    expect(Prediction.last.rewarded).to be("Yes")
    puts("Process Completed")
  end

  it "is not successful if A Gamer hasnt Played this week" do

    last_week_gamer()
    gamer = Gamer.last.id

    expect{
      RewardsWorker.perform_async(gamer)
    }.to change(RewardsWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      RewardsWorker.drain
    end

    expect(Disbursement.count).to eq(0)
    expect(Prediction.last.rewarded).to be("No")


    puts("Success")
  end

end
