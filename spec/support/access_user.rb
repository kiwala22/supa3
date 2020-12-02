require 'faker'

RSpec.shared_context 'Access User Creation' do

    before :each do
      create_access_user
    end


    def create_access_user
      AccessUser.create({
        first_name: Faker::Name.name,
        last_name: Faker::Name.name
        })
    end

  end
