# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :destroy, :show]
  before_action :set_categories, only: [:new, :create, :edit, :update]
  
# app/controllers/products_controller.rb
# app/controllers/products_controller.rb
# app/controllers/products_controller.rb
def index
  @products = Current.shop.products.includes(:category)
  
  if params[:search].present?
    @products = @products.where("name ILIKE ? OR barcode ILIKE ? OR brand ILIKE ?", 
                               "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
  end
  
  if params[:low_stock].present?
    @products = @products.where("current_stock <= reorder_level")
  end

  respond_to do |format|
    format.html
    format.json do
      # Make sure we return proper JSON
      products_data = @products.map { |p| 
        { 
          id: p.id, 
          name: p.name, 
          brand: p.brand,
          selling_price: p.selling_price.to_f,
          current_stock: p.current_stock.to_f,
          barcode: p.barcode
        } 
      }
      render json: products_data
    end
  end
end

  def show
  end

  def new
    @product = Current.shop.products.new
    @product.barcode = params[:barcode] if params[:barcode].present?
    @product.current_stock = 0
    
    # If barcode is provided, try to fetch product details
    if @product.barcode.present?
      fetch_and_prefill_product_details(@product.barcode)
    end
  end

  def create
    @product = Current.shop.products.new(product_params)
    
    if @product.save
      if params[:save_and_scan].present?
        redirect_to scan_products_path, notice: "Product saved! You can scan another barcode."
      else
        redirect_to products_path, notice: "Product created successfully!"
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: "Product updated successfully!"
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Product deleted successfully!"
  end

  def scan
    # Render scan page
  end

  def process_scan
    barcode = params[:barcode]&.strip
    
    if barcode.present?
      # Validate barcode format
      unless valid_barcode?(barcode)
        redirect_to scan_products_path, alert: "Invalid barcode format. Please check and try again."
        return
      end

      # Check if product already exists
      existing_product = Current.shop.products.find_by(barcode: barcode)
      
      if existing_product
        redirect_to edit_product_path(existing_product), 
                    notice: "Product already exists! You can update it."
      else
        # Redirect to new product form with barcode pre-filled
        redirect_to new_product_path(barcode: barcode), 
                    notice: "Barcode scanned! Fetching product details from multiple databases..."
      end
    else
      redirect_to scan_products_path, alert: "No barcode detected. Please try again."
    end
  end

  def lookup
    product = Current.shop.products.find_by(barcode: params[:barcode])
    
    if product
      render json: {
        success: true,
        product: {
          id: product.id,
          name: product.name,
          selling_price: product.selling_price,
          current_stock: product.current_stock,
          barcode: product.barcode
        }
      }
    else
      render json: { 
        success: false, 
        message: "Product not found in your inventory",
        barcode: params[:barcode]
      }
    end
  end

  def fetch_details
    barcode = params[:barcode]&.strip
    
    if barcode.present?
      # Validate barcode first
      unless valid_barcode?(barcode)
        render json: { 
          success: false, 
          message: "Invalid barcode format. Please check the barcode and try again.",
          barcode: barcode
        }, status: :bad_request
        return
      end

      # Fetch from all free APIs
      product_info = ProductApiService.fetch_product_details(barcode)
      
      if product_info && product_info[:success]
        # Find or create category
        category = find_or_create_category(product_info[:category])
        
        render json: {
          success: true,
          product: product_info.merge(category_id: category&.id)
        }
      else
        render json: { 
          success: false, 
          message: "Product not found in any free product database. This product might be local or new. Please enter details manually.",
          barcode: barcode,
          sources_tried: [
            'Open Food Facts (Global)',
            'Open Beauty Facts (Personal Care)',
            'Open Products Facts (Non-food)',
            'Open Pet Food Facts (Pet Food)',
            'Barcode Database',
            'UPCitemdb',
            'Barcodes Database'
          ]
        }
      end
    else
      render json: { 
        success: false, 
        message: "No barcode provided" 
      }, status: :bad_request
    end
  end

  def bulk_import
    if request.post?
      # Handle CSV import logic here
      redirect_to products_path, notice: "Products imported successfully!"
    end
  end

  def test_apis
    # Test method to check all APIs
    test_barcodes = [
      "3017620422003", # Nutella (International)
      "5449000000996", # Coca-Cola (International)
      "8901030223018", # Parle-G (Indian - should work)
      "8901491003254", # Bru Coffee (Indian - should work)
      "6291101250128", # Almarai Juice (Middle East)
      "6291100150193"  # Almarai Milk (Middle East)
    ]
    
    results = {}
    
    test_barcodes.each do |barcode|
      results[barcode] = ProductApiService.fetch_product_details(barcode)
    end
    
    render json: {
      message: "API Test Results",
      results: results,
      timestamp: Time.current
    }
  end

  private
  
  def set_product
    @product = Current.shop.products.find(params[:id])
  end

  def set_categories
    @categories = Current.shop.categories
  end

  def product_params
    params.require(:product).permit(
      :name, :sku, :barcode, :category_id, :purchase_price_cents,
      :selling_price_cents, :current_stock, :reorder_level, :expiry_date, :photo,
      :brand, :unit
    )
  end

  def fetch_and_prefill_product_details(barcode)
    product_info = ProductApiService.fetch_product_details(barcode)
    
    if product_info && product_info[:success]
      @product.name = product_info[:name] if product_info[:name].present?
      @product.brand = product_info[:brand] if product_info[:brand].present?
      
      # Handle category
      if product_info[:category].present?
        category = find_or_create_category(product_info[:category])
        @product.category = category if category
      end
      
      # Set image if URL is available
      @product.remote_photo_url = product_info[:image_url] if product_info[:image_url].present?
      
      # Store API info for display
      @api_product_info = product_info
      flash.now[:info] = "✅ Product details fetched from #{product_info[:source].to_s.humanize}"
    else
      flash.now[:warning] = "⚠️ No product details found for barcode #{barcode}. This appears to be a local product. Please enter details manually."
    end
  end

  def find_or_create_category(category_name)
    return nil unless category_name.present?
    
    # Clean category name
    clean_name = category_name.strip.capitalize
    return nil if clean_name.blank?
    
    # Find existing category or create new one
    Current.shop.categories.find_or_create_by(name: clean_name)
  end

  def valid_barcode?(barcode)
    # Basic barcode validation
    return false unless barcode.present?
    
    # Remove any non-digit characters
    clean_barcode = barcode.gsub(/\D/, '')
    
    # Check length (EAN-13, UPC-A, EAN-8 are common)
    [8, 12, 13].include?(clean_barcode.length)
  end
end