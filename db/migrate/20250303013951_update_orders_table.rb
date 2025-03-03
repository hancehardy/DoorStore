class UpdateOrdersTable < ActiveRecord::Migration[8.0]
  def change
    change_table :orders do |t|
      t.rename :order_status, :status
      t.datetime :expires_at
      t.text :notes
      t.change :user_id, :bigint, null: true
    end

    change_table :line_items do |t|
      t.rename :price, :price_per_unit
      t.remove :unit_price
    end
  end
end
