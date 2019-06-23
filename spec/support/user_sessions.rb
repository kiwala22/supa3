require 'faker'

RSpec.shared_context 'User Sessions' do
    before :each do
      authenticate
    end

    let(:valid_manager_params) do
        {
            username: Faker::Name.name,
            email: Faker::Internet.email,
            phone_number: "256786481312",
            password: "password",
            password_confirmation: "password"
        }
    end
  
    def authenticate
        visit '/admin/login'

        fill_in "Email", with: "admin@example.com"
        fill_in "Password", with: "password"
        click_button "Login"
        
        visit "/admin/managers"

        visit "/admin/managers/new"

        fill_in "Email", with: valid_manager_params[:email]
        fill_in "Username", with: valid_manager_params[:username]

        fill_in "Phone number", with: valid_manager_params[:phone_number]
        fill_in "Password", with: valid_manager_params[:password]
        fill_in "Confirmation", with: valid_manager_params[:password_confirmation]

        click_button "Create Manager" 

        visit '/admin/logout'
    end
  end


  