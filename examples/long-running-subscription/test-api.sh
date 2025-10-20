#!/usr/bin/env bash
# Simple script to test the long-running subscription API

set -e

HOST="${API_HOST:-localhost}"
PORT="${API_PORT:-8080}"
BASE_URL="http://$HOST:$PORT"

echo "Testing Long-Running Subscription API at $BASE_URL"
echo ""

# Health check
echo "Health Check:"
curl -s "$BASE_URL/health" | jq .
echo ""
echo ""

# Query initial state
echo "Initial Projection State:"
INITIAL_STATE=$(curl -s "$BASE_URL/projection")
echo "$INITIAL_STATE" | jq .
INITIAL_COUNT=$(echo "$INITIAL_STATE" | jq -r '.currentCount')
echo ""
echo "Initial count: $INITIAL_COUNT"
echo ""

# Add some events
echo "Adding 5 events..."
ADDED_SUM=0
for i in {1..5}; do
  echo "  Event $i: Adding amount $i"
  curl -s -X POST "$BASE_URL/events" \
    -H 'Content-Type: application/json' \
    -d "{\"amount\": $i}" | jq -r '.message'
  ADDED_SUM=$((ADDED_SUM + i))
  sleep 0.5
done
echo ""
echo "Total added: $ADDED_SUM"

# Wait a bit for projection to process
echo "Waiting 2 seconds for projection to process..."
sleep 2
echo ""

# Query final state
echo "Final Projection State:"
FINAL_STATE=$(curl -s "$BASE_URL/projection")
echo "$FINAL_STATE" | jq .
FINAL_COUNT=$(echo "$FINAL_STATE" | jq -r '.currentCount')
echo ""

# Calculate expected
EXPECTED_COUNT=$((INITIAL_COUNT + ADDED_SUM))

echo "Test complete!"
echo "Initial count: $INITIAL_COUNT"
echo "Events added: $ADDED_SUM (1+2+3+4+5)"
echo "Expected final count: $EXPECTED_COUNT"
echo "Actual final count: $FINAL_COUNT"
echo ""

if [ "$FINAL_COUNT" -eq "$EXPECTED_COUNT" ]; then
  echo "SUCCESS: Counts match!"
else
  echo "FAILURE: Expected $EXPECTED_COUNT but got $FINAL_COUNT"
  exit 1
fi
