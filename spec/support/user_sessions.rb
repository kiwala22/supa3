require 'faker'

RSpec.shared_context 'User Sessions' do
    before :each do
      authenticate
    end

    let(:valid_user_params) do
        {
            first_name: Faker::Name.name,
            last_name: Faker::Name.name,
            email: Faker::Internet.email,
            password: "password",
            password_confirmation: "password"
        }
    end
  
    def authenticate
        visit '/admin/login'

        fill_in "Email", with: "admin@example.com"
        fill_in "Password", with: "password"
        click_button "Login"
        
        visit "/admin/users"

        visit "/admin/users/new"

        fill_in "Email", with: valid_user_params[:email]
        fill_in "First name", with: valid_user_params[:first_name]
        fill_in "Last name", with: valid_user_params[:last_name]
        fill_in "Password", with: valid_user_params[:password]
        fill_in "Confirmation", with: valid_user_params[:password_confirmation]

        click_button "Create User" 

        visit '/admin/logout'
    end
  end


  