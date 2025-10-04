#!/bin/bash

# Step 2: Run NANDA Agent Backend
# This script starts the magic mirror agent server
#
# Usage: ./2_run_backend.sh [agent_script]
# Example: ./2_run_backend.sh (uses default magic mirror)
# Example: ./2_run_backend.sh path/to/custom_agent.py

set -e  # Exit on error

echo "🚀 NANDA Agent - Backend Server"
echo "================================"

# Configuration
ENV_NAME="nanda_agent"
PROJECT_ROOT="$(pwd)"
DEFAULT_AGENT="tresata_challenge_adapter/nanda_adapter/examples/langchain_diy.py"

# Get agent script from argument or use default
if [ -n "$1" ]; then
    AGENT_SCRIPT="$1"
else
    AGENT_SCRIPT="$DEFAULT_AGENT"
fi

# Check if agent script exists
if [ ! -f "$AGENT_SCRIPT" ]; then
    echo "❌ Agent script not found: $AGENT_SCRIPT"
    exit 1
fi

# Check for .env file
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "   Create $ENV_FILE with:"
    echo "   ANTHROPIC_API_KEY=your-api-key"
    echo "   DOMAIN_NAME=localhost"
    echo ""
    read -p "Continue anyway? (y/n): " continue_run
    if [ "$continue_run" != "y" ] && [ "$continue_run" != "Y" ]; then
        exit 1
    fi
fi

# Activate conda environment
echo "🔄 Activating conda environment: $ENV_NAME"
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

# Display configuration
echo ""
echo "📋 Configuration:"
echo "   Agent: $AGENT_SCRIPT"
echo "   Config: $ENV_FILE"
echo "   Working Dir: $PROJECT_ROOT"
echo ""
echo "🌐 Server will be available at:"
echo "   - Local: http://localhost:6000"
echo "   - Web UI: http://localhost:6000/api/health"
echo "   - Send Task: http://localhost:6000/tasks/send"
echo ""
echo "💡 To connect via NANDA Chat:"
echo "   1. Open https://chat.nanda-registry.com:6900"
echo "   2. Register your agent using the enrollment URL (check logs)"
echo ""
echo "✨ Starting Magic Mirror Agent..."
echo "   Press Ctrl+C to stop"
echo ""

# Run the agent
python "$AGENT_SCRIPT"
