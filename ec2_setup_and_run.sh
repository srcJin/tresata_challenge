#!/bin/bash

# EC2 Setup and Run Script
# Run this on your EC2 instance to set up and start the Magic Mirror agent

set -e  # Exit on error

echo "🚀 Magic Mirror Agent - EC2 Setup & Launch"
echo "==========================================="
echo ""

# Step 1: Detect IP
echo "Step 1: Detecting EC2 Public IP..."
EC2_IP=$(curl -s http://checkip.amazonaws.com)
echo "✅ Detected IP: $EC2_IP"
echo ""

# Step 2: Check if conda is available
echo "Step 2: Checking Conda environment..."
if ! command -v conda &> /dev/null; then
    echo "❌ Conda not found. Please install Miniconda first."
    exit 1
fi
echo "✅ Conda is available"
echo ""

# Step 3: Create/activate environment
echo "Step 3: Setting up Conda environment..."
ENV_NAME="nanda_agent"

if conda env list | grep -q "^$ENV_NAME "; then
    echo "✅ Environment '$ENV_NAME' exists"
else
    echo "📦 Creating environment '$ENV_NAME'..."
    conda create -n $ENV_NAME python=3.11 -y
fi

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate $ENV_NAME
echo "✅ Activated environment: $ENV_NAME"
echo ""

# Step 4: Install dependencies
echo "Step 4: Installing Python dependencies..."
cd ~/tresata_challenge/tresata_challenge_adapter
pip install --upgrade pip > /dev/null
pip install nanda-adapter langchain-core langchain-anthropic flask flask-cors python-dotenv > /dev/null
echo "✅ Dependencies installed"
cd ~/tresata_challenge
echo ""

# Step 5: Generate SSL certificate
echo "Step 5: Setting up SSL certificate..."
if [ -f "fullchain.pem" ] && [ -s "fullchain.pem" ]; then
    echo "✅ SSL certificate already exists"
else
    echo "🔐 Generating self-signed SSL certificate..."
    openssl req -x509 -newkey rsa:4096 -nodes \
        -keyout privkey.pem \
        -out fullchain.pem \
        -days 365 \
        -subj "/CN=$EC2_IP" 2>/dev/null

    if [ -s "fullchain.pem" ] && [ -s "privkey.pem" ]; then
        echo "✅ SSL certificate generated"
        ls -lh fullchain.pem privkey.pem
    else
        echo "❌ SSL certificate generation failed"
        exit 1
    fi
fi
echo ""

# Step 6: Configure .env
echo "Step 6: Configuring environment variables..."

# Check if API key exists
if [ -f ".env" ] && grep -q "^ANTHROPIC_API_KEY=" .env; then
    echo "✅ .env file exists with API key"
else
    echo "⚠️  .env file missing or incomplete"
    echo ""
    read -p "Enter your ANTHROPIC_API_KEY: " API_KEY

    cat > .env << EOF
ANTHROPIC_API_KEY=$API_KEY
DOMAIN_NAME=$EC2_IP
PORT=3737
API_PORT=6001
ENABLE_SSL=true
EOF
    echo "✅ Created .env file"
fi

# Update domain to current IP
sed -i "s/^DOMAIN_NAME=.*/DOMAIN_NAME=$EC2_IP/" .env
sed -i "s/^ENABLE_SSL=.*/ENABLE_SSL=true/" .env

echo ""
echo "Current .env configuration:"
cat .env
echo ""

# Step 7: Check firewall
echo "Step 7: Checking firewall configuration..."
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status | head -1)
    if echo "$UFW_STATUS" | grep -q "active"; then
        echo "🔥 UFW is active, checking ports..."
        sudo ufw allow 3737/tcp > /dev/null 2>&1 || true
        sudo ufw allow 6001/tcp > /dev/null 2>&1 || true
        sudo ufw allow 3738/tcp > /dev/null 2>&1 || true
        echo "✅ Firewall rules updated"
    else
        echo "ℹ️  UFW is inactive"
    fi
else
    echo "ℹ️  UFW not installed"
fi
echo ""

# Step 8: Stop any existing instances
echo "Step 8: Stopping existing agent instances..."
pkill -f "python.*langchain_diy" 2>/dev/null || true
sleep 2
echo "✅ Old instances stopped"
echo ""

# Step 9: Start the agent
echo "Step 9: Starting Magic Mirror Agent..."
echo "======================================="
echo ""
echo "🪞 Magic Mirror will start with:"
echo "   - Domain: $EC2_IP"
echo "   - Agent Port: 3737 (HTTPS)"
echo "   - API Port: 6001 (HTTPS)"
echo "   - SSL: Enabled (self-signed)"
echo ""
echo "📝 Logs will appear below..."
echo "   Press Ctrl+C to stop"
echo ""
echo "-----------------------------------"

# Run in foreground so you can see logs
python tresata_challenge_adapter/nanda_adapter/examples/langchain_diy.py
