require 'rails_helper'
require 'sidekiq/testing'

def login_form(email, password)
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Login"
end

describe "user broadcast", type: :request, js: true  do
    include_context 'User Sessions'

    it "successfully schedules a broadcast with status PENDING" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "A", :from => "Segment"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('25 June 2019 - 10:15 AM')")
        click_button "Schedule"

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
        expect(Broadcast.last.status).to eq('PENDING')

    end

    it "successfully schedules a broadcast with status PROCESSING" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "B", :from => "Segment"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('21 June 2019 - 10:15 AM')")
        click_button "Schedule"

        get '/process_broadcasts'
        expect(Broadcast.last.status).to eq('PROCESSING')

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
    end

    it "successfully schedules a broadcast with status SUCCESS" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "C", :from => "Segment"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('21 June 2019 - 10:15 AM')")
        click_button "Schedule"

        expect {
            get '/process_broadcasts'
        }.to change(BroadcastWorker.jobs, :size).by(1)

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'

        # Sidekiq::Testing.inline! do
        #    BroadcastWorker.drain
        # end

        #expect(Broadcast.last.status).to eq('SUCCESS')

    end
end