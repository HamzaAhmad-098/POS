# app/models/sale_item.rb
class SaleItem < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  validates :qty, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, presence: true
  validate :stock_availability

  before_validation :set_unit_price
  before_save :calculate_total_price

  def total_price_cents
    (qty * unit_price_cents).round
  end

  def unit_price
    unit_price_cents.to_f / 100.0
  end

  def total_price
    total_price_cents.to_f / 100.0
  end

  private
  
  def set_unit_price
    # Auto-set unit price from product if not provided
    if unit_price_cents.nil? && product
      self.unit_price_cents = product.selling_price_cents
    end
  end

  def calculate_total_price
    self.total_price_cents = (qty * unit_price_cents).round
  end
  
  def stock_availability
    return unless product && qty
    
    # Skip validation if sale is being refunded/cancelled
    return if sale&.refunded? || sale&.cancelled?
    
    if product.current_stock < qty
      errors.add(:qty, "exceeds available stock (#{product.current_stock} available)")
    end
  end
end