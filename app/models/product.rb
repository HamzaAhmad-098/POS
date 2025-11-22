# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :shop
  belongs_to :category, optional: true
  has_one_attached :photo

  has_many :sale_items
  has_many :stock_movements

  validates :name, presence: true
  validates :barcode, uniqueness: { scope: :shop_id }, allow_blank: true

  # Add remote photo URL support
  attr_accessor :remote_photo_url

  before_save :download_remote_photo, if: :remote_photo_url_provided?

  # Scopes for multi-tenancy
  scope :for_shop, ->(shop_id) { where(shop_id: shop_id) }
  def purchase_price
    purchase_price_cents
  end

  def purchase_price=(value)
    self.purchase_price_cents = value.to_i
  end

  def selling_price
    selling_price_cents
  end

  def selling_price=(value)
    self.selling_price_cents = value.to_i
  end

  # update stock and create movement
  def change_stock!(qty, reason:, related: nil)
    self.with_lock do
      old = current_stock
      new_stock = (old.to_d + qty.to_d)
      self.current_stock = new_stock
      save!
      StockMovement.create!(
        shop: shop,
        product: self,
        change_qty: qty,
        reason: reason,
        related_id: (related && related.id),
        related_type: (related && related.class.to_s)
      )
    end
  end

  private

  def remote_photo_url_provided?
    remote_photo_url.present?
  end

  def download_remote_photo
    return unless remote_photo_url.present?
    
    begin
      # Download and attach the image
      downloaded_image = URI.open(remote_photo_url)
      self.photo.attach(io: downloaded_image, filename: "product_#{barcode}.jpg")
    rescue => e
      Rails.logger.error "Error downloading remote photo: #{e.message}"
      # Don't fail the save if image download fails
    end
  end
end