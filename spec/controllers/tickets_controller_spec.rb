require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe "TicketsController", type: 'request' do
    Sidekiq::Worker.clear_all

    it "receives tickets information and return status 200" do
        expect {
            phone_number = "256786481312"
            data = "123"
            amount = 2000
            post "/tickets?phone_number=#{phone_number}&data=#{data}&amount=#{amount}"
        }.to change(TicketWorker.jobs, :size).by(1)

        expect(response).to have_http_status(200)
    end

    it "returns status 400 on any blank field" do
        expect {
            phone_number = "256786481312"
            data = "123"
            amount = 2000
            post "/tickets?phone_number=#{phone_number}&data=#{data}"
        }.to change(TicketWorker.jobs, :size).by(0)
        
        expect(response).to have_http_status(200)
    end
end