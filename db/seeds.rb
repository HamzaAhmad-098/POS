shop = Shop.create!(name: "Test Shop", address: "Test Address", phpos(dev)> shop = Shop.create!(name: "Test Shop", address: "Test Address", phone: "03001234567")
 user = User.create!(
   full_name: "Test Owner",
  email: "test@example.com",
  phone: "03001234567",
 password: "password123",
   role: "owner",
   shop: shop
)
