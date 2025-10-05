#!/bin/bash

# EC2 One-Click Setup Script for Magic Mirror Agent
# Run this script on your EC2 instance to configure everything

set -e  # Exit on error

echo "🚀 Magic Mirror Agent - One-Click Setup"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Get API Key from user
echo "Step 1: Anthropic API Key"
echo "-------------------------"
read -p "Enter your ANTHROPIC_API_KEY: " API_KEY

if [ -z "$API_KEY" ]; then
    echo -e "${RED}❌ API key cannot be empty${NC}"
    exit 1
fi

echo -e "${GREEN}✅ API key received${NC}"
echo ""

# Step 2: Detect EC2 IP
echo "Step 2: Detecting EC2 Public IP"
echo "--------------------------------"
EC2_IP=$(curl -s http://checkip.amazonaws.com)
if [ -z "$EC2_IP" ]; then
    echo -e "${RED}❌ Failed to detect EC2 IP${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Detected IP: $EC2_IP${NC}"
echo ""

# Step 3: Set environment variables
echo "Step 3: Configuring Environment Variables"
echo "------------------------------------------"

# Remove old NANDA config from .bashrc if exists
sed -i '/# NANDA Agent Environment Variables/,/^$/d' ~/.bashrc 2>/dev/null || true

# Add new configuration
cat >> ~/.bashrc << EOF

# NANDA Agent Environment Variables
export ANTHROPIC_API_KEY=$API_KEY
export DOMAIN_NAME=$EC2_IP
export PORT=6000
export API_PORT=6001
export ENABLE_SSL=true
EOF

# Load immediately
export ANTHROPIC_API_KEY=$API_KEY
export DOMAIN_NAME=$EC2_IP
export PORT=6000
export API_PORT=6001
export ENABLE_SSL=true

echo -e "${GREEN}✅ Environment variables configured${NC}"
echo ""

# Step 4: Verify conda environment
echo "Step 4: Checking Conda Environment"
echo "-----------------------------------"
if ! command -v conda &> /dev/null; then
    echo -e "${RED}❌ Conda not found. Please install Miniconda first.${NC}"
    exit 1
fi

ENV_NAME="nanda_agent"
if conda env list | grep -q "^$ENV_NAME "; then
    echo -e "${GREEN}✅ Conda environment '$ENV_NAME' exists${NC}"
else
    echo -e "${YELLOW}📦 Creating conda environment '$ENV_NAME'...${NC}"
    conda create -n $ENV_NAME python=3.11 -y
    echo -e "${GREEN}✅ Conda environment created${NC}"
fi
echo ""

# Step 5: Install dependencies
echo "Step 5: Installing Python Dependencies"
echo "---------------------------------------"
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME

cd ~/tresata_challenge/tresata_challenge_adapter
pip install --upgrade pip -q
pip install nanda-adapter langchain-core langchain-anthropic flask flask-cors python-dotenv -q

echo -e "${GREEN}✅ Dependencies installed${NC}"
cd ~/tresata_challenge
echo ""

# Step 6: Generate SSL certificates
echo "Step 6: Setting Up SSL Certificates"
echo "------------------------------------"
if [ -f "fullchain.pem" ] && [ -s "fullchain.pem" ]; then
    echo -e "${GREEN}✅ SSL certificate already exists${NC}"
else
    echo -e "${YELLOW}🔐 Generating self-signed SSL certificate...${NC}"
    openssl req -x509 -newkey rsa:4096 -nodes \
        -keyout privkey.pem \
        -out fullchain.pem \
        -days 365 \
        -subj "/CN=$EC2_IP" 2>/dev/null

    if [ -s "fullchain.pem" ] && [ -s "privkey.pem" ]; then
        echo -e "${GREEN}✅ SSL certificate generated${NC}"
    else
        echo -e "${RED}❌ SSL certificate generation failed${NC}"
        exit 1
    fi
fi
echo ""

# Step 7: Configure firewall (UFW)
echo "Step 7: Checking Firewall Configuration"
echo "----------------------------------------"
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status | head -1)
    if echo "$UFW_STATUS" | grep -q "active"; then
        echo -e "${YELLOW}🔥 UFW is active, opening ports...${NC}"
        sudo ufw allow 6000/tcp >/dev/null 2>&1 || true
        sudo ufw allow 6001/tcp >/dev/null 2>&1 || true
        sudo ufw allow 3738/tcp >/dev/null 2>&1 || true
        echo -e "${GREEN}✅ Firewall rules updated${NC}"
    else
        echo -e "${GREEN}ℹ️  UFW is inactive${NC}"
    fi
else
    echo -e "${GREEN}ℹ️  UFW not installed${NC}"
fi
echo ""

# Step 8: Create/update .env file (as backup)
echo "Step 8: Creating .env File (Backup)"
echo "------------------------------------"
cat > .env << EOF
ANTHROPIC_API_KEY=$API_KEY
DOMAIN_NAME=$EC2_IP
PORT=6000
API_PORT=6001
ENABLE_SSL=true
EOF
echo -e "${GREEN}✅ .env file created${NC}"
echo ""

# Step 9: Stop old instances
echo "Step 9: Stopping Old Agent Instances"
echo "-------------------------------------"
pkill -f "python.*langchain_diy" 2>/dev/null || true
sleep 2
echo -e "${GREEN}✅ Old instances stopped${NC}"
echo ""

# Step 10: Verify configuration
echo "Step 10: Verifying Configuration"
echo "---------------------------------"
echo "API Key: ${ANTHROPIC_API_KEY:0:20}...${ANTHROPIC_API_KEY: -10}"
echo "Domain: $DOMAIN_NAME"
echo "Port: $PORT"
echo "API Port: $API_PORT"
echo "SSL: $ENABLE_SSL"
echo ""

# Step 11: Display next steps
echo -e "${GREEN}========================================"
echo "✅ Setup Complete!"
echo "========================================${NC}"
echo ""
echo "To start the Magic Mirror Agent:"
echo ""
echo "  cd ~/tresata_challenge"
echo "  conda activate nanda_agent"
echo "  ./2_run_backend.sh"
echo ""
echo "Or run directly:"
echo "  python tresata_challenge_adapter/nanda_adapter/examples/langchain_diy.py"
echo ""
echo "Expected endpoints:"
echo "  - Agent Bridge: https://$EC2_IP:6000/a2a"
echo "  - API Server: https://$EC2_IP:6001"
echo "  - Health Check: https://$EC2_IP:6001/api/health"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo "  - Make sure EC2 Security Group allows ports 6000, 6001, 3738"
echo "  - Accept self-signed certificate in browser at:"
echo "    https://$EC2_IP:6001/api/health"
echo "    https://$EC2_IP:6000/api/health"
echo ""

# Ask if user wants to start now
read -p "Start the agent now? (y/n): " START_NOW

if [ "$START_NOW" = "y" ] || [ "$START_NOW" = "Y" ]; then
    echo ""
    echo "🚀 Starting Magic Mirror Agent..."
    echo "================================="
    echo ""
    python tresata_challenge_adapter/nanda_adapter/examples/langchain_diy.py
else
    echo ""
    echo "✅ Setup complete. Start the agent when ready with:"
    echo "   ./2_run_backend.sh"
    echo ""
fi
