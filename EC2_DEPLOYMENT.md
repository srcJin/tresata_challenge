# EC2 Deployment Guide (HTTP Mode - No SSL)

## Quick Start for EC2 Deployment

### 1. Configure Environment Variables

Edit `.env` file on your EC2 instance:

```bash
# Required: Your Anthropic API key
ANTHROPIC_API_KEY=your_key_here

# For EC2: Use your public IP or keep as localhost
DOMAIN_NAME=localhost

# Port configuration (3737 is safe and not blocked by browsers)
PORT=3737

# SSL Configuration - MUST be false for EC2 without certificates
ENABLE_SSL=false
```

### 2. Deploy to EC2

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Navigate to project directory
cd ~/tresata_challenge

# Pull latest changes
git pull

# Run the backend (HTTP mode, no SSL needed)
./2_run_backend.sh
```

### 3. Access Your Agent

The agent will be available at:

- **Local (on EC2)**: `http://localhost:3737`
- **Public**: `http://YOUR_EC2_PUBLIC_IP:3737`

**Important**: Make sure port 3737 is open in your EC2 Security Group:

```
Type: Custom TCP
Port: 3737
Source: 0.0.0.0/0 (or restrict to your IP)
```

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│  EC2 Instance (Ubuntu)                          │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │  NANDA Agent (HTTP Mode)                 │  │
│  │  Port: 3737                              │  │
│  │  SSL: Disabled                           │  │
│  │                                          │  │
│  │  • Agent Bridge: /a2a                    │  │
│  │  • API Health: /api/health               │  │
│  │  • API Send: /api/send                   │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  Registry Communication:                        │
│  → https://chat.nanda-registry.com:6900         │
└─────────────────────────────────────────────────┘
         ↓ HTTP (Port 3737)
┌─────────────────────────────────────────────────┐
│  Client Browser                                 │
│  http://EC2_IP:3737                             │
└─────────────────────────────────────────────────┘
```

## Security Considerations (HTTP Mode)

### Current Setup (No SSL)

- ✅ **Pros**:
  - No certificate management needed
  - Works with EC2 IP addresses
  - Easy to deploy and debug
  - No SSL handshake overhead

- ⚠️ **Cons**:
  - Traffic not encrypted
  - Suitable for development/testing only
  - Not recommended for production with sensitive data

### Recommended Security Enhancements

Even without SSL, you should implement:

#### 1. Session Token Authentication

Add to your API calls:

```javascript
// Frontend: Auto-managed session tokens
const response = await fetch('http://YOUR_EC2_IP:3737/api/send', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-Session-Token': sessionToken  // Auto-generated
    },
    body: JSON.stringify({ message: userInput })
});
```

#### 2. IP Allowlisting (Security Group)

Restrict EC2 Security Group to known IPs:

```
Inbound Rules:
Port 3737: Your IP address only
Port 22: Your IP address only (SSH)
```

#### 3. Rate Limiting

The system should implement rate limiting to prevent abuse:

```python
# Backend: Add to agent_bridge.py
from flask_limiter import Limiter

limiter = Limiter(
    app,
    key_func=lambda: request.headers.get('X-Session-Token', request.remote_addr),
    default_limits=["100 per hour"]
)
```

## Upgrading to SSL (Future)

When you're ready for production with SSL:

### Option A: Use a Domain Name + Let's Encrypt

```bash
# 1. Point a domain to your EC2 IP
# 2. Install certbot
sudo apt install certbot

# 3. Generate certificates
sudo certbot certonly --standalone -d your-domain.com

# 4. Copy certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ~/tresata_challenge/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ~/tresata_challenge/
sudo chown ubuntu:ubuntu ~/tresata_challenge/*.pem

# 5. Update .env
DOMAIN_NAME=your-domain.com
ENABLE_SSL=true

# 6. Restart
./2_run_backend.sh
```

### Option B: Self-Signed Certificate (Testing Only)

```bash
cd ~/tresata_challenge

# Generate self-signed cert
openssl genrsa -out privkey.pem 4096
openssl req -new -x509 -key privkey.pem -out fullchain.pem -days 365 -subj "/CN=YOUR_EC2_IP"

# Update .env
ENABLE_SSL=true

# Restart
./2_run_backend.sh
```

**Note**: Browsers will show security warnings for self-signed certificates.

## Troubleshooting

### Issue: Port 3737 not accessible

**Solution**: Check EC2 Security Group

```bash
# On EC2, check if service is listening
sudo netstat -tlnp | grep 3737

# Should show:
# tcp 0 0 0.0.0.0:3737 0.0.0.0:* LISTEN
```

### Issue: "ENABLE_SSL" environment variable not recognized

**Solution**: Make sure `.env` is loaded

```bash
# Verify .env file exists and has correct content
cat ~/tresata_challenge/.env | grep ENABLE_SSL

# Should output:
# ENABLE_SSL=false
```

### Issue: Registry connection fails

**Solution**: Check network connectivity

```bash
# Test registry connection
curl -v https://chat.nanda-registry.com:6900/api/health

# If this fails, check VPN/firewall settings
```

### Issue: Cannot access from China

**Workarounds**:

1. Use VPN (MIT VPN as you're doing)
2. Use a proxy service
3. Deploy registry server in China-accessible region
4. Use Chinese model providers (Alibaba Qwen, Baidu Wenxin)

## Performance Optimization

### For Production Deployment

1. **Use HTTPS**: Get proper SSL certificates
2. **Add CDN**: CloudFlare or similar
3. **Enable Compression**: Gzip responses
4. **Add Caching**: Redis for session storage
5. **Load Balancing**: Multiple EC2 instances
6. **Monitoring**: CloudWatch or Prometheus

## Next Steps

After HTTP deployment works:

1. ✅ **Test basic functionality**: Send/receive messages
2. ✅ **Implement authentication**: Session tokens
3. ✅ **Add rate limiting**: Prevent abuse
4. 🔜 **Upgrade to HTTPS**: Get domain + certificates
5. 🔜 **Add monitoring**: Track usage and errors
6. 🔜 **Backup strategy**: Database and logs

## Contact & Support

For issues with:

- **NANDA Framework**: https://github.com/projnanda/adapter
- **Deployment**: Check issues.md in this repository
- **Network (China)**: Consider Chinese cloud providers (Alibaba Cloud, Tencent Cloud)
