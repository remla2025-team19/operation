#!/bin/bash
# scripts/generate-experiment-traffic.sh

echo "Starting canary experiment traffic generation..."

# Function to generate user ID for sticky sessions
generate_user_id() {
    echo "user-$((RANDOM%100))"
}

# Generate baseline traffic with sticky sessions
for i in {1..1000}; do
    USER_ID=$(generate_user_id)
    
    # 90% normal traffic
    if [ $((RANDOM%10)) -ne 0 ]; then
        curl -H "X-User: $USER_ID" \
             -H "Host: app.local" \
             http://192.168.56.91/predict \
             -d '{"text": "This is a test sentiment"}' \
             -H "Content-Type: application/json" \
             -s -o /dev/null
    else
        # 10% canary traffic
        curl -H "X-User: $USER_ID" \
             -H "X-Experiment: canary" \
             -H "Host: app.local" \
             http://192.168.56.91/predict \
             -d '{"text": "This is a canary test"}' \
             -H "Content-Type: application/json" \
             -s -o /dev/null
    fi
    
    # Small delay to simulate realistic traffic
    sleep 0.1
done

echo "Traffic generation complete. Check Grafana dashboard for results."

# Verify sticky session routing
echo "Testing sticky session consistency..."
for i in {1..5}; do
    echo "Request $i:"
    curl -H "X-User: test-user-123" \
         -H "Host: app.local" \
         http://192.168.56.91/ \
         -s | grep -o '"version":"[^"]*"' || echo "No version found"
done
