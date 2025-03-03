# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_03_015117) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.datetime "expires_at"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.string "code", null: false
    t.text "description"
    t.string "discount_type", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "minimum_order_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_discounts_on_active"
    t.index ["code"], name: "index_discounts_on_code", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "line_items", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "cart_id"
    t.bigint "order_id"
    t.integer "quantity"
    t.decimal "width"
    t.decimal "height"
    t.string "glass_option"
    t.string "finish"
    t.decimal "price_per_unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_price", precision: 10, scale: 2
    t.index ["cart_id"], name: "index_line_items_on_cart_id"
    t.index ["order_id"], name: "index_line_items_on_order_id"
    t.index ["product_id"], name: "index_line_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id"
    t.string "status"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.text "notes"
    t.string "payment_intent_id"
    t.string "payment_status"
    t.string "payment_error"
    t.jsonb "payment_method_details"
    t.string "shipping_method"
    t.decimal "shipping_rate", precision: 10, scale: 2
    t.jsonb "shipping_address"
    t.jsonb "billing_address"
    t.date "estimated_delivery_date"
    t.string "tracking_number"
    t.string "carrier"
    t.index ["payment_intent_id"], name: "index_orders_on_payment_intent_id"
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["tracking_number"], name: "index_orders_on_tracking_number"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "name", null: false
    t.string "sku", null: false
    t.decimal "price_modifier", precision: 8, scale: 4, default: "0.0", null: false
    t.string "glass_option"
    t.string "finish"
    t.boolean "active", default: true, null: false
    t.bigint "product_id", null: false
    t.integer "position", default: 0, null: false
    t.jsonb "specifications", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_product_variants_on_active"
    t.index ["finish"], name: "index_product_variants_on_finish"
    t.index ["glass_option"], name: "index_product_variants_on_glass_option"
    t.index ["position"], name: "index_product_variants_on_position"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "product_type"
    t.decimal "price_per_sqft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "base_price", precision: 10, scale: 2, default: "0.0", null: false
    t.text "description", default: "", null: false
    t.decimal "min_width", precision: 8, scale: 2, null: false
    t.decimal "max_width", precision: 8, scale: 2, null: false
    t.decimal "min_height", precision: 8, scale: 2, null: false
    t.decimal "max_height", precision: 8, scale: 2, null: false
    t.boolean "active", default: true, null: false
    t.string "meta_title"
    t.text "meta_description"
    t.jsonb "specifications", default: {}, null: false
    t.integer "position", default: 0, null: false
    t.index ["active"], name: "index_products_on_active"
    t.index ["position"], name: "index_products_on_position"
    t.index ["product_type"], name: "index_products_on_product_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "carts", "users"
  add_foreign_key "line_items", "carts"
  add_foreign_key "line_items", "orders"
  add_foreign_key "line_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "product_variants", "products"
end
