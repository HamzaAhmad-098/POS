# 1. Clean the database (Optional but recommended)
# This prevents "Email has already been taken" errors if you run seeds twice.
puts "🗑️  Cleaning up old data..."
User.destroy_all
Shop.destroy_all

puts "🌱 Seeding data..."

# 2. Create the Shop
puts "  Creating Shop..."
shop = Shop.create!(
  name: "Test Shop",
  address: "Test Address",
  phone: "03001234567"
)
puts "  ✅ Shop created: '#{shop.name}' (ID: #{shop.id})"

# 3. Create the User associated with the Shop
puts "  Creating Owner..."
user = User.create!(
  full_name: "Test Owner",
  email: "test@example.com",
  phone: "03001234567",
  password: "password123",
  role: "owner",
  shop: shop # Rails automatically handles the foreign key (shop_id) here
)
puts "  ✅ User created: '#{user.full_name}' with email '#{user.email}'"

puts "🎉 Seeding completed successfully!"