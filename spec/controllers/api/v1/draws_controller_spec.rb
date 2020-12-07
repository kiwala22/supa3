require 'rails_helper'

RSpec.describe Api::V1::DrawsController, type: 'request' do

  include_context 'Create Draws'
  include_context 'Access User Creation'

  describe "GET api/v1/draws" do

    it "successfully returns draws when both IP and Token are correct" do
      token = AccessUser.last.token
      get "/api/v1/draws?token=#{token}"

      expect(response).to have_http_status(200)
      result = JSON.parse(response.body)
      expect(result["supa3"].length).to eq(10)
      expect(result["supa5"].length).to eq(10)

    end

    it "fails when wrong user Token has been passed" do
      token = "xxxxxxxxxxxxxxxx"
      get "/api/v1/draws?token=#{token}"

      expect(response).to have_http_status(200)
      result = JSON.parse(response.body)
      expect(result["status"]).to eq("Unauthorized. Invalid token.")
    end

    # it "fails when request is coming from Unauthorized IP Address" do
    #
    # end

  end

end
