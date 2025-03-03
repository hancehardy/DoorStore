require 'rails_helper'

RSpec.describe Admin::OrdersController, type: :controller do
  let(:admin_user) { create(:user, admin: true) }
  let(:order) { create(:order) }

  before { sign_in admin_user }

  describe "GET #index" do
    before do
      create_list(:order, 3)
    end

    it "returns a list of all orders" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"].length).to eq(3)
    end

    it "filters orders by status" do
      create(:order, status: "completed")
      get :index, params: { status: "completed" }
      expect(JSON.parse(response.body)["data"].length).to eq(1)
    end
  end

  describe "GET #show" do
    it "returns the requested order" do
      get :show, params: { id: order.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["id"].to_i).to eq(order.id)
    end
  end

  describe "PUT #update" do
    context "when order is not completed or cancelled" do
      let(:order) { create(:order, status: "pending") }

      it "updates the order" do
        put :update, params: {
          id: order.id,
          order: { shipping_method: "express" }
        }
        expect(response).to have_http_status(:ok)
        expect(order.reload.shipping_method).to eq("express")
      end

      it "sends an email notification" do
        expect {
          put :update, params: {
            id: order.id,
            order: { shipping_method: "express" }
          }
        }.to have_enqueued_mail(OrderMailer, :order_updated)
      end
    end

    context "when order is completed" do
      let(:order) { create(:order, status: "completed") }

      it "returns forbidden status" do
        put :update, params: {
          id: order.id,
          order: { shipping_method: "express" }
        }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST #process_refund" do
    let(:order) { create(:order, payment_intent_id: "pi_123") }

    it "processes a refund" do
      allow(RefundService).to receive(:process).and_return({ success: true })

      post :process_refund, params: {
        id: order.id,
        amount: 50.00,
        reason: "Customer request"
      }

      expect(response).to have_http_status(:ok)
      expect(RefundService).to have_received(:process).with(
        order: order,
        amount: "50.0",
        reason: "Customer request"
      )
    end

    it "handles refund failures" do
      allow(RefundService).to receive(:process).and_return({
        success: false,
        error: "Refund failed"
      })

      post :process_refund, params: {
        id: order.id,
        amount: 50.00,
        reason: "Customer request"
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["error"]).to eq("Refund failed")
    end
  end

  describe "POST #add_note" do
    it "adds an internal note to the order" do
      post :add_note, params: {
        id: order.id,
        content: "Test note"
      }

      expect(response).to have_http_status(:ok)
      expect(order.notes).to include("Test note")
    end
  end
end
