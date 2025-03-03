class PricingCalculator
  INCH_FRACTION = 1.0/16.0

  def self.calculate_price(width:, height:, door_style:, finish:, glass_option: nil)
    new(
      width: width,
      height: height,
      door_style: door_style,
      finish: finish,
      glass_option: glass_option
    ).calculate_price
  end

  def initialize(width:, height:, door_style:, finish:, glass_option: nil)
    @width = width.to_f
    @height = height.to_f
    @door_style = door_style
    @finish = finish
    @glass_option = glass_option
  end

  def calculate_price
    (base_price + finish_price + glass_price).round(2)
  end

  private

  attr_reader :width, :height, :door_style, :finish, :glass_option

  def square_footage
    rounded_width = round_to_nearest_fraction(width)
    rounded_height = round_to_nearest_fraction(height)
    ((rounded_width * rounded_height) / 144.0).round(4) # Convert square inches to square feet
  end

  def round_to_nearest_fraction(dimension)
    ((dimension / INCH_FRACTION).ceil * INCH_FRACTION).round(4)
  end

  def base_price
    (door_style.base_price + (square_footage * door_style.price_per_sqft)).round(4)
  end

  def finish_price
    (square_footage * finish.price_per_sqft).round(4)
  end

  def glass_price
    return 0 unless glass_option
    (glass_option.base_price + (square_footage * glass_option.price_per_sqft)).round(4)
  end
end
