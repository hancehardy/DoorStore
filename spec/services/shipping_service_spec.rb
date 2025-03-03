require 'rails_helper'

RSpec.describe ShippingService do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }
  let(:door_style) { create(:product, :door_style) }
  let!(:line_item) { create(:line_item, order: order, product: door_style, quantity: 2) }
  let(:to_zip) { '90210' }

  describe '.calculate_rates' do
    context 'in development/test environment' do
      it 'returns simulated shipping rates' do
        rates = ShippingService.calculate_rates(order: order, to_zip: to_zip)

        expect(rates).to be_an(Array)
        expect(rates.length).to eq(4)

        ground_rate = rates.find { |r| r[:service] == 'Ground' }
        expect(ground_rate).to include(
          carrier: 'UPS',
          rate: 75.00,
          total_days: ShippingService::PRODUCTION_DAYS + 5
        )
      end

      it 'calculates correct delivery dates' do
        rates = ShippingService.calculate_rates(order: order, to_zip: to_zip)
        ground_rate = rates.find { |r| r[:service] == 'Ground' }

        production_end_date = ShippingService::PRODUCTION_DAYS.business_days.from_now
        expected_delivery = 5.business_days.after(production_end_date)

        expect(ground_rate[:delivery_date].to_date).to eq(expected_delivery.to_date)
      end
    end

    context 'in production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        allow_any_instance_of(ActiveShipping::UPS).to receive(:find_rates).and_return(
          double(
            rates: [
              double(
                service_name: 'Ground',
                total_price: 7500,
                delivery_range_end: 5
              ),
              double(
                service_name: '2nd Day Air',
                total_price: 12500,
                delivery_range_end: 2
              )
            ]
          )
        )
      end

      it 'fetches real shipping rates from UPS' do
        rates = ShippingService.calculate_rates(order: order, to_zip: to_zip)

        expect(rates).to be_an(Array)
        expect(rates.length).to eq(2)

        ground_rate = rates.find { |r| r[:service] == 'Ground' }
        expect(ground_rate).to include(
          carrier: 'UPS',
          rate: 75.00,
          total_days: ShippingService::PRODUCTION_DAYS + 5
        )
      end
    end

    context 'with API errors' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
        allow_any_instance_of(ActiveShipping::UPS).to receive(:find_rates).and_raise(
          ActiveShipping::ResponseError.new('API Error')
        )
      end

      it 'handles shipping API errors gracefully' do
        result = ShippingService.calculate_rates(order: order, to_zip: to_zip)

        expect(result).to include(error: 'Unable to calculate shipping rates at this time.')
      end
    end
  end

  describe 'package calculations' do
    it 'calculates correct package weight based on line items' do
      service = ShippingService.new(order, to_zip)
      packages = service.send(:build_packages)

      expect(packages.length).to eq(1)
      expect(packages.first.ounces).to eq(40 * 16) # 2 doors * 20 lbs * 16 oz/lb
    end
  end
end
