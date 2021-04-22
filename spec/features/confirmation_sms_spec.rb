require 'rails_helper'
require 'sidekiq/testing'

def gamer_prediction_creation

  Gamer.create({
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    phone_number: "256786481312",
    supa3_segment: "A",
    supa5_segment: "A",
    network: "MTN"
  })

  gamer_id = Gamer.last.id

  probability = rand()
  tickets = rand(0.0..20.0)

  Prediction.create({
    tickets: tickets,
    probability: probability,
    target: 3,
    gamer_id: gamer_id,
    rewarded: "No"
  })

end

def gamer_creation
  # Gamer.skip_callback(:create, :after, :update_user_info)
  Gamer.create({
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      phone_number: "256786481312",
      supa3_segment: "A",
      supa5_segment: "A",
      network: "MTN"
  })
end

def generate_random_data
  random_numbers = []
  while random_numbers.length != 3
     random_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
  end
  return random_numbers.join("")
end

describe "Ticket Worker ", type: "request" do

  before(:each) do
    Gamer.skip_callback(:create, :after, :update_user_info)
  end

  after(:each) do
    Gamer.set_callback(:create, :after, :update_user_info)
  end

  ## Scenarion 1. When gamer has no prediction or has a target of 0 on the prediction

  it "gives gamer normal confirmation sms" do
    ## Create the gamer
    gamer_creation()

    ## Gamer plays ticket
    ##Variables for ticket creation
    phone_number = Gamer.last.phone_number
    amount = '1000'
    data = generate_random_data()

    expect {
      TicketWorker.perform_async(phone_number, data, amount)
    }.to change(TicketWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      TicketWorker.drain
    end

    confirmation_sms = CGI.unescape(Message.last.message)
    name = Gamer.last.first_name
    max_win = 200000
    reference = Ticket.last.reference
    draw_time = ((Time.now - (Time.now.min % 10).minutes).beginning_of_minute + 10.minutes).strftime("%I:%M %p")

    puts confirmation_sms

    expect(confirmation_sms).to eq("#{name}, Your lucky numbers: #{data} are entered in the next draw at #{draw_time}. You could win UGX.#{max_win}! Ticket ID: #{reference}. You have been entered into the Supa Jackpot. Thank you for playing SUPA3")

  end

  ## Scenario 2. When gamer has a prediction and has not yet hit the target but plays a ticket

  it "gives gamer a reminder through confirmation sms when target not hit yet" do
    ## Create the gamer and his/her prediction
    gamer_prediction_creation()

    ## Gamer plays ticket
    ##Variables for ticket creation
    phone_number = Gamer.last.phone_number
    amount = '1000'
    data = generate_random_data()

    expect {
      TicketWorker.perform_async(phone_number, data, amount)
    }.to change(TicketWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      TicketWorker.drain
    end

    confirmation_sms = CGI.unescape(Message.last.message)
    name = Gamer.last.first_name
    max_win = 200000
    reference = Ticket.last.reference
    number_of_week_tickets = Gamer.last.tickets.where("created_at >= ?", (Time.now.beginning_of_week)).count()
    target_check = (Gamer.last.prediction.target - number_of_week_tickets).to_i
    draw_time = ((Time.now - (Time.now.min % 10).minutes).beginning_of_minute + 10.minutes).strftime("%I:%M %p")

    puts confirmation_sms

    expect(confirmation_sms).to eq("#{name}, Your lucky numbers: #{data} are entered in the next draw at #{draw_time}. You could win UGX.#{max_win}! Ticket ID: #{reference}. Play #{target_check} more tickets to hit your weekly target and win a 20% bonus of amount played. Thank you for playing SUPA3")
  end

end
