class Purchase < ApplicationRecord
  belongs_to :shop
  has_many :purchase_items
  belongs_to :creator, class_name: "User", foreign_key: :created_by_user_id, optional: true
end
