require 'rails_helper'

RSpec.describe PricingCalculator do
  let(:door_style) { create(:product, :door_style) }
  let(:finish) { create(:product, :finish) }
  let(:glass) { create(:product, :glass) }

  describe '#calculate_price' do
    it 'rounds dimensions to 2 decimal places' do
      calculator = PricingCalculator.new(
        width: 24.123,
        height: 30.456,
        door_style: door_style,
        finish: finish
      )

      expect(calculator.calculate_price).to be_within(0.1).of(202.22)
    end

    it 'includes glass pricing' do
      calculator = PricingCalculator.new(
        width: 24.0,
        height: 30.0,
        door_style: door_style,
        finish: finish,
        glass_option: glass
      )

      expect(calculator.calculate_price).to be_within(0.1).of(350.00)
    end

    it 'calculates price for small doors using minimum square footage of 1' do
      calculator = PricingCalculator.new(
        width: 10.0,
        height: 10.0,
        door_style: door_style,
        finish: finish
      )

      expect(calculator.calculate_price).to be_within(0.1).of(113.89)
    end
  end

  describe '#round_to_nearest_fraction' do
    let(:calculator) { described_class.new(width: 24, height: 30, door_style: door_style, finish: finish) }

    it 'rounds dimensions up to the nearest 1/16 inch' do
      # Test private method
      result = calculator.send(:round_to_nearest_fraction, 24.1)
      expect(result).to eq(24.125) # 24 2/16"

      result = calculator.send(:round_to_nearest_fraction, 30.05)
      expect(result).to eq(30.0625) # 30 1/16"

      result = calculator.send(:round_to_nearest_fraction, 48.999)
      expect(result).to eq(49.0) # 49"
    end
  end
end
