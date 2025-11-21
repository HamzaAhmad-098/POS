# app/services/product_api_service.rb
class ProductApiService
  include HTTParty

  # Set default options for HTTParty
  default_timeout 15  # This is the correct way to set timeout

  def self.fetch_product_details(barcode)
    # Try multiple free product databases in sequence
    product_info = nil

    # 1. Try Open Food Facts first (global, free, no key)
    product_info ||= fetch_from_open_food_facts(barcode)

    # 2. Try Open Beauty Facts (personal care, free, no key)
    product_info ||= fetch_from_open_beauty_facts(barcode)

    # 3. Try Open Products Facts (non-food items, free, no key)
    product_info ||= fetch_from_open_products_facts(barcode)

    # 4. Try Open Pet Food Facts (pet food, free, no key)
    product_info ||= fetch_from_open_pet_food_facts(barcode)

    # 5. Try UPCitemdb (free, no key required)
    product_info ||= fetch_from_upcitemdb(barcode)

    # 6. Try Barcode Database (free, no key required)
    product_info ||= fetch_from_barcode_database(barcode)

    product_info
  end

  private

  def self.fetch_from_open_food_facts(barcode)
    response = get("https://world.openfoodfacts.org/api/v0/product/#{barcode}.json")
    
    if response.success? && response['status'] == 1
      product = response['product']
      {
        source: 'open_food_facts',
        name: clean_product_name(product['product_name'] || product['generic_name']),
        brand: clean_brand_name(product['brands']),
        category: extract_category(product['categories']),
        image_url: product['image_url'],
        weight: product['quantity'],
        description: product['generic_name'],
        ingredients: product['ingredients_text'],
        nutrition_info: extract_nutrition_info(product),
        barcode: barcode,
        success: true
      }
    end
  rescue => e
    Rails.logger.error "Open Food Facts API error: #{e.message}"
    nil
  end

  def self.fetch_from_open_beauty_facts(barcode)
    response = get("https://world.openbeautyfacts.org/api/v0/product/#{barcode}.json")
    
    if response.success? && response['status'] == 1
      product = response['product']
      {
        source: 'open_beauty_facts',
        name: clean_product_name(product['product_name'] || product['generic_name']),
        brand: clean_brand_name(product['brands']),
        category: 'Personal Care',
        image_url: product['image_url'],
        weight: product['quantity'],
        description: product['generic_name'],
        barcode: barcode,
        success: true
      }
    end
  rescue => e
    Rails.logger.error "Open Beauty Facts API error: #{e.message}"
    nil
  end

  def self.fetch_from_open_products_facts(barcode)
    response = get("https://world.openproductfacts.org/api/v0/product/#{barcode}.json")
    
    if response.success? && response['status'] == 1
      product = response['product']
      {
        source: 'open_products_facts',
        name: clean_product_name(product['product_name'] || product['generic_name']),
        brand: clean_brand_name(product['brands']),
        category: extract_category(product['categories']),
        image_url: product['image_url'],
        description: product['generic_name'],
        barcode: barcode,
        success: true
      }
    end
  rescue => e
    Rails.logger.error "Open Products Facts API error: #{e.message}"
    nil
  end

  def self.fetch_from_open_pet_food_facts(barcode)
    response = get("https://world.openpetfoodfacts.org/api/v0/product/#{barcode}.json")
    
    if response.success? && response['status'] == 1
      product = response['product']
      {
        source: 'open_pet_food_facts',
        name: clean_product_name(product['product_name'] || product['generic_name']),
        brand: clean_brand_name(product['brands']),
        category: 'Pet Food',
        image_url: product['image_url'],
        description: product['generic_name'],
        barcode: barcode,
        success: true
      }
    end
  rescue => e
    Rails.logger.error "Open Pet Food Facts API error: #{e.message}"
    nil
  end

  def self.fetch_from_barcode_database(barcode)
    # Barcode Database - Free API (if available)
    # Note: This API might not exist or require keys, so we'll skip if it fails
    begin
      response = get("https://api.barcodedatabase.com/v1/product?barcode=#{barcode}")
      
      if response.success? && response['product']
        product = response['product']
        {
          source: 'barcode_database',
          name: clean_product_name(product['name']),
          brand: clean_brand_name(product['brand']),
          category: product['category'],
          image_url: product['image'],
          description: product['description'],
          barcode: barcode,
          success: true
        }
      end
    rescue => e
      Rails.logger.error "Barcode Database API error: #{e.message}"
      nil
    end
  end

  def self.fetch_from_upcitemdb(barcode)
    # UPCitemdb - Free API with good coverage
    response = get("https://api.upcitemdb.com/prod/trial/lookup?upc=#{barcode}")
    
    if response.success? && response['items']&.any?
      product = response['items'].first
      {
        source: 'upcitemdb',
        name: clean_product_name(product['title']),
        brand: clean_brand_name(product['brand']),
        category: product['category'],
        image_url: product['images']&.first,
        description: product['description'],
        weight: product['weight'],
        barcode: barcode,
        success: true
      }
    end
  rescue => e
    Rails.logger.error "UPCitemdb API error: #{e.message}"
    nil
  end

  # Enhanced data cleaning methods
  def self.clean_product_name(name)
    return nil unless name.present?
    
    # Remove extra whitespace and special characters
    name = name.to_s.strip
    # Remove multiple spaces
    name = name.gsub(/\s+/, ' ')
    # Remove common prefixes and suffixes
    name = name.gsub(/^-\s*/, '').gsub(/\s*-$/, '')
    # Capitalize first letter of each word
    name.split(' ').map(&:capitalize).join(' ')
  end

  def self.clean_brand_name(brand)
    return nil unless brand.present?
    
    brand = brand.to_s.strip
    # Remove everything after comma (common in OFF data)
    brand = brand.split(',').first if brand.include?(',')
    # Remove common suffixes
    brand = brand.gsub(/inc\.?$/i, '').gsub(/ltd\.?$/i, '').gsub(/co\.?$/i, '')
    brand.strip.capitalize
  end

  def self.extract_category(categories)
    return 'Uncategorized' unless categories.present?
    
    # Take the first category and clean it
    main_category = categories.to_s.split(',').first.strip
    main_category = main_category.gsub(/^en:/, '').gsub(/^fr:/, '')
    
    # Map to common categories
    category_map = {
      /beverages?/i => 'Beverages',
      /snacks?/i => 'Snacks',
      /dairy/i => 'Dairy',
      /bakery/i => 'Bakery',
      /frozen/i => 'Frozen Foods',
      /personal care/i => 'Personal Care',
      /household/i => 'Household',
      /baby/i => 'Baby Care',
      /pet/i => 'Pet Care',
      /health/i => 'Health',
      /cosmetics/i => 'Cosmetics'
    }
    
    category_map.each do |pattern, mapped_category|
      return mapped_category if main_category.match?(pattern)
    end
    
    main_category.capitalize
  end

  def self.extract_nutrition_info(product)
    return nil unless product['nutriments']
    
    {
      energy: product['nutriments']['energy'],
      proteins: product['nutriments']['proteins'],
      carbohydrates: product['nutriments']['carbohydrates'],
      fat: product['nutriments']['fat'],
      sugar: product['nutriments']['sugars'],
      salt: product['nutriments']['salt']
    }
  end
end