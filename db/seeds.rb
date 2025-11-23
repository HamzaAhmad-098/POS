


# 2. Create the Shop
puts "  Creating Shop..."
shop = Shop.create!(
  name: "M.Beauty Bloom",
  address: "Urdu Bazaar Beside Nazir cloth House",
  phone: "03434801621"
)
puts "  ✅ Shop created: '#{shop.name}' (ID: #{shop.id})"

# 3. Create the User associated with the Shop
puts "  Creating Owner..."
user = User.create!(
  full_name: "Muddasir",
  email: "muddasir@hamzaxdevelopers.com",
  phone: "03434801621",
  password: "muddasir1234",
  role: "owner",
  shop: shop # Rails automatically handles the foreign key (shop_id) here
)
puts "  ✅ User created: '#{user.full_name}' with email '#{user.email}'"

puts "🎉 Seeding completed successfully!"