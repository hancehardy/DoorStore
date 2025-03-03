require 'rails_helper'

RSpec.describe Admin::ProductsController, type: :controller do
  let(:admin_user) { create(:user, admin: true) }
  let(:product) { create(:product) }

  before { sign_in admin_user }

  describe "GET #index" do
    before do
      create_list(:product, 3)
    end

    it "returns a list of all products" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(3)
    end
  end

  describe "GET #show" do
    it "returns the requested product" do
      get :show, params: { id: product.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["id"].to_i).to eq(product.id)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        name: "New Door Style",
        description: "A beautiful door style",
        base_price: 199.99,
        price_per_sqft: 15.00,
        product_type: "door_style",
        active: true,
        min_width: 8.0,
        max_width: 48.0,
        min_height: 8.0,
        max_height: 96.0,
        specifications: {
          material: "wood",
          construction: "5-piece",
          panel_style: "recessed"
        }
      }
    end

    it "creates a new product" do
      expect {
        post :create, params: { product: valid_attributes }
      }.to change(Product, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(Product.last.name).to eq("New Door Style")
    end

    it "returns errors for invalid attributes" do
      post :create, params: { product: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end
  end

  describe "PUT #update" do
    let(:new_attributes) do
      {
        name: "Updated Door Style",
        base_price: 299.99,
        price_per_sqft: 20.00
      }
    end

    it "updates the product" do
      put :update, params: {
        id: product.id,
        product: new_attributes
      }

      expect(response).to have_http_status(:ok)
      product.reload
      expect(product.name).to eq("Updated Door Style")
      expect(product.base_price).to eq(299.99)
      expect(product.price_per_sqft).to eq(20.00)
    end

    it "returns errors for invalid attributes" do
      put :update, params: {
        id: product.id,
        product: { name: "" }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)).to have_key("errors")
    end
  end

  describe "DELETE #destroy" do
    it "destroys the product" do
      product = create(:product)

      expect {
        delete :destroy, params: { id: product.id }
      }.to change(Product, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
