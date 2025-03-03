Rails.configuration.stripe = {
  publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"],
  secret_key: ENV["STRIPE_SECRET_KEY"]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

# Use test mode keys in development and test environments
if Rails.env.development? || Rails.env.test?
  Rails.configuration.stripe[:publishable_key] = "pk_test_your_test_key"
  Rails.configuration.stripe[:secret_key] = "sk_test_your_test_key"
  Stripe.api_key = Rails.configuration.stripe[:secret_key]
end
