require 'rails_helper'

RSpec.describe Admin::BaseController, type: :controller do
  controller(Admin::BaseController) do
    def index
      render json: { message: "Success" }
    end
  end

  let(:user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }

  describe "authentication" do
    context "when no user is logged in" do
      it "returns unauthorized" do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when a non-admin user is logged in" do
      before { sign_in user }

      it "returns forbidden" do
        get :index
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["error"]).to eq("You are not authorized to access this area.")
      end
    end

    context "when an admin user is logged in" do
      before { sign_in admin_user }

      it "allows access" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("Success")
      end
    end
  end
end
