require 'rails_helper'
require 'sidekiq/testing'

def gamer_prediction_creation

  Gamer.create({
    first_name:"KYASI",
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

# def gamer_tickets_creation(gamer_id)
#   2.times {
#     Ticket.create({
#
#       })
#   }
# end


def generate_random_data
  random_numbers = []
  while random_numbers.length != 3
     random_numbers = SecureRandom.hex(50).scan(/\d/).uniq.sample(3).map(&:to_i)
  end
  return random_numbers.join("")
end


describe "Ticket Worker" do
  before(:each) do
    Gamer.skip_callback(:create, :after, :update_user_info)
  end

  after(:each) do
    Gamer.set_callback(:create, :after, :update_user_info)
  end

  ## Scenario gamer receives a reward on hitting prediction target

  it "processes reward for gamer on hitting prediction target" do

    ## Create the gamer and the corresponding prediction
    gamer_prediction_creation()

    ##Variables for ticket creation
    phone_number = Gamer.last.phone_number
    amount = '1000'

    ## Since gamer has prediction target of 3, we create 3 tickets inorder to hit the target
    3.times do
      data = generate_random_data()
      TicketWorker.perform_async(phone_number, data, amount)

      Sidekiq::Testing.inline! do
        TicketWorker.drain
      end
    end

    # expect(RewardDisbursementWorker.jobs.size).to eq(1)

    ## expect gamer prediction to have rewarded "Yes"
    # expect(Prediction.last.rewarded).to eq("Yes")

  end
end
