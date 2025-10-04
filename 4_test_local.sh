#!/bin/bash

# Step 4: Test Agent Locally (Interactive)
# This script provides a local chat interface to test your agent
#
# Usage: ./4_test_local.sh
# or: ./4_test_local.sh "Your question here" (for single question)

echo "🧪 NANDA Agent - Local Test Interface"
echo "======================================"

# Configuration
ENV_NAME="nanda_agent"

# Check for .env file
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "   Create .env with your ANTHROPIC_API_KEY"
    exit 1
fi

# Activate conda environment
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

# Run the test script
if [ -n "$1" ]; then
    # Single question mode
    python test_agent_local.py "$@"
else
    # Interactive mode
    python test_agent_local.py
fi
