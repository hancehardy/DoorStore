class AddPaymentAndShippingToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :payment_intent_id, :string
    add_column :orders, :payment_status, :string
    add_column :orders, :payment_error, :string
    add_column :orders, :payment_method_details, :jsonb
    add_column :orders, :shipping_method, :string
    add_column :orders, :shipping_rate, :decimal, precision: 10, scale: 2
    add_column :orders, :shipping_address, :jsonb
    add_column :orders, :billing_address, :jsonb
    add_column :orders, :estimated_delivery_date, :date
    add_column :orders, :tracking_number, :string
    add_column :orders, :carrier, :string

    add_index :orders, :payment_intent_id
    add_index :orders, :payment_status
    add_index :orders, :tracking_number
  end
end
