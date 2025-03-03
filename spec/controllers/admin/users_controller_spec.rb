require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin_user) { create(:user, admin: true) }
  let(:user) { create(:user) }

  before { sign_in admin_user }

  describe "GET #index" do
    before do
      create_list(:user, 3)
    end

    it "returns a list of all users" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(6) # admin_user + user + 3 created users
    end
  end

  describe "GET #show" do
    it "returns the requested user" do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["id"].to_i).to eq(user.id)
    end
  end

  describe "PUT #update" do
    let(:new_email) { "newemail@example.com" }

    it "updates the user" do
      put :update, params: {
        id: user.id,
        user: { email: new_email }
      }

      expect(response).to have_http_status(:ok)
      expect(user.reload.email).to eq(new_email)
    end

    it "returns errors for invalid attributes" do
      put :update, params: {
        id: user.id,
        user: { email: "" }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end
  end

  describe "POST #toggle_admin" do
    it "toggles admin status for a regular user" do
      expect {
        post :toggle_admin, params: { id: user.id }
      }.to change { user.reload.admin? }.from(false).to(true)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("User added to administrators")
    end

    it "toggles admin status for an admin user" do
      admin = create(:user, admin: true)

      expect {
        post :toggle_admin, params: { id: admin.id }
      }.to change { admin.reload.admin? }.from(true).to(false)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["message"]).to eq("User removed from administrators")
    end

    it "prevents toggling the last admin user" do
      # Try to remove admin status from the last admin
      post :toggle_admin, params: { id: admin_user.id }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(admin_user.reload.admin?).to be true
    end
  end
end
