const API_BASE = "/api";
const CURRENCY_FORMATTER = new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
});

const FALLBACK_PRODUCTS = [
    {
        id: "p1",
        name: "Astra Wireless Headphones",
        price: 1999,
        category: "audio",
        stock: 150,
        rating: 4.7,
        description: "Active noise cancellation, low-latency Bluetooth, and a 32-hour battery life.",
        badge: "Best seller",
        eta: "Next-day delivery",
    },
    {
        id: "p2",
        name: "Transit Weekender Duffel",
        price: 2499,
        category: "travel",
        stock: 80,
        rating: 4.5,
        description: "Structured carry-all with laptop sleeve, shoe compartment, and water-resistant shell.",
        badge: "New drop",
        eta: "2-day dispatch",
    },
    {
        id: "p3",
        name: "Foundry Mechanical Keyboard",
        price: 5499,
        category: "workspace",
        stock: 65,
        rating: 4.8,
        description: "Hot-swappable switches, gasket mount frame, and warm white backlighting.",
        badge: "Editor pick",
        eta: "Ships today",
    },
    {
        id: "p4",
        name: "Canvas Everyday Overshirt",
        price: 1799,
        category: "apparel",
        stock: 210,
        rating: 4.3,
        description: "Layer-ready cotton twill with relaxed tailoring for work and weekends.",
        badge: "Seasonal staple",
        eta: "2-day dispatch",
    },
    {
        id: "p5",
        name: "Form Studio Bottle",
        price: 899,
        category: "wellness",
        stock: 120,
        rating: 4.4,
        description: "Double-wall insulated steel bottle sized for desk sessions and gym runs.",
        badge: "Under 1K",
        eta: "Next-day delivery",
    },
];

const state = {
    userId: getOrCreateUserId(),
    products: [],
    cart: { items: [], total: 0, item_count: 0 },
    orders: [],
    filters: {
        query: "",
        category: "all",
        sort: "featured",
    },
};

const elements = {
    cartOverlay: document.getElementById("cart-overlay"),
    cartCount: document.getElementById("cart-count"),
    cartItems: document.getElementById("cart-items"),
    cartQuantity: document.getElementById("cart-quantity"),
    cartTotal: document.getElementById("cart-total"),
    categoryChips: document.getElementById("category-chips"),
    checkoutButton: document.getElementById("checkout-btn"),
    checkoutFeedback: document.getElementById("checkout-feedback"),
    checkoutForm: document.getElementById("checkout-form"),
    closeCartButton: document.getElementById("close-cart-btn"),
    customerAddress: document.getElementById("customer-address"),
    customerEmail: document.getElementById("customer-email"),
    customerName: document.getElementById("customer-name"),
    errorMessage: document.getElementById("error-message"),
    gatewayPill: document.getElementById("gateway-pill"),
    gatewayStatus: document.getElementById("gateway-status"),
    heroCartCount: document.getElementById("hero-cart-count"),
    heroCatalogCount: document.getElementById("hero-catalog-count"),
    heroOrderCount: document.getElementById("hero-order-count"),
    lastOrderCard: document.getElementById("last-order-card"),
    loader: document.getElementById("loader"),
    openCartButton: document.getElementById("open-cart-btn"),
    ordersList: document.getElementById("orders-list"),
    paymentMethod: document.getElementById("payment-method"),
    productGrid: document.getElementById("product-grid"),
    resultsCount: document.getElementById("results-count"),
    scrollCatalogButton: document.getElementById("scroll-catalog-btn"),
    searchInput: document.getElementById("search-input"),
    sortSelect: document.getElementById("sort-select"),
    summaryCartTotal: document.getElementById("summary-cart-total"),
    summaryOrderCount: document.getElementById("summary-order-count"),
    topbarCartButton: document.getElementById("cart-toggle"),
    topbarShopButton: document.getElementById("hero-shop-btn"),
    userIdDisplay: document.getElementById("user-id-display"),
    emptyState: document.getElementById("empty-state"),
};

document.addEventListener("DOMContentLoaded", bootstrap);

function bootstrap() {
    bindEvents();
    hydrateCheckoutFields();
    elements.userIdDisplay.textContent = state.userId;
    refreshPageData();
}

function bindEvents() {
    elements.topbarCartButton.addEventListener("click", openCart);
    elements.openCartButton.addEventListener("click", openCart);
    elements.closeCartButton.addEventListener("click", closeCart);
    elements.cartOverlay.addEventListener("click", event => {
        if (event.target === elements.cartOverlay) {
            closeCart();
        }
    });

    elements.scrollCatalogButton.addEventListener("click", scrollToCatalog);
    elements.topbarShopButton.addEventListener("click", scrollToCatalog);

    elements.searchInput.addEventListener("input", event => {
        state.filters.query = event.target.value.trim().toLowerCase();
        renderProducts();
    });

    elements.sortSelect.addEventListener("change", event => {
        state.filters.sort = event.target.value;
        renderProducts();
    });

    elements.categoryChips.addEventListener("click", event => {
        const chip = event.target.closest("[data-category]");
        if (!chip) {
            return;
        }
        state.filters.category = chip.dataset.category;
        renderCategoryChips();
        renderProducts();
    });

    elements.productGrid.addEventListener("click", async event => {
        const button = event.target.closest("[data-add-product]");
        if (!button) {
            return;
        }
        await addToCart(button.dataset.addProduct);
    });

    elements.cartItems.addEventListener("click", async event => {
        const actionButton = event.target.closest("[data-action]");
        if (!actionButton) {
            return;
        }

        const { action, productId } = actionButton.dataset;
        const item = state.cart.items.find(entry => entry.product_id === productId);
        if (!item) {
            return;
        }

        if (action === "increment") {
            await updateCartQuantity(productId, item.quantity + 1);
        }

        if (action === "decrement") {
            await updateCartQuantity(productId, Math.max(item.quantity - 1, 0));
        }

        if (action === "remove") {
            await removeCartItem(productId);
        }
    });

    elements.checkoutForm.addEventListener("submit", submitOrder);

    document.addEventListener("keydown", event => {
        if (event.key === "Escape") {
            closeCart();
        }
    });
}

async function refreshPageData() {
    setCheckoutMessage("");
    setLoading(true);

    const [gatewayResult, productsResult, cartResult, ordersResult] = await Promise.allSettled([
        fetchGatewayStatus(),
        fetchProducts(),
        fetchCart(),
        fetchOrders(),
    ]);

    setGatewayHealth(gatewayResult.status === "fulfilled");

    if (productsResult.status === "fulfilled") {
        elements.errorMessage.classList.add("hidden");
    } else {
        state.products = FALLBACK_PRODUCTS;
        elements.errorMessage.classList.remove("hidden");
    }

    if (cartResult.status === "rejected") {
        state.cart = { items: [], total: 0, item_count: 0 };
    }

    if (ordersResult.status === "rejected") {
        state.orders = [];
    }

    renderCategoryChips();
    renderProducts();
    renderCart();
    renderOrders();
    updateSummaryMetrics();
    setLoading(false);
}

async function fetchGatewayStatus() {
    await fetchJson("/health");
}

async function fetchProducts() {
    const payload = await fetchJson("/products");
    state.products = Array.isArray(payload) ? payload : payload.products;
}

async function fetchCart() {
    const payload = await fetchJson(`/cart/${state.userId}`);
    applyCartResponse(payload);
}

async function fetchOrders() {
    const payload = await fetchJson(`/orders/user/${state.userId}`);
    state.orders = Array.isArray(payload.orders)
        ? payload.orders.sort((left, right) => right.created_at - left.created_at)
        : [];
}

async function addToCart(productId) {
    const product = state.products.find(entry => entry.id === productId);
    if (!product) {
        return;
    }

    try {
        const payload = await fetchJson(`/cart/${state.userId}/add`, {
            method: "POST",
            body: JSON.stringify({
                product_id: product.id,
                product_name: product.name,
                price: product.price,
                quantity: 1,
                category: product.category,
            }),
        });
        applyCartResponse(payload);
        renderCart();
        updateSummaryMetrics();
        setCheckoutMessage(`${product.name} added to cart.`, "success");
    } catch (error) {
        setCheckoutMessage(error.message, "error");
    }
}

async function updateCartQuantity(productId, quantity) {
    try {
        const payload = await fetchJson(`/cart/${state.userId}/items/${productId}`, {
            method: "PUT",
            body: JSON.stringify({ quantity }),
        });
        applyCartResponse(payload);
        renderCart();
        updateSummaryMetrics();
    } catch (error) {
        setCheckoutMessage(error.message, "error");
    }
}

async function removeCartItem(productId) {
    try {
        const payload = await fetchJson(`/cart/${state.userId}/remove/${productId}`, {
            method: "DELETE",
        });
        applyCartResponse(payload);
        renderCart();
        updateSummaryMetrics();
    } catch (error) {
        setCheckoutMessage(error.message, "error");
    }
}

async function submitOrder(event) {
    event.preventDefault();

    if (!state.cart.items.length) {
        setCheckoutMessage("Add at least one item before placing an order.", "error");
        return;
    }

    const customerName = elements.customerName.value.trim();
    const customerEmail = elements.customerEmail.value.trim();
    const customerAddress = elements.customerAddress.value.trim();
    const paymentMethod = elements.paymentMethod.value;

    if (customerName.length < 2) {
        setCheckoutMessage("Enter a valid customer name.", "error");
        return;
    }

    if (customerAddress.length < 10) {
        setCheckoutMessage("Enter a complete delivery address.", "error");
        return;
    }

    elements.checkoutButton.disabled = true;
    elements.checkoutButton.textContent = "Processing order...";
    saveCheckoutDefaults(customerName, customerEmail);

    try {
        const order = await fetchJson("/orders", {
            method: "POST",
            body: JSON.stringify({
                user_id: state.userId,
                items: state.cart.items.map(item => ({
                    product_id: item.product_id,
                    product_name: item.product_name,
                    price: item.price,
                    quantity: item.quantity,
                })),
                address: customerAddress,
                payment_method: paymentMethod,
                customer_name: customerName,
                customer_email: customerEmail || null,
            }),
        });

        setCheckoutMessage(`Order ${order.order_id} confirmed.`, "success");
        await Promise.all([fetchCart(), fetchOrders()]);
        renderCart();
        renderOrders(order.order_id);
        updateSummaryMetrics();
    } catch (error) {
        setCheckoutMessage(error.message, "error");
    } finally {
        elements.checkoutButton.disabled = false;
        elements.checkoutButton.textContent = "Place secure order";
    }
}

function applyCartResponse(payload) {
    state.cart = {
        items: Array.isArray(payload.items) ? payload.items : [],
        total: Number(payload.total || 0),
        item_count: Number(payload.item_count || 0),
    };
}

function renderCategoryChips() {
    const categories = ["all", ...new Set(state.products.map(product => product.category))];
    elements.categoryChips.innerHTML = categories
        .map(category => {
            const activeClass = state.filters.category === category ? "active" : "";
            const label = category === "all" ? "All categories" : titleCase(category);
            return `<button class="chip ${activeClass}" type="button" data-category="${escapeHtml(category)}">${escapeHtml(label)}</button>`;
        })
        .join("");
}

function renderProducts() {
    const filteredProducts = getFilteredProducts();
    elements.resultsCount.textContent = `${filteredProducts.length} products available`;

    elements.emptyState.classList.toggle("hidden", filteredProducts.length !== 0);

    elements.productGrid.innerHTML = filteredProducts
        .map((product, index) => {
            const tone = escapeHtml(product.category);
            return `
                <article class="product-card" data-tone="${tone}" style="animation-delay:${index * 40}ms">
                    <div class="product-visual">
                        <span class="badge">${escapeHtml(product.badge || "Curated")}</span>
                        <span class="category-label">${escapeHtml(titleCase(product.category))}</span>
                    </div>
                    <div class="product-meta">
                        <span>${Number(product.rating).toFixed(1)} rating</span>
                        <span>${escapeHtml(product.eta || "Dispatch in 48 hours")}</span>
                    </div>
                    <h3>${escapeHtml(product.name)}</h3>
                    <p class="product-description">${escapeHtml(product.description || "Premium product from the live catalog.")}</p>
                    <div class="product-footer">
                        <div class="price-block">
                            <span class="price-label">${product.stock} units ready</span>
                            <strong class="price-value">${formatCurrency(product.price)}</strong>
                        </div>
                        <button class="primary-btn" type="button" data-add-product="${escapeHtml(product.id)}">Add to cart</button>
                    </div>
                </article>
            `;
        })
        .join("");
}

function renderCart() {
    elements.cartCount.textContent = state.cart.item_count;
    elements.cartQuantity.textContent = `${state.cart.item_count}`;
    elements.cartTotal.textContent = formatCurrency(state.cart.total);

    if (!state.cart.items.length) {
        elements.cartItems.innerHTML = `
            <div class="cart-empty">
                <h3>Your cart is empty.</h3>
                <p>Add products from the catalog to start the checkout flow.</p>
            </div>
        `;
        return;
    }

    elements.cartItems.innerHTML = state.cart.items
        .map(item => {
            const subtotal = Number(item.price) * Number(item.quantity);
            return `
                <article class="cart-item">
                    <div class="cart-item-header">
                        <div>
                            <h3>${escapeHtml(item.product_name)}</h3>
                            <p>${escapeHtml(titleCase(item.category || "General"))}</p>
                        </div>
                        <strong>${formatCurrency(subtotal)}</strong>
                    </div>
                    <div class="cart-actions">
                        <div class="quantity-control">
                            <button type="button" data-action="decrement" data-product-id="${escapeHtml(item.product_id)}">-</button>
                            <span>${item.quantity}</span>
                            <button type="button" data-action="increment" data-product-id="${escapeHtml(item.product_id)}">+</button>
                        </div>
                        <button class="text-action" type="button" data-action="remove" data-product-id="${escapeHtml(item.product_id)}">Remove</button>
                    </div>
                </article>
            `;
        })
        .join("");
}

function renderOrders(highlightOrderId) {
    if (!state.orders.length) {
        elements.lastOrderCard.classList.add("hidden");
        elements.ordersList.innerHTML = `
            <div class="order-placeholder">
                <h3>No orders yet.</h3>
                <p>Place an order from the cart drawer to populate the order ledger.</p>
            </div>
        `;
        return;
    }

    const [latestOrder, ...remainingOrders] = state.orders;
    elements.lastOrderCard.classList.remove("hidden");
    elements.lastOrderCard.innerHTML = `
        <p class="eyebrow">Latest confirmation</p>
        <h3>${escapeHtml(latestOrder.order_id)}</h3>
        <div class="spotlight-grid">
            <div>
                <span>Status</span>
                <strong>${escapeHtml(latestOrder.status)}</strong>
            </div>
            <div>
                <span>Total</span>
                <strong>${formatCurrency(latestOrder.total)}</strong>
            </div>
            <div>
                <span>Payment</span>
                <strong>${escapeHtml(latestOrder.payment_method || "razorpay")}</strong>
            </div>
            <div>
                <span>Items</span>
                <strong>${latestOrder.item_count || countItems(latestOrder.items)}</strong>
            </div>
        </div>
    `;

    elements.ordersList.innerHTML = remainingOrders
        .map(order => renderOrderCard(order, highlightOrderId))
        .join("");

    if (!remainingOrders.length) {
        elements.ordersList.innerHTML = `
            <div class="order-placeholder">
                <h3>Only one order so far.</h3>
                <p>New orders will stack here automatically after checkout.</p>
            </div>
        `;
    }
}

function renderOrderCard(order, highlightOrderId) {
    const itemCount = order.item_count || countItems(order.items);
    const note = `${itemCount} items, ${escapeHtml(order.address)}`;
    const tag = order.order_id === highlightOrderId ? "Newest" : "Confirmed";

    return `
        <article class="order-card">
            <div class="order-card-header">
                <div>
                    <p class="eyebrow">Order record</p>
                    <h3>${escapeHtml(order.order_id)}</h3>
                </div>
                <span class="order-tag">${tag}</span>
            </div>
            <div class="order-card-grid">
                <div>
                    <span>Total</span>
                    <strong>${formatCurrency(order.total)}</strong>
                </div>
                <div>
                    <span>Placed</span>
                    <strong>${formatTimestamp(order.created_at)}</strong>
                </div>
                <div>
                    <span>Payment</span>
                    <strong>${escapeHtml(order.payment_method || "razorpay")}</strong>
                </div>
                <div>
                    <span>Status</span>
                    <strong>${escapeHtml(order.status)}</strong>
                </div>
            </div>
            <p class="order-notes">${note}</p>
        </article>
    `;
}

function updateSummaryMetrics() {
    elements.heroCatalogCount.textContent = `${state.products.length} products`;
    elements.heroCartCount.textContent = `${state.cart.item_count} items`;
    elements.heroOrderCount.textContent = `${state.orders.length} orders`;
    elements.summaryCartTotal.textContent = formatCurrency(state.cart.total);
    elements.summaryOrderCount.textContent = `${state.orders.length}`;
}

function setGatewayHealth(isHealthy) {
    elements.gatewayPill.classList.remove("healthy", "unhealthy");
    if (isHealthy) {
        elements.gatewayPill.classList.add("healthy");
        elements.gatewayPill.textContent = "Gateway online";
        elements.gatewayStatus.textContent = "Healthy";
    } else {
        elements.gatewayPill.classList.add("unhealthy");
        elements.gatewayPill.textContent = "Gateway degraded";
        elements.gatewayStatus.textContent = "Fallback mode";
    }
}

function setLoading(isLoading) {
    elements.loader.classList.toggle("hidden", !isLoading);
}

function setCheckoutMessage(message, kind) {
    elements.checkoutFeedback.textContent = message;
    elements.checkoutFeedback.classList.remove("success", "error");
    if (kind) {
        elements.checkoutFeedback.classList.add(kind);
    }
}

function hydrateCheckoutFields() {
    elements.customerName.value = window.localStorage.getItem("northstar.customerName") || "";
    elements.customerEmail.value = window.localStorage.getItem("northstar.customerEmail") || "";
}

function saveCheckoutDefaults(customerName, customerEmail) {
    window.localStorage.setItem("northstar.customerName", customerName);
    window.localStorage.setItem("northstar.customerEmail", customerEmail);
}

function openCart() {
    elements.cartOverlay.classList.remove("hidden");
    document.body.classList.add("cart-open");
}

function closeCart() {
    elements.cartOverlay.classList.add("hidden");
    document.body.classList.remove("cart-open");
}

function scrollToCatalog() {
    document.getElementById("catalog").scrollIntoView({ behavior: "smooth", block: "start" });
}

function getFilteredProducts() {
    const filtered = state.products.filter(product => {
        const matchesCategory =
            state.filters.category === "all" || product.category === state.filters.category;
        const haystack = `${product.name} ${product.description} ${product.category}`.toLowerCase();
        const matchesQuery = !state.filters.query || haystack.includes(state.filters.query);
        return matchesCategory && matchesQuery;
    });

    if (state.filters.sort === "rating") {
        filtered.sort((left, right) => right.rating - left.rating);
    }

    if (state.filters.sort === "price-asc") {
        filtered.sort((left, right) => left.price - right.price);
    }

    if (state.filters.sort === "price-desc") {
        filtered.sort((left, right) => right.price - left.price);
    }

    return filtered;
}

async function fetchJson(path, options = {}) {
    const config = {
        ...options,
        headers: {
            "Content-Type": "application/json",
            ...(options.headers || {}),
        },
    };

    const response = await fetch(`${API_BASE}${path}`, config);
    const contentType = response.headers.get("content-type") || "";
    const payload = contentType.includes("application/json") ? await response.json() : null;

    if (!response.ok) {
        const detail = payload && payload.detail ? payload.detail : `Request failed with ${response.status}`;
        throw new Error(Array.isArray(detail) ? detail.join(", ") : detail);
    }

    return payload;
}

function getOrCreateUserId() {
    const existing = window.localStorage.getItem("northstar.userId");
    if (existing) {
        return existing;
    }

    const generated = `guest-${Math.random().toString(36).slice(2, 10)}`;
    window.localStorage.setItem("northstar.userId", generated);
    return generated;
}

function countItems(items = []) {
    return items.reduce((sum, item) => sum + Number(item.quantity || 0), 0);
}

function formatCurrency(value) {
    return CURRENCY_FORMATTER.format(Number(value || 0));
}

function formatTimestamp(value) {
    if (!value) {
        return "Just now";
    }
    return new Date(Number(value) * 1000).toLocaleString("en-IN", {
        day: "numeric",
        month: "short",
        hour: "2-digit",
        minute: "2-digit",
    });
}

function titleCase(value) {
    return value
        .split(/[\s-]+/)
        .filter(Boolean)
        .map(part => part.charAt(0).toUpperCase() + part.slice(1))
        .join(" ");
}

function escapeHtml(value) {
    return String(value)
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#39;");
}
