# app/models/user.rb
class User < ApplicationRecord
  belongs_to :shop, optional: true

  has_secure_password

  enum :role, { cashier: 0, owner: 1, admin: 2 }, prefix: true

  validates :full_name, presence: true
  validates :phone, presence: true
  validates :email, presence: true, uniqueness: true
end