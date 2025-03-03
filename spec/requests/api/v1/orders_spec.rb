require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/orders/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/orders/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/orders/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/api/v1/orders/update"
      expect(response).to have_http_status(:success)
    end
  end

end
