class POSSystem {
  constructor() {
    this.cart = [];
    this.initEventListeners();
  }

  initEventListeners() {
    document.getElementById('scan-btn').addEventListener('click', () => this.scanBarcode());
    document.getElementById('product-search').addEventListener('keypress', (e) => {
      if (e.key === 'Enter') this.searchProduct();
    });
    document.getElementById('checkout-btn').addEventListener('click', () => this.checkout());
  }

  async scanBarcode() {
    // Implement barcode scanning using QuaggaJS or similar
    alert('Barcode scanning would be implemented here');
  }

  async searchProduct() {
    const searchTerm = document.getElementById('product-search').value;
    const response = await fetch(`/products/lookup?barcode=${encodeURIComponent(searchTerm)}`);
    
    if (response.ok) {
      const product = await response.json();
      this.addToCart(product);
    } else {
      this.showAddProductModal(searchTerm);
    }
  }

  addToCart(product) {
    const existingItem = this.cart.find(item => item.id === product.id);
    
    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      this.cart.push({
        ...product,
        quantity: 1
      });
    }
    
    this.updateCartDisplay();
  }

  updateCartDisplay() {
    const cartContainer = document.getElementById('cart-items');
    cartContainer.innerHTML = '';
    
    this.cart.forEach(item => {
      const row = document.createElement('tr');
      row.innerHTML = `
        <td>${item.name}</td>
        <td>Rs. ${item.selling_price}</td>
        <td>
          <button onclick="pos.updateQuantity(${item.id}, -1)">-</button>
          ${item.quantity}
          <button onclick="pos.updateQuantity(${item.id}, 1)">+</button>
        </td>
        <td>Rs. ${(item.selling_price * item.quantity).toFixed(2)}</td>
        <td><button onclick="pos.removeFromCart(${item.id})">Remove</button></td>
      `;
      cartContainer.appendChild(row);
    });
    
    this.calculateTotals();
  }

  updateQuantity(productId, change) {
    const item = this.cart.find(item => item.id === productId);
    if (item) {
      item.quantity += change;
      if (item.quantity <= 0) {
        this.removeFromCart(productId);
      } else {
        this.updateCartDisplay();
      }
    }
  }

  removeFromCart(productId) {
    this.cart = this.cart.filter(item => item.id !== productId);
    this.updateCartDisplay();
  }

  calculateTotals() {
    const subtotal = this.cart.reduce((sum, item) => sum + (item.selling_price * item.quantity), 0);
    const discount = parseFloat(document.getElementById('discount').value) || 0;
    const tax = parseFloat(document.getElementById('tax').value) || 0;
    
    const total = subtotal - discount + tax;
    
    document.getElementById('subtotal').textContent = `Rs. ${subtotal.toFixed(2)}`;
    document.getElementById('total').textContent = `Rs. ${total.toFixed(2)}`;
  }

  async checkout() {
    const saleData = {
      sale_items_attributes: this.cart.map(item => ({
        product_id: item.id,
        qty: item.quantity,
        unit_price_cents: Math.round(item.selling_price * 100)
      })),
      discount_cents: parseFloat(document.getElementById('discount').value) * 100 || 0,
      tax_cents: parseFloat(document.getElementById('tax').value) * 100 || 0,
      payment_method: document.querySelector('input[name="payment_method"]:checked').value
    };

    const response = await fetch('/sales', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ sale: saleData })
    });

    if (response.ok) {
      const result = await response.json();
      window.location.href = `/sales/${result.id}/receipt`;
    } else {
      alert('Error processing sale');
    }
  }

  showAddProductModal(barcode) {
    // Show modal to add new product with pre-filled barcode
    if (confirm(`Product not found. Would you like to add a new product with barcode: ${barcode}?`)) {
      window.location.href = `/products/new?barcode=${encodeURIComponent(barcode)}`;
    }
  }
}

// Initialize POS system when page loads
document.addEventListener('DOMContentLoaded', () => {
  window.pos = new POSSystem();
});