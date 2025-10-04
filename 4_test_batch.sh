#!/bin/bash

# Step 4: Test Agent in Batch Mode
# This script runs automated batch tests and saves results
#
# Usage: ./4_test_batch.sh
# or: ./4_test_batch.sh questions.txt (custom questions file)

echo "🧪 NANDA Agent - Batch Testing"
echo "==============================="

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

# Run the batch test script
if [ -n "$1" ]; then
    # Custom questions file
    echo "📄 Using custom questions from: $1"
    echo ""
    python test_local_batch.py "$1"
else
    # Default questions
    echo "📋 Using default test questions"
    echo ""
    python test_local_batch.py
fi

# Show results directory
echo ""
echo "💾 All test results are saved in: test_results/"
echo ""
