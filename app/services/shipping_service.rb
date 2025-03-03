class ShippingService
  PRODUCTION_DAYS = 14 # 2 weeks for production
  SHIPPING_METHODS = {
    "ground" => { carrier: "UPS", service: "Ground" },
    "three_day" => { carrier: "UPS", service: "3 Day Select" },
    "two_day" => { carrier: "UPS", service: "2nd Day Air" },
    "next_day" => { carrier: "UPS", service: "Next Day Air" }
  }

  def self.calculate_rates(order:, to_zip:)
    new(order, to_zip).calculate_rates
  end

  def initialize(order, to_zip)
    @order = order
    @to_zip = to_zip
    @from_location = ActiveShipping::Location.new(
      country: "US",
      state: "CA",
      city: "Los Angeles",
      zip: "90012"
    )
    @to_location = ActiveShipping::Location.new(
      country: "US",
      zip: @to_zip
    )
  end

  def calculate_rates
    begin
      packages = build_packages
      rates = fetch_rates(packages)
      format_rates(rates)
    rescue ActiveShipping::ResponseError => e
      handle_shipping_error(e)
    rescue => e
      handle_generic_error(e)
    end
  end

  private

  def build_packages
    # Calculate total weight based on line items
    # For this example, we'll use a fixed weight per door
    total_weight = @order.line_items.sum { |item| item.quantity * 20 } # 20 lbs per door

    [
      ActiveShipping::Package.new(
        total_weight * 16, # Convert to ounces
        [ 30, 80, 2 ], # Standard door dimensions in inches
        units: :imperial
      )
    ]
  end

  def fetch_rates(packages)
    if Rails.env.production?
      ups = ActiveShipping::UPS.new(
        login: ENV["UPS_LOGIN"],
        password: ENV["UPS_PASSWORD"],
        key: ENV["UPS_KEY"]
      )
      ups.find_rates(@from_location, @to_location, packages)
    else
      simulate_shipping_rates
    end
  end

  def simulate_shipping_rates
    # Simulate shipping rates for development/testing
    {
      "ground" => { rate: 75.00, days: 5 },
      "three_day" => { rate: 95.00, days: 3 },
      "two_day" => { rate: 125.00, days: 2 },
      "next_day" => { rate: 175.00, days: 1 }
    }
  end

  def format_rates(rates)
    if rates.is_a?(Hash)
      # Using simulated rates
      format_simulated_rates(rates)
    else
      # Using real UPS rates
      format_ups_rates(rates)
    end
  end

  def format_simulated_rates(rates)
    rates.map do |service, details|
      {
        service: SHIPPING_METHODS[service][:service],
        carrier: SHIPPING_METHODS[service][:carrier],
        rate: details[:rate],
        delivery_date: calculate_delivery_date(details[:days]),
        total_days: PRODUCTION_DAYS + details[:days]
      }
    end
  end

  def format_ups_rates(rates)
    rates.rates.map do |rate|
      service = SHIPPING_METHODS.find { |_, v| v[:service] == rate.service_name }
      next unless service

      {
        service: rate.service_name,
        carrier: "UPS",
        rate: rate.total_price.to_f / 100,
        delivery_date: calculate_delivery_date(rate.delivery_range_end),
        total_days: PRODUCTION_DAYS + rate.delivery_range_end
      }
    end.compact
  end

  def calculate_delivery_date(shipping_days)
    production_end_date = PRODUCTION_DAYS.business_days.from_now
    shipping_days.business_days.after(production_end_date)
  end

  def handle_shipping_error(error)
    Rails.logger.error("Shipping calculation error: #{error.message}")
    { error: "Unable to calculate shipping rates at this time." }
  end

  def handle_generic_error(error)
    Rails.logger.error("Unexpected shipping error: #{error.message}")
    { error: "An unexpected error occurred while calculating shipping." }
  end
end
