#!/bin/bash
# scripts/load-test.sh
# Simulates Flipkart Big Billion Days flash sale traffic spike
# Watch HPA scale pods in real time: kubectl get hpa -n ecommerce -w

set -e

GATEWAY_URL=${1:-"http://localhost:8080"}
CONCURRENCY=${2:-50}
DURATION=${3:-60}

echo "🛒 Flash Sale Load Test"
echo "  Target:      $GATEWAY_URL"
echo "  Concurrency: $CONCURRENCY parallel users"
echo "  Duration:    ${DURATION}s"
echo ""

# Check if hey is installed (HTTP load generator)
if ! command -v hey &>/dev/null; then
  echo "Installing hey (HTTP load tool)..."
  go install github.com/rakyll/hey@latest 2>/dev/null || \
  apt-get install -y hey 2>/dev/null || \
  brew install hey 2>/dev/null || {
    echo "Please install 'hey': https://github.com/rakyll/hey"
    exit 1
  }
fi

echo "📦 Phase 1: Catalog browsing (simulates users browsing products)..."
hey -z ${DURATION}s -c $CONCURRENCY -q 10 \
  "${GATEWAY_URL}/products" &

echo "🛍️  Phase 2: Product detail views..."
hey -z ${DURATION}s -c $((CONCURRENCY/2)) -q 5 \
  "${GATEWAY_URL}/products/p1" &

echo "🛒 Phase 3: Cart adds (peak checkout pressure)..."
for i in $(seq 1 10); do
  curl -s -X POST "${GATEWAY_URL}/cart/user${i}/add" \
    -H "Content-Type: application/json" \
    -d "{\"product_id\":\"p1\",\"product_name\":\"Headphones\",\"price\":1999.0,\"quantity\":1}" \
    > /dev/null &
done

echo ""
echo "⏳ Running for ${DURATION}s... Watch pods scale:"
echo "   kubectl get hpa -n ecommerce -w"
echo "   kubectl get pods -n ecommerce -w"
echo ""

wait
echo "✅ Load test complete!"
echo ""
echo "📊 Check results in GCP Cloud Monitoring:"
echo "   https://console.cloud.google.com/monitoring"
