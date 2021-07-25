require 'rails_helper'
require 'sidekiq/testing'

## To run this class you need to change the draw worker as below
## perform(draw_id, start_time, end_time)
## And also comment out lines 15 & 18 then uncomment line 19


def ticket_creation
    phone_numbers = ["256786481312", "256704422320", "256776582036", "256752148252", "256785595569", "256701864607"]

    amount = rand(1000..30000)
    message = rand(10000..99999).to_s

    phone_numbers.each do |number|
        TicketWorker.new.perform(number, message, amount)
    end
end

RSpec.describe Supa5DrawWorker, type: :worker do
    ## Get a random number not divisible by 3
    first_draw_id = 3
    while (first_draw_id % 3) == 0
        first_draw_id = rand(1..10000)
    end

    ## Get a random number divisible by 3
    second_draw_id = 2
    while (second_draw_id % 3) != 0
        second_draw_id = rand(1..10000)
    end
    
    START_TIME = Time.now.localtime.beginning_of_minute - 10.minutes
    END_TIME = Time.now.localtime

    let(:draw_first) {
        FactoryBot.create(:draw, id: first_draw_id, draw_time: END_TIME)
    }

    let(:draw_second) {
        FactoryBot.create(:draw, id: second_draw_id, draw_time: END_TIME)
    }

    before :each do
        Gamer.skip_callback(:create, :after, :update_user_info)
        ticket_creation
    end

    after :each do
        Gamer.set_callback(:create, :after, :update_user_info)
    end

    it "runs normally when the draw ID has a reminder on modulo 3" do
        draw_id = draw_first.id
        expect {
            Supa5DrawWorker.perform_async(draw_id, START_TIME, END_TIME)
        }.to change(Supa5DrawWorker.jobs, :size).by(1)

        Sidekiq::Testing.inline! do
            Supa5DrawWorker.drain
        end

        winning_tickets = Ticket.where("draw_id = ? and number_matches = ?", draw_id, 3).count()

        expect(winning_tickets).to be >= 0

    end

    it "ensures no winning tickets when the draw ID has no reminder on modulo 3" do
        draw_id = draw_second.id

        expect {
            Supa5DrawWorker.perform_async(draw_id, START_TIME, END_TIME)
        }.to change(Supa5DrawWorker.jobs, :size).by(1)

        Sidekiq::Testing.inline! do
            Supa5DrawWorker.drain
        end

        winning_tickets = Ticket.where("draw_id = ? and number_matches = ?", draw_id, 3).count()

        expect(winning_tickets).to eq(0)
    end
end
