class Shop < ApplicationRecord
  has_many :users
  has_many :products
  has_many :sales
  has_many :purchases
  has_many :categories
  has_many :customers
  has_one_attached :logo # optional

  belongs_to :subscription_plan, optional: true
end
