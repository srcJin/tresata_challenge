#!/bin/bash

# Step 3: Test Agent Locally (CLI Interactive)
# This script provides a CLI chat interface to test your agent interactively
#
# Usage: ./3_test_local.sh
# or: ./3_test_local.sh "Your question here" (for single question)

echo "🧪 NANDA Agent - CLI Test Interface"
echo "===================================="

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

# Run the CLI test script
if [ -n "$1" ]; then
    # Single question mode
    python test_local_cli.py "$@"
else
    # Interactive mode
    python test_local_cli.py
fi
