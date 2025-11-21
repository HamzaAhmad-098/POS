// app/javascript/controllers/product_api_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["barcode", "name", "brand", "category", "fetchButton", "status"]

  connect() {
    console.log("Product API controller connected")
  }

  async fetchDetails() {
    const barcode = this.barcodeTarget.value.trim()
    
    if (!barcode) {
      this.showStatus('Please enter a barcode first', 'error')
      return
    }

    this.showLoading()
    this.fetchButtonTarget.disabled = true

    try {
      const response = await fetch(`/products/fetch_details?barcode=${encodeURIComponent(barcode)}`)
      const result = await response.json()

      if (result.success) {
        this.fillForm(result.product)
        this.showStatus(`✅ Product details fetched from ${this.formatSource(result.product.source)}`, 'success')
      } else {
        this.showStatus(`⚠️ ${result.message}`, 'warning')
        // Auto-focus on name field for manual entry
        if (this.hasNameTarget) this.nameTarget.focus()
      }
    } catch (error) {
      console.error('API Error:', error)
      this.showStatus('❌ Network error. Please check your connection and try again.', 'error')
    } finally {
      this.fetchButtonTarget.disabled = false
    }
  }

  fillForm(productData) {
    if (this.hasNameTarget && productData.name) {
      this.nameTarget.value = productData.name
    }
    
    if (this.hasBrandTarget && productData.brand) {
      this.brandTarget.value = productData.brand
    }
    
    if (this.hasCategoryTarget && productData.category_id) {
      this.categoryTarget.value = productData.category_id
    }
    
    // Auto-focus on selling price for quick entry
    const sellingPriceField = document.querySelector('#product_selling_price_cents')
    if (sellingPriceField) sellingPriceField.focus()
  }

  showLoading() {
    if (this.hasStatusTarget) {
      this.statusTarget.innerHTML = `
        <div class="alert alert-info">
          <div class="d-flex align-items-center">
            <div class="spinner-border spinner-border-sm me-2" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
            <span>Searching 7 free databases for product information...</span>
          </div>
        </div>
      `
    }
  }

  showStatus(message, type = 'info') {
    if (this.hasStatusTarget) {
      const alertClass = {
        'success': 'alert-success',
        'error': 'alert-danger',
        'warning': 'alert-warning',
        'info': 'alert-info'
      }[type]

      this.statusTarget.innerHTML = `
        <div class="alert ${alertClass}">
          ${message}
        </div>
      `
    }
  }

  formatSource(source) {
    const sourceMap = {
      'open_food_facts': 'Open Food Facts',
      'open_beauty_facts': 'Open Beauty Facts',
      'open_products_facts': 'Open Products Facts',
      'open_pet_food_facts': 'Open Pet Food Facts',
      'barcode_database': 'Barcode Database',
      'upcitemdb': 'UPCitemdb',
      'barcodes_database': 'Barcodes Database'
    }
    
    return sourceMap[source] || source
  }

  // Auto-fetch when barcode is entered (after delay)
  autoFetch() {
    const barcode = this.barcodeTarget.value.trim()
    
    // Only auto-fetch if barcode is complete and name field is empty
    if (barcode.length >= 8 && (!this.hasNameTarget || !this.nameTarget.value.trim())) {
      clearTimeout(this.autoFetchTimeout)
      this.autoFetchTimeout = setTimeout(() => {
        this.fetchDetails()
      }, 1500)
    }
  }
}