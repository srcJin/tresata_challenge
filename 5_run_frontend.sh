#!/bin/bash

# Step 5: Open Local Frontend
# Opens the Magic Mirror chat interface (simple HTML file)
#
# Usage: ./5_run_frontend.sh

echo "🌐 Magic Mirror - Local Frontend"
echo "================================="
echo ""

# Get absolute path to frontend
FRONTEND_PATH="$(pwd)/local_frontend/index.html"

# Check if backend is running on port 3737
PORT=${PORT:-3737}
if ! curl -s http://localhost:$PORT/api/health > /dev/null 2>&1; then
    echo "⚠️  Warning: Backend doesn't appear to be running on port $PORT!"
    echo ""
    echo "Start the backend first:"
    echo "  ./2_run_backend.sh"
    echo ""
fi

echo "🪞 Opening Magic Mirror Chat Interface..."
echo ""
echo "📍 Frontend: file://$FRONTEND_PATH"
echo "📍 Backend API: http://localhost:$PORT"
echo ""
echo "💡 Using port $PORT to avoid browser blocking"
echo ""

# Open browser with local file
if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$FRONTEND_PATH"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open "$FRONTEND_PATH" 2>/dev/null || true
else
    echo "Please open manually: $FRONTEND_PATH"
fi

echo "✨ Browser opened!"
echo ""
