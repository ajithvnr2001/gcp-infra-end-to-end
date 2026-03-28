const API_BASE = '/api'; // Routes through Ingress to API Gateway
const USER_ID = 'demo-user-123';
let cart = [];

// DOM Elements
const loader = document.getElementById('loader');
const productGrid = document.getElementById('product-grid');
const errorMsg = document.getElementById('error-message');
const cartOverlay = document.getElementById('cart-overlay');
const cartCount = document.getElementById('cart-count');
const cartItemsContainer = document.getElementById('cart-items');
const cartTotal = document.getElementById('cart-total');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    fetchProducts();
    fetchCart();
});

// UI Logic
function toggleCart() {
    cartOverlay.classList.toggle('hidden');
}

// Fetch Products from Catalog Service (via API Gateway)
async function fetchProducts() {
    try {
        const response = await fetch(`${API_BASE}/products`);
        if (!response.ok) throw new Error('API Error');
        const data = await response.json();
        
        loader.classList.add('hidden');
        renderProducts(data.products || data); // handle variations in json structure
    } catch (error) {
        console.error('Failed to load products:', error);
        loader.classList.add('hidden');
        errorMsg.classList.remove('hidden');
        // Retry logic for unstable environments
        setTimeout(fetchProducts, 5000);
    }
}

// Fetch user's cart
async function fetchCart() {
    try {
        const response = await fetch(`${API_BASE}/cart/${USER_ID}`);
        if (response.ok) {
            const data = await response.json();
            cart = data.items || [];
            updateCartUI();
        }
    } catch (error) {
        console.error('Failed to load cart:', error);
    }
}

// Render Products to Screen
function renderProducts(products) {
    if (!Array.isArray(products) || products.length === 0) {
        // Fallback demo data if db is empty during interview
        products = [
            { id: "1", name: "Aura Noise-Cancelling Headphones", price: 299.99, description: "Studio-quality sound with adaptive ANC." },
            { id: "2", name: "Minimalist Mechanical Keyboard", price: 149.50, description: "Tactile precision crafted for typists." },
            { id: "3", name: "Premium Leather Desk Mat", price: 89.00, description: "Elevate your workspace aesthetics." },
            { id: "4", name: "Ergonomic Workflow Mouse", price: 119.99, description: "Designed for endless productivity." }
        ];
    }

    productGrid.innerHTML = products.map(p => `
        <article class="glass-card">
            <div class="card-img-placeholder">
                <span style="opacity:0.3">AURA</span>
            </div>
            <h4 class="card-title">${p.name}</h4>
            <p class="card-desc">${p.description}</p>
            <div class="card-footer">
                <span class="price">$${parseFloat(p.price).toFixed(2)}</span>
                <button class="add-btn" onclick="addToCart('${p.id}', '${p.name.replace(/'/g, "\\'")}', ${p.price})">Add to Cart</button>
            </div>
        </article>
    `).join('');
}

// Add Item to Cart
async function addToCart(productId, name, price) {
    const item = { product_id: productId, name, price, quantity: 1 };
    
    // Optimistic UI update
    const existingIndex = cart.findIndex(i => i.product_id === productId);
    if (existingIndex > -1) {
        cart[existingIndex].quantity += 1;
    } else {
        cart.push(item);
    }
    updateCartUI();

    // API Call
    try {
        await fetch(`${API_BASE}/cart/${USER_ID}/add`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(item)
        });
    } catch (error) {
        console.error('Failed to add to cart details:', error);
        // revert optimistic update on failure could go here
    }
}

// Update Cart Display
function updateCartUI() {
    // Total count
    const totalCount = cart.reduce((sum, item) => sum + item.quantity, 0);
    cartCount.innerText = totalCount;

    // Items list
    if (cart.length === 0) {
        cartItemsContainer.innerHTML = '<p class="empty-cart">Your cart is feeling light.</p>';
        cartTotal.innerText = '$0.00';
        return;
    }

    let sum = 0;
    cartItemsContainer.innerHTML = cart.map(item => {
        const itemTotal = item.price * item.quantity;
        sum += itemTotal;
        return `
            <div class="cart-item">
                <div>
                    <strong>${item.name}</strong>
                    <div style="color:var(--text-muted);font-size:0.9rem">Qty: ${item.quantity} × $${parseFloat(item.price).toFixed(2)}</div>
                </div>
                <span>$${itemTotal.toFixed(2)}</span>
            </div>
        `;
    }).join('');

    cartTotal.innerText = `$${sum.toFixed(2)}`;
}

// Checkout Function (UI only for demo, links to payment service)
async function checkout() {
    if (cart.length === 0) return alert('Your cart is empty');
    
    const total = cart.reduce((sum, it) => sum + (it.price * it.quantity), 0);
    
    try {
        const btn = document.querySelector('.checkout-btn');
        btn.innerText = 'Processing...';
        btn.disabled = true;

        const response = await fetch(`${API_BASE}/orders`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_id: USER_ID,
                items: cart,
                total_amount: total
            })
        });

        if (response.ok) {
            cart = [];
            updateCartUI();
            alert('Order placed successfully! Secure payment processed.');
            toggleCart();
        } else {
            throw new Error('Checkout failed');
        }
    } catch (error) {
        alert('Simulated API Checkout Failed: Ensure your Payment Service is running.');
    } finally {
        const btn = document.querySelector('.checkout-btn');
        btn.innerText = 'Secure Checkout';
        btn.disabled = false;
    }
}
