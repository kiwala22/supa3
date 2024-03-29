require 'rails_helper'

def login_form(email, password)
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Login"
end

describe "user sessions", type: :feature, js: true  do
    include_context 'User Sessions'
    

    it "fails on incorrect email address" do
        visit '/'
        login_form("fake@gmail.com", valid_user_params[:password])

        expect(page).to have_content("Invalid Email or password.")
    end

    it "fails on incorrect password" do
        visit '/'
        login_form(valid_user_params[:email], "fakepassword")

        expect(page).to have_content("Invalid Email or password.")
    end

    it "successfully logins on correct credentials" do
        visit '/'
        login_form(valid_user_params[:email], valid_user_params[:password])

        expect(page.current_path).to eq '/'
        expect(page).to have_content("Signed in successfully.")

        visit '/users/sign_out'
        expect(page).to have_content("Signed out successfully.")
        expect(page.current_path).to eq '/'
    end
end