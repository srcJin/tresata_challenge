#!/bin/bash

# EC2 Deployment Test Script
# Tests both HTTP and HTTPS endpoints

echo "🧪 Testing EC2 Magic Mirror Deployment"
echo "======================================="

# Configuration
EC2_IP="${1:-18.224.228.207}"
AGENT_PORT="${2:-3737}"
API_PORT="${3:-6001}"

echo ""
echo "📍 Target: $EC2_IP"
echo "🔌 Agent Port: $AGENT_PORT"
echo "🔌 API Port: $API_PORT"
echo ""

# Test 1: HTTP Agent Bridge Health
echo "Test 1: Agent Bridge Health (HTTP)"
echo "-----------------------------------"
HTTP_AGENT_URL="http://$EC2_IP:$AGENT_PORT/api/health"
echo "Testing: $HTTP_AGENT_URL"
HTTP_AGENT_RESULT=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$HTTP_AGENT_URL" 2>&1)
if [ "$HTTP_AGENT_RESULT" = "200" ]; then
    echo "✅ HTTP Agent Bridge is accessible"
else
    echo "❌ HTTP Agent Bridge failed (Status: $HTTP_AGENT_RESULT)"
fi
echo ""

# Test 2: HTTPS Agent Bridge Health
echo "Test 2: Agent Bridge Health (HTTPS)"
echo "------------------------------------"
HTTPS_AGENT_URL="https://$EC2_IP:$AGENT_PORT/api/health"
echo "Testing: $HTTPS_AGENT_URL"
HTTPS_AGENT_RESULT=$(curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$HTTPS_AGENT_URL" 2>&1)
if [ "$HTTPS_AGENT_RESULT" = "200" ]; then
    echo "✅ HTTPS Agent Bridge is accessible"
else
    echo "❌ HTTPS Agent Bridge failed (Status: $HTTPS_AGENT_RESULT)"
fi
echo ""

# Test 3: HTTP API Server Health
echo "Test 3: API Server Health (HTTP)"
echo "---------------------------------"
HTTP_API_URL="http://$EC2_IP:$API_PORT/api/health"
echo "Testing: $HTTP_API_URL"
HTTP_API_RESULT=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$HTTP_API_URL" 2>&1)
if [ "$HTTP_API_RESULT" = "200" ]; then
    echo "✅ HTTP API Server is accessible"
else
    echo "❌ HTTP API Server failed (Status: $HTTP_API_RESULT)"
fi
echo ""

# Test 4: HTTPS API Server Health
echo "Test 4: API Server Health (HTTPS)"
echo "----------------------------------"
HTTPS_API_URL="https://$EC2_IP:$API_PORT/api/health"
echo "Testing: $HTTPS_API_URL"
HTTPS_API_RESULT=$(curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$HTTPS_API_URL" 2>&1)
if [ "$HTTPS_API_RESULT" = "200" ]; then
    echo "✅ HTTPS API Server is accessible"
else
    echo "❌ HTTPS API Server failed (Status: $HTTPS_API_RESULT)"
fi
echo ""

# Test 5: Send a test message via A2A
echo "Test 5: Send Test Message via A2A"
echo "----------------------------------"
if [ "$HTTPS_AGENT_RESULT" = "200" ]; then
    A2A_URL="https://$EC2_IP:$AGENT_PORT/a2a"
    echo "Sending to: $A2A_URL"
    A2A_RESPONSE=$(curl -k -s -X POST "$A2A_URL" \
        -H "Content-Type: application/json" \
        -d '{
            "content": {"type": "text", "text": "Test message"},
            "role": "user"
        }' 2>&1)

    if echo "$A2A_RESPONSE" | grep -q "role"; then
        echo "✅ A2A endpoint responds correctly"
        echo "Response preview: $(echo "$A2A_RESPONSE" | head -c 100)..."
    else
        echo "❌ A2A endpoint error"
        echo "Response: $A2A_RESPONSE"
    fi
elif [ "$HTTP_AGENT_RESULT" = "200" ]; then
    A2A_URL="http://$EC2_IP:$AGENT_PORT/a2a"
    echo "Sending to: $A2A_URL"
    A2A_RESPONSE=$(curl -s -X POST "$A2A_URL" \
        -H "Content-Type: application/json" \
        -d '{
            "content": {"type": "text", "text": "Test message"},
            "role": "user"
        }' 2>&1)

    if echo "$A2A_RESPONSE" | grep -q "role"; then
        echo "✅ A2A endpoint responds correctly"
        echo "Response preview: $(echo "$A2A_RESPONSE" | head -c 100)..."
    else
        echo "❌ A2A endpoint error"
        echo "Response: $A2A_RESPONSE"
    fi
else
    echo "⚠️  Skipping - no accessible endpoint found"
fi
echo ""

# Summary
echo "📊 Summary"
echo "=========="
HTTPS_READY=false
HTTP_READY=false

if [ "$HTTPS_AGENT_RESULT" = "200" ] && [ "$HTTPS_API_RESULT" = "200" ]; then
    HTTPS_READY=true
    echo "✅ HTTPS Mode: Ready for NANDA Chat"
    echo "   - Agent: https://$EC2_IP:$AGENT_PORT/a2a"
    echo "   - API: https://$EC2_IP:$API_PORT"
elif [ "$HTTP_AGENT_RESULT" = "200" ] && [ "$HTTP_API_RESULT" = "200" ]; then
    HTTP_READY=true
    echo "⚠️  HTTP Mode: Working but NANDA Chat needs HTTPS"
    echo "   - Agent: http://$EC2_IP:$AGENT_PORT/a2a"
    echo "   - API: http://$EC2_IP:$API_PORT"
else
    echo "❌ Deployment Not Ready"
fi

echo ""
echo "🔧 Next Steps"
echo "============="

if [ "$HTTPS_READY" = true ]; then
    echo "✅ Your deployment is ready!"
    echo "   Register at: https://chat.nanda-registry.com:6900"
    echo "   Agent URL: https://$EC2_IP:$AGENT_PORT/a2a"
    echo "   API URL: https://$EC2_IP:$API_PORT"
elif [ "$HTTP_READY" = true ]; then
    echo "⚠️  Enable HTTPS for NANDA Chat compatibility:"
    echo "   1. Generate SSL certificate (see EC2_FIX.md)"
    echo "   2. Set ENABLE_SSL=true in .env"
    echo "   3. Restart the agent"
else
    echo "❌ Troubleshooting needed:"
    echo "   1. Check EC2 Security Group (ports $AGENT_PORT, $API_PORT)"
    echo "   2. Check if agent is running: ps aux | grep langchain_diy"
    echo "   3. Check server logs for errors"
    echo "   4. Verify .env configuration"
fi

echo ""
