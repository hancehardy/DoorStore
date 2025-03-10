require 'rails_helper'

RSpec.describe "Api::V1::Products", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api/v1/products/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/api/v1/products/show"
      expect(response).to have_http_status(:success)
    end
  end

end
