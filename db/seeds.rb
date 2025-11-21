# Create subscription plans
basic = SubscriptionPlan.find_or_create_by!(name: "Basic") do |p|
  p.monthly_price_pkr = 2000
  p.features = { billing: true, inventory: true, camera_scan: true }
end

pro = SubscriptionPlan.find_or_create_by!(name: "Pro") do |p|
  p.monthly_price_pkr = 3500
  p.features = { billing: true, inventory: true, backup: true, sms: true }
end

# Create admin user
admin = User.create_with(
  full_name: "Admin",
  role: :admin,
  password: "password123"
).find_or_create_by!(
  email: "admin@example.com",
  phone: "0000000000"
)

# Create demo shop owned by admin
shop = Shop.find_or_create_by!(name: "Demo Store") do |s|
  s.owner_user_id = admin.id
  s.phone = "03120000000"
  s.subscription_plan = basic
end

# Create owner user for the shop
owner = User.create_with(
  full_name: "Owner",
  role: :owner,
  password: "ownerpass",
  shop: shop
).find_or_create_by!(
  email: "owner@demo.com",
  phone: "03121234567"
)

puts "Seed completed successfully!"
# db/seeds/pakistani_categories.rb
def create_pakistani_categories(shop)
  pakistani_categories = [
    'Snacks',
    'Beverages',
    'Dairy',
    'Bakery',
    'Groceries',
    'Spices',
    'Cooking Oil',
    'Personal Care',
    'Cleaning',
    'Fresh Produce',
    'Frozen Foods',
    'Baby Care',
    'Stationery',
    'Electronics',
    'General'
  ]

  pakistani_categories.each do |category_name|
    shop.categories.find_or_create_by!(name: category_name)
  end
end

# Run this in rails console or in your seeds file
# create_pakistani_categories(Current.shop)