# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :destroy, :show]
  before_action :set_categories, only: [:new, :create, :edit, :update]
  
  def index
    @products = Current.shop.products.includes(:category)
    
    # Handle barcode-specific search (for scanner)
    if params[:barcode].present?
      barcode = params[:barcode].strip
      @products = @products.where("barcode = ?", barcode)
    elsif params[:search].present?
      # General search by name, barcode, or brand
      search_term = "%#{params[:search]}%"
      @products = @products.where(
        "name ILIKE ? OR barcode ILIKE ? OR brand ILIKE ?", 
        search_term, search_term, search_term
      )
    end
    
    if params[:low_stock].present?
      @products = @products.where("current_stock <= reorder_level")
    end

    respond_to do |format|
      format.html
      format.json do
        products_data = @products.limit(50).map { |p| 
          { 
            id: p.id, 
            name: p.name, 
            brand: p.brand,
            selling_price: p.selling_price.to_f,
            current_stock: p.current_stock.to_f,
            barcode: p.barcode,
            unit: p.unit,
            category: p.category&.name
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
    @product = Product.find(params[:id])
    @product.destroy
    
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully deleted.' }
      format.json { head :no_content }
    end
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

  # API endpoint for quick barcode lookup (used by POS scanner)
  def lookup
    barcode = params[:barcode]&.strip
    
    if barcode.blank?
      render json: { 
        success: false, 
        message: "Barcode is required"
      }, status: :bad_request
      return
    end
    
    product = Current.shop.products.find_by(barcode: barcode)
    
    if product
      render json: {
        success: true,
        product: {
          id: product.id,
          name: product.name,
          brand: product.brand,
          selling_price: product.selling_price.to_f,
          current_stock: product.current_stock.to_f,
          barcode: product.barcode,
          unit: product.unit,
          category: product.category&.name
        }
      }
    else
      render json: { 
        success: false, 
        message: "Product not found in your inventory",
        barcode: barcode,
        suggestion: "Add this product to inventory?"
      }, status: :not_found
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

  private
  
  def set_product
    @product = Current.shop.products.find(params[:id])
  end

  def set_categories
    @categories = Current.shop.categories
  end
  def remove_photo
    @product = Product.find(params[:id])
    @product.photo.purge
    redirect_to edit_product_path(@product), notice: 'Photo removed successfully'
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
    [8, 12, 13, 14].include?(clean_barcode.length)
  end
end