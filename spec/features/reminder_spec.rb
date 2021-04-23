require 'rails_helper'
require 'sidekiq/testing'

def generate_random_data
  random_numbers = []
  while random_numbers.length != 3
     random_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
  end
  return random_numbers.join("")
end

def last_week_gamer
  #create a gamer and tickets that were played more than 3 months back.
  Gamer.create(first_name:Faker::Name.first_name, last_name:Faker::Name.last_name, 
    phone_number:"256703452234", supa3_segment:"A", supa5_segment:"B", network:"AIRTEL")

  gamer = Gamer.last.id
  probability = rand(0.4..1.0)
  tickets = rand(0.0..20.0)
  data = generate_random_data()

  Prediction.create(tickets: tickets , probability: probability,  target: 3, gamer_id:gamer, rewarded: "No")
  2.times do |index|
     Ticket.create({
      phone_number: "256703452234", amount: 1000, time: Date.today-(8+index).days,
       number_matches: 2, gamer_id: gamer, win_amount: 0, paid: false,
       data: data, network:"AIRTEL", confirmation: true,
       first_name: Gamer.last.first_name, last_name: Gamer.last.last_name,
       winning_number:"943",  game: "supa3", supa3_segment:"A",
       supa5_segment:"B", created_at: Date.today-(8+index).days,
       updated_at: Date.today-(8+index).days
       })
    end
  end

describe "Reminder", type: "request" do

  it "is successfully sent to a gamer that has not played this week." do

    last_week_gamer()
    gamer = Gamer.last
    target = Prediction.last.target

    expect{
      RemindersWorker.perform_async(gamer.id, target)
    }.to change(RemindersWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      RemindersWorker.drain
    end

    sleep(2)

    reminder_sms = CGI.unescape(Message.last.message)

    message = ", Reminder to hit your target of #{target} ticketsthis week to win a bonus of 20% amount played. You have not yet played any tickets this week. Thank you for playing #{ENV['GAME']}"

    expect(reminder_sms).to have(gamer.first_name + message)
   
    puts("Process Completed")
  end


end
