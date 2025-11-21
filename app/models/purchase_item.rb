class PurchaseItem < ApplicationRecord
  belongs_to :purchase
  belongs_to :product

  after_create :apply_stock

  def apply_stock
    product.change_stock!(qty.to_d, reason: 'purchase', related: purchase)
  end
end
