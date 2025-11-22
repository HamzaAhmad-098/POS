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

ActiveRecord::Schema[8.0].define(version: 2025_11_22_140457) do
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

  create_table "audit_logs", force: :cascade do |t|
    t.integer "actor_user_id"
    t.string "action"
    t.string "auditable_type"
    t.integer "auditable_id"
    t.jsonb "changes_json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_user_id"], name: "index_audit_logs_on_actor_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.bigint "shop_id"
    t.string "name"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["shop_id"], name: "index_categories_on_shop_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "shop_id"
    t.string "name"
    t.string "phone"
    t.integer "credit_balance_cents", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_customers_on_phone"
    t.index ["shop_id"], name: "index_customers_on_shop_id"
  end

  create_table "device_sessions", force: :cascade do |t|
    t.bigint "shop_id"
    t.string "device_id"
    t.datetime "last_sync_at"
    t.jsonb "pending_changes_json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_device_sessions_on_device_id"
    t.index ["shop_id"], name: "index_device_sessions_on_shop_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "shop_id"
    t.string "sku"
    t.string "barcode"
    t.string "name"
    t.bigint "category_id"
    t.string "brand"
    t.string "unit"
    t.integer "purchase_price_cents", default: 0, null: false
    t.integer "selling_price_cents", default: 0, null: false
    t.decimal "current_stock", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "reorder_level", precision: 12, scale: 2, default: "0.0"
    t.date "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["barcode"], name: "index_products_on_barcode"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["shop_id"], name: "index_products_on_shop_id"
    t.index ["sku"], name: "index_products_on_sku"
  end

  create_table "purchase_items", force: :cascade do |t|
    t.bigint "purchase_id"
    t.bigint "product_id"
    t.decimal "qty", precision: 12, scale: 2
    t.integer "unit_cost_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_purchase_items_on_product_id"
    t.index ["purchase_id"], name: "index_purchase_items_on_purchase_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "shop_id"
    t.string "vendor_name"
    t.string "invoice_no"
    t.integer "total_cost_cents", default: 0
    t.integer "created_by_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_purchases_on_shop_id"
  end

  create_table "sale_items", force: :cascade do |t|
    t.bigint "sale_id"
    t.bigint "product_id"
    t.decimal "qty", precision: 12, scale: 2
    t.integer "unit_price_cents"
    t.integer "total_price_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sale_items_on_product_id"
    t.index ["sale_id"], name: "index_sale_items_on_sale_id"
  end

  create_table "sales", force: :cascade do |t|
    t.bigint "shop_id"
    t.bigint "user_id"
    t.integer "total_cents", default: 0
    t.integer "discount_cents", default: 0
    t.integer "tax_cents", default: 0
    t.string "payment_method"
    t.string "invoice_no"
    t.string "status", default: "completed"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_no"], name: "index_sales_on_invoice_no"
    t.index ["shop_id"], name: "index_sales_on_shop_id"
    t.index ["user_id"], name: "index_sales_on_user_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "name", null: false
    t.integer "owner_user_id"
    t.string "address"
    t.string "phone"
    t.string "currency", default: "PKR"
    t.string "timezone", default: "Asia/Karachi"
    t.integer "subscription_plan_id"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_user_id"], name: "index_shops_on_owner_user_id"
    t.index ["subscription_plan_id"], name: "index_shops_on_subscription_plan_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.bigint "shop_id"
    t.bigint "product_id"
    t.decimal "change_qty", precision: 12, scale: 2
    t.string "reason"
    t.integer "related_id"
    t.string "related_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "created_at"], name: "index_stock_movements_on_product_id_and_created_at"
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
    t.index ["shop_id"], name: "index_stock_movements_on_shop_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "name"
    t.integer "monthly_price_pkr"
    t.jsonb "features", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "shop_id"
    t.bigint "user_id"
    t.string "subject"
    t.text "body"
    t.string "status", default: "open"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_tickets_on_shop_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "phone", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", null: false
    t.bigint "shop_id"
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["shop_id"], name: "index_users_on_shop_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "shops"
  add_foreign_key "customers", "shops"
  add_foreign_key "device_sessions", "shops"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "shops"
  add_foreign_key "purchase_items", "products"
  add_foreign_key "purchase_items", "purchases"
  add_foreign_key "purchases", "shops"
  add_foreign_key "sale_items", "products"
  add_foreign_key "sale_items", "sales"
  add_foreign_key "sales", "shops"
  add_foreign_key "sales", "users"
  add_foreign_key "stock_movements", "products"
  add_foreign_key "stock_movements", "shops"
  add_foreign_key "tickets", "shops"
  add_foreign_key "tickets", "users"
  add_foreign_key "users", "shops"
end
