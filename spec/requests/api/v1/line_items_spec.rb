require 'rails_helper'

RSpec.describe 'API V1 Line Items', type: :request do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }
  let(:door_style) { create(:product, :door_style) }
  let(:finish) { create(:product, :finish) }
  let(:glass) { create(:product, :glass) }

  before do
    sign_in user
  end

  describe 'POST /api/v1/orders/:order_id/line_items' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          line_item: {
            product_id: door_style.id,
            quantity: 1,
            width: 24.0,
            height: 30.0,
            finish: finish.name
          }
        }
      end

      it 'creates a line item with correct pricing' do
        post "/api/v1/orders/#{order.id}/line_items", params: valid_params
        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        line_item = json['data']['attributes']

        # Square footage: (24 * 30) / 144 = 5 sq ft
        # Base price: 100 + (5 * 15) = 175
        # Finish price: 5 * 5 = 25
        # Total per unit: 175 + 25 = 200
        # Total price: 200 * 1 = 200
        expect(line_item['price_per_unit'].to_f).to eq(200.00)
        expect(line_item['total_price'].to_f).to eq(200.00)
      end

      it 'calculates price with glass option' do
        params_with_glass = valid_params.deep_merge(
          line_item: { glass_option: glass.name }
        )

        post "/api/v1/orders/#{order.id}/line_items", params: params_with_glass
        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        line_item = json['data']['attributes']

        # Square footage: (24 * 30) / 144 = 5 sq ft
        # Base price: 100 + (5 * 15) = 175
        # Finish price: 5 * 5 = 25
        # Glass price: 50 + (5 * 20) = 150
        # Total per unit: 175 + 25 + 150 = 350
        # Total price: 350 * 1 = 350
        expect(line_item['price_per_unit'].to_f).to eq(350.00)
        expect(line_item['total_price'].to_f).to eq(350.00)
      end

      it 'calculates price for multiple quantity' do
        params_with_quantity = valid_params.deep_merge(
          line_item: { quantity: 3 }
        )

        post "/api/v1/orders/#{order.id}/line_items", params: params_with_quantity
        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        line_item = json['data']['attributes']

        # Price per unit: 200
        # Total price: 200 * 3 = 600
        expect(line_item['price_per_unit'].to_f).to eq(200.00)
        expect(line_item['total_price'].to_f).to eq(600.00)
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing finish' do
        post "/api/v1/orders/#{order.id}/line_items", params: {
          line_item: {
            product_id: door_style.id,
            quantity: 1,
            width: 24.0,
            height: 30.0
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to have_key('price_per_unit')
      end

      it 'returns error for invalid dimensions' do
        invalid_params = {
          line_item: {
            product_id: door_style.id,
            quantity: 1,
            width: 4.0, # Below minimum
            height: 30.0,
            finish: finish.name
          }
        }

        post "/api/v1/orders/#{order.id}/line_items", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['errors']).to have_key('width')
      end

      it 'returns error for invalid glass option' do
        invalid_params = {
          line_item: {
            product_id: door_style.id,
            quantity: 1,
            width: 24.0,
            height: 30.0,
            finish: finish.name,
            glass_option: 'Invalid Glass'
          }
        }

        post "/api/v1/orders/#{order.id}/line_items", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['errors']).to have_key('glass_option')
      end
    end
  end

  describe 'PATCH /api/v1/orders/:order_id/line_items/:id' do
    let!(:line_item) { create(:line_item, order: order, product: door_style, finish: finish.name) }

    it 'updates price when dimensions change' do
      patch "/api/v1/orders/#{order.id}/line_items/#{line_item.id}", params: {
        line_item: {
          width: 36.0,
          height: 36.0
        }
      }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      updated_item = json['data']['attributes']

      # Square footage: (36 * 36) / 144 = 9 sq ft
      # Base price: 100 + (9 * 15) = 235
      # Finish price: 9 * 5 = 45
      # Total per unit: 235 + 45 = 280
      expect(updated_item['price_per_unit'].to_f).to eq(280.00)
      expect(updated_item['total_price'].to_f).to eq(280.00)
    end

    it 'updates price when adding glass option' do
      patch "/api/v1/orders/#{order.id}/line_items/#{line_item.id}", params: {
        line_item: {
          glass_option: glass.name
        }
      }
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      updated_item = json['data']['attributes']

      # Square footage: (24 * 30) / 144 = 5 sq ft
      # Base price: 100 + (5 * 15) = 175
      # Finish price: 5 * 5 = 25
      # Glass price: 50 + (5 * 20) = 150
      # Total per unit: 175 + 25 + 150 = 350
      expect(updated_item['price_per_unit'].to_f).to eq(350.00)
      expect(updated_item['total_price'].to_f).to eq(350.00)
    end
  end
end
