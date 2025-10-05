# Fix EC2 Connection Timeout Issue

## Problem
NANDA Chat tries to connect to `https://18.224.228.207:6001` but gets `ERR_CONNECTION_TIMED_OUT`.

## Root Cause
The API server (port 6001) is either:
1. Not running
2. Blocked by EC2 Security Group
3. Blocked by server firewall (UFW)

## Solution

### Step 1: Update .env on EC2

SSH into your EC2 instance and update `.env`:

```bash
ssh -i ~/.ssh/your-key.pem ubuntu@18.224.228.207
cd ~/tresata_challenge

# Edit .env file
nano .env
```

Make sure it has:
```bash
ANTHROPIC_API_KEY=your_actual_key_here
DOMAIN_NAME=18.224.228.207
PORT=3737
API_PORT=6001
ENABLE_SSL=false
```

### Step 2: Update EC2 Security Group

1. Go to AWS Console → EC2 → Security Groups
2. Find your instance's security group
3. Add Inbound Rules:

| Type | Protocol | Port Range | Source |
|------|----------|------------|--------|
| Custom TCP | TCP | 3737 | 0.0.0.0/0 |
| Custom TCP | TCP | 6001 | 0.0.0.0/0 |
| Custom TCP | TCP | 3738 | 0.0.0.0/0 |

### Step 3: Allow Ports in UFW (if enabled)

```bash
# Check if UFW is active
sudo ufw status

# If active, allow the ports
sudo ufw allow 3737/tcp
sudo ufw allow 6001/tcp
sudo ufw allow 3738/tcp
```

### Step 4: Pull Latest Code

```bash
cd ~/tresata_challenge
git pull

cd tresata_challenge_adapter
git pull
cd ..
```

### Step 5: Restart the Agent

```bash
# Stop any running instances
pkill -f "python.*langchain_diy"

# Activate conda environment
conda activate nanda_agent

# Start the agent
python tresata_challenge_adapter/nanda_adapter/examples/langchain_diy.py
```

### Step 6: Verify It's Working

You should see output like:
```
🌐 Starting HTTP server on 18.224.228.207
   - Agent Bridge (A2A): http://18.224.228.207:3737/a2a
   - API Server: http://18.224.228.207:6001
   - API Health: http://18.224.228.207:6001/api/health
   - API Send: http://18.224.228.207:6001/api/send
   - API Render: http://18.224.228.207:6001/api/render

⚠️  Make sure EC2 Security Group allows inbound traffic on ports 3737 and 6001
✨ Magic Mirror Chat API started on port 3738
```

### Step 7: Test from Local Machine

```bash
# Test API health
curl http://18.224.228.207:6001/api/health

# Test A2A endpoint
curl http://18.224.228.207:3737/api/health
```

### Step 8: Test with NANDA Chat

1. Open https://chat.nanda-registry.com:6900
2. Look for the registration URL in your server logs
3. Or manually register with:
   - Agent URL: `http://18.224.228.207:3737/a2a`
   - API URL: `http://18.224.228.207:6001`

## Common Issues

### Issue: Port 6001 still times out
**Solution**: Make sure `start_server_api()` is being called (check domain != "localhost")

### Issue: Certificate errors
**Solution**: Make sure `ENABLE_SSL=false` in .env

### Issue: Agent not responding
**Solution**: Check logs with `journalctl -u magic-mirror -f` if using systemd

## What Changed

The latest code now:
1. Explicitly sets `api_port=6001` parameter
2. Prints all endpoint URLs on startup
3. Warns about Security Group requirements
4. Handles both HTTP and HTTPS modes correctly

## Summary

NANDA Chat needs **TWO ports**:
- **Port 3737**: Agent Bridge (A2A protocol)
- **Port 6001**: API Server (for NANDA Chat web interface)

Both must be:
✅ Open in EC2 Security Group
✅ Open in UFW (if enabled)
✅ Actually running on the server
