require 'rails_helper' # include in your RSpec file
require 'sidekiq/testing' #include in your Rspec file

RSpec.describe TicketWorker, type: :worker do
  describe 'ticket worker' do
    it "successfully creates a supa 5 ticket" do
      phone_number = "256786481312"
      amount = 1000
      message = "78230"
      expect do
        TicketWorker.perform_async(phone_number, message, amount)
      end.to change(TicketWorker.jobs, :size).by(1)
      TicketWorker.drain
    end

    it "successfully creates a supa 3 ticket" do
      phone_number = "256786481312"
      amount = 1000
      message = "780"
      expect do
        TicketWorker.perform_async(phone_number, message, amount)
      end.to change(TicketWorker.jobs, :size).by(1)
      TicketWorker.drain
    end
  end
end
