# app/models/sale.rb
class Sale < ApplicationRecord
  belongs_to :shop
  belongs_to :user
  belongs_to :customer, optional: true
  has_many :sale_items, dependent: :destroy
  
  accepts_nested_attributes_for :sale_items, allow_destroy: true
  
  # Fixed enum syntax for Rails 7+
  enum :payment_method, {
    cash: 0,
    card: 1,
    digital: 2,
    jazzcash: 3,
    easypaisa: 4
  }, default: :cash
  
  # Status enum for tracking sale state
  enum :status, {
    pending: 0,
    completed: 1,
    refunded: 2,
    cancelled: 3
  }, default: :completed
  
  validates :invoice_no, presence: true, uniqueness: { scope: :shop_id }
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :sale_items, length: { minimum: 1, message: "must have at least one item" }
  validates :user, presence: true
  validates :shop, presence: true

  before_validation :set_defaults
  before_validation :calculate_total
  validate :validate_stock_availability
  
  after_create :update_product_stocks
  after_destroy :restore_product_stocks

  # Money conversion methods
  def total_amount
    total_cents.to_f / 100.0
  end

  def discount_amount
    discount_cents.to_f / 100.0
  end

  def tax_amount
    tax_cents.to_f / 100.0
  end

  def subtotal_amount
    sale_items.sum { |item| item.total_price_cents.to_f / 100.0 }
  end
  
  def net_amount
    (subtotal_amount - discount_amount + tax_amount).round(2)
  end

  private

  def set_defaults
    self.invoice_no ||= generate_invoice_number
    self.payment_method ||= :cash
    self.discount_cents ||= 0
    self.tax_cents ||= 0
    self.status ||= :completed
  end
  
  def calculate_total
    return unless sale_items.any?
    
    subtotal = sale_items.sum(&:total_price_cents)
    discount = discount_cents || 0
    tax = tax_cents || 0
    
    self.total_cents = [0, subtotal - discount + tax].max
  end

  def generate_invoice_number
    date = Time.current.strftime("%Y%m%d")
    last_sale = shop.sales.where("invoice_no LIKE ?", "#{date}%").order(:invoice_no).last
    if last_sale
      last_number = last_sale.invoice_no.split('-').last.to_i
      "#{date}-#{'%03d' % (last_number + 1)}"
    else
      "#{date}-001"
    end
  end
  
  def validate_stock_availability
    return unless sale_items.any?
    
    sale_items.each do |item|
      next unless item.product
      
      if item.product.current_stock < item.qty
        errors.add(:base, "Insufficient stock for #{item.product.name}. Available: #{item.product.current_stock}, Required: #{item.qty}")
      end
    end
  end
  
  def update_product_stocks
    sale_items.each do |item|
      if item.product
        item.product.change_stock!(-item.qty, reason: 'sale', related: self)
      end
    end
  rescue => e
    Rails.logger.error("Failed to update stock for sale #{id}: #{e.message}")
    raise ActiveRecord::Rollback
  end
  
  def restore_product_stocks
    sale_items.each do |item|
      if item.product
        item.product.change_stock!(item.qty, reason: 'sale_refund', related: self)
      end
    end
  rescue => e
    Rails.logger.error("Failed to restore stock for sale #{id}: #{e.message}")
  end
end