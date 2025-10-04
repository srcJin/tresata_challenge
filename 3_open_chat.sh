#!/bin/bash

# Step 3: Open NANDA Chat Interface
# This script opens the NANDA Chat web interface in your browser
#
# Usage: ./3_open_chat.sh

echo "💬 NANDA Chat Interface"
echo "======================="
echo ""
echo "Opening NANDA Chat in your browser..."
echo ""
echo "📍 URL: https://chat.nanda-registry.com:6900"
echo ""
echo "💡 How to use:"
echo "   1. Make sure your backend is running (./2_run_backend.sh)"
echo "   2. Look for the enrollment/registration URL in backend logs"
echo "   3. Register your agent on NANDA Chat"
echo "   4. Start chatting with your magic mirror agent!"
echo ""

# Detect OS and open browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "https://chat.nanda-registry.com:6900"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open &> /dev/null; then
        xdg-open "https://chat.nanda-registry.com:6900"
    else
        echo "Please open this URL manually: https://chat.nanda-registry.com:6900"
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows
    start "https://chat.nanda-registry.com:6900"
else
    echo "⚠️  Could not detect OS. Please open manually:"
    echo "   https://chat.nanda-registry.com:6900"
fi

echo ""
echo "✅ If the browser didn't open, visit:"
echo "   https://chat.nanda-registry.com:6900"
echo ""
