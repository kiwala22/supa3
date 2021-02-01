require 'rails_helper'
require 'sidekiq/testing'

def generate_random_data
  random_numbers = []
  while random_numbers.length != 3
     random_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
  end
  return random_numbers.join("")
end

def bonus_ticket_creation
  segment = 'A'
  expiry = Time.now + 5.minutes
  game = 'Supa3'
  BonusTicket.create({
    segment: segment,
    expiry: expiry,
    game: game
    })
end

describe "Bonus Ticket", type: "request" do
  it "is created successfully if Bonus Ticket Offer exists" do

    ##First create the Bonus Ticket Offer
    bonus_ticket_creation()

    ##Variables for ticket creation
    phone_number = "256786481312"
    amount = '1000'
    message = generate_random_data()

    expect {
      TicketWorker.perform_async(phone_number, message, amount)
    }.to change(TicketWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      TicketWorker.drain
    end
    reference_ticket_hash = Ticket.second_to_last.reference

    expect(Ticket.last.ticket_type).to eq("Bonus Ticket-##{reference_ticket_hash}")
  end

  it "is not created if Bonus Ticket Offer is non existent" do
    
    ##Variables for ticket creation
    phone_number = "256786481312"
    amount = '1000'
    message = generate_random_data()

    expect {
      TicketWorker.perform_async(phone_number, message, amount)
    }.to change(TicketWorker.jobs, :size).by(1)

    Sidekiq::Testing.inline! do
      TicketWorker.drain
    end

    # Represents that only one normal ticket was formed and no bonus ticket created
    expect(Ticket.last.ticket_type).to eq(nil)
  end
end
