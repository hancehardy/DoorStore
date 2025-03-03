require 'rails_helper'

RSpec.describe "Api::V1::Health", type: :request do
  describe "GET /api/v1/health/check" do
    it "returns a successful health check response" do
      get "/api/v1/health/check"

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response["status"]).to eq("ok")
      expect(json_response["timestamp"]).to be_present
    end
  end
end
