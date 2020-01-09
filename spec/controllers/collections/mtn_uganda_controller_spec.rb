require 'rails_helper'

RSpec.describe Collections::MtnUgandaController, type: :controller do

  describe "GET #collect" do
    it "returns http success" do
      get :collect
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #collection_confirmation" do
    it "returns http success" do
      get :collection_confirmation
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #payout" do
    it "returns http success" do
      get :payout
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #payout_confirmation" do
    it "returns http success" do
      get :payout_confirmation
      expect(response).to have_http_status(:success)
    end
  end

end
