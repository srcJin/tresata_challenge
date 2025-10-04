#!/bin/bash

# Step 1: Setup Environment for NANDA Agent
# This script creates the conda environment and installs all dependencies
#
# Usage: ./1_setup_environment.sh

set -e  # Exit on error

echo "🔧 NANDA Agent - Environment Setup"
echo "===================================="

# Configuration
ENV_NAME="nanda_agent"
PYTHON_VERSION="3.11"

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "❌ Conda is not installed. Please install Anaconda or Miniconda first."
    echo "Visit: https://docs.conda.io/en/latest/miniconda.html"
    exit 1
fi

# Create or reuse conda environment
echo ""
if conda env list | grep -q "^$ENV_NAME "; then
    echo "✅ Using existing conda environment: $ENV_NAME"
else
    echo "📦 Creating conda environment: $ENV_NAME"
    conda create -n $ENV_NAME python=$PYTHON_VERSION -y
fi

# Activate environment
echo "🔄 Activating conda environment..."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

# Navigate to adapter directory for installation
cd tresata_challenge_adapter

# Install dependencies
echo ""
echo "📥 Installing NANDA dependencies..."
pip install --upgrade pip
pip install nanda-adapter langchain-core langchain-anthropic crewai python-dotenv

echo ""
echo "✅ Environment setup complete!"
echo ""
echo "📋 Summary:"
echo "   Environment: $ENV_NAME"
echo "   Python: $(python --version)"
echo "   Location: $(which python)"
echo ""
echo "Next steps:"
echo "  1. Create .env file with your ANTHROPIC_API_KEY (see .env.example)"
echo "  2. Run ./2_run_backend.sh to start the agent"
echo "  3. Run ./3_open_chat.sh to open NANDA Chat"
echo ""
