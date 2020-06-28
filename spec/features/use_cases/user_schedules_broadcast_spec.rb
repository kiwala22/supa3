require 'rails_helper'
require 'sidekiq/testing'

def login_form(email, password)
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Login"
end


describe "user broadcast", type: :request, js: true  do
    include_context 'User Sessions'

    it "successfully schedules a Supa3 segment broadcast for all networks with status PENDING" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "SUPA 3", from: "game"
        select "Segments", from: "selector"
        find('a[id="add_user_lists"]').click
        2.times {
          check((('A'..'F').to_a).sample(1).join())
        }
        select "ALL", from: "network"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('25 June 2021 - 10:15 AM')")
        click_button "Schedule"

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
        expect(Broadcast.last.status).to eq('PENDING')
    end

    it "successfully schedules a Supa5 segment broadcast for all networks with status PENDING" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "SUPA 5", from: "game"
        select "Segments", from: "selector"
        find('a[id="add_user_lists"]').click
        2.times {
          check((('A'..'F').to_a).sample(1).join())
        }
        select "ALL", from: "network"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('25 June 2021 - 10:15 AM')")
        click_button "Schedule"

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
        expect(Broadcast.last.status).to eq('PENDING')
    end

    it "successfully schedules a Supa3 segment broadcast for MTN with status PENDING" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "SUPA 3", from: "game"
        select "Segments", from: "selector"
        find('a[id="add_user_lists"]').click
        2.times {
          check((('A'..'F').to_a).sample(1).join())
        }
        select "MTN", from: "network"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('25 June 2021 - 10:15 AM')")
        click_button "Schedule"

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
        expect(Broadcast.last.status).to eq('PENDING')
    end

    it "successfully schedules a Supa5 segment broadcast for AIRTEL with status PENDING" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "SUPA 5", from: "game"
        select "Segments", from: "selector"
        find('a[id="add_user_lists"]').click
        2.times {
          check((('A'..'F').to_a).sample(1).join())
        }
        select "AIRTEL", from: "network"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('25 June 2021 - 10:15 AM')")
        click_button "Schedule"

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
        expect(Broadcast.last.status).to eq('PENDING')
    end


    it "successfully schedules a Supa5 segment broadcast for all networks with status SUCCESS" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "SUPA 5", from: "game"
        select "Segments", from: "selector"
        find('a[id="add_user_lists"]').click
        2.times {
          check((('A'..'F').to_a).sample(1).join())
        }
        select "ALL", from: "network"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('25 June 2021 - 10:15 AM')")
        click_button "Schedule"

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
        expect(Broadcast.last.status).to eq('PENDING')

        expect {
          BroadcastWorker.perform_async(Broadcast.last.id)
        }.to change(BroadcastWorker.jobs, :size).by(1)

        Sidekiq::Testing.inline! do
          BroadcastWorker.drain
        end
        expect(Broadcast.last.status).to eq('SUCCESS')
    end

    it "successfully schedules a Supa3 segment broadcast for MTN with status SUCCESS" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "SUPA 3", from: "game"
        select "Segments", from: "selector"
        find('a[id="add_user_lists"]').click
        2.times {
          check((('A'..'F').to_a).sample(1).join())
        }
        select "MTN", from: "network"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('25 June 2021 - 10:15 AM')")
        click_button "Schedule"

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
        expect(Broadcast.last.status).to eq('PENDING')

        expect {
          BroadcastWorker.perform_async(Broadcast.last.id)
        }.to change(BroadcastWorker.jobs, :size).by(1)

        Sidekiq::Testing.inline! do
          BroadcastWorker.drain
        end
        expect(Broadcast.last.status).to eq('SUCCESS')
    end

    it "successfully schedules a Supa5 segment broadcast for AIRTEL with status SUCCESS" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/broadcasts/new'
        select "SUPA 5", from: "game"
        select "Segments", from: "selector"
        find('a[id="add_user_lists"]').click
        2.times {
          check((('A'..'F').to_a).sample(1).join())
        }
        select "AIRTEL", from: "network"
        fill_in "broadcast_compose_message", with: 'This is to test the broadcast'
        page.execute_script("$('#broadcast_schedule').val('25 June 2021 - 10:15 AM')")
        click_button "Schedule"

        expect(page).to have_content('Broadcast Successful. Processing.....')
        expect(page.current_path).to eq '/broadcasts'
        expect(Broadcast.last.status).to eq('PENDING')

        expect {
          BroadcastWorker.perform_async(Broadcast.last.id)
        }.to change(BroadcastWorker.jobs, :size).by(1)

        Sidekiq::Testing.inline! do
          BroadcastWorker.drain
        end
        expect(Broadcast.last.status).to eq('SUCCESS')
    end
end
