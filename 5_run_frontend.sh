#!/bin/bash

# Step 5: Run Local Frontend
# This script starts the local web interface for testing the agent
#
# Usage: ./5_run_frontend.sh

echo "🌐 Magic Mirror - Local Frontend"
echo "================================="
echo ""

# Check if backend is running
if ! curl -s http://localhost:6000/api/health > /dev/null 2>&1; then
    echo "⚠️  Warning: Backend doesn't appear to be running!"
    echo ""
    echo "Please start the backend first:"
    echo "  ./2_run_backend.sh"
    echo ""
    read -p "Continue anyway? (y/n): " continue_run
    if [ "$continue_run" != "y" ] && [ "$continue_run" != "Y" ]; then
        exit 1
    fi
    echo ""
fi

# Configuration
ENV_NAME="nanda_agent"

# Activate conda environment (needed for Python)
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME 2>/dev/null || true

echo "🚀 Starting frontend server..."
echo ""
echo "📍 Frontend: http://localhost:8080"
echo "🔗 Backend:  http://localhost:6000"
echo ""
echo "💡 Opening browser in 2 seconds..."
echo "   Press Ctrl+C to stop"
echo ""

# Wait 2 seconds then open browser
sleep 2 &
sleep_pid=$!

# Start server in background briefly to let it initialize
python local_frontend/server.py &
server_pid=$!

# Wait for sleep to finish
wait $sleep_pid

# Open browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    open "http://localhost:8080"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open "http://localhost:8080" 2>/dev/null || true
fi

# Bring server to foreground
wait $server_pid
