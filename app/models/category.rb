class Category < ApplicationRecord
  belongs_to :shop
  has_many :products
  belongs_to :parent, class_name: "Category", optional: true
end
