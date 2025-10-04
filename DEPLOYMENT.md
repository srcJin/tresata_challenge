# Deploying Magic Mirror Agent to Amazon EC2

This guide walks you through deploying the Magic Mirror agent to an Amazon EC2 instance.

## Prerequisites

- AWS Account with EC2 access
- SSH key pair for EC2 access
- Domain name (optional, for HTTPS)
- Anthropic API key

## Step 1: Launch EC2 Instance

### 1.1 Choose Instance Type
```
Recommended: t2.medium or t3.medium
- 2 vCPUs
- 4 GB RAM
- Cost: ~$0.05/hour
```

### 1.2 Select AMI
- **Ubuntu Server 22.04 LTS** (recommended)
- Or Amazon Linux 2023

### 1.3 Configure Security Group

Create a security group with these inbound rules:

| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | Your IP | SSH access |
| Custom TCP | TCP | 3737 | 0.0.0.0/0 | Agent API |
| Custom TCP | TCP | 5050 | 0.0.0.0/0 | Flask UI (optional) |
| HTTPS | TCP | 443 | 0.0.0.0/0 | HTTPS (if using SSL) |

### 1.4 Create/Select Key Pair
- Download the `.pem` file
- Save it securely (e.g., `~/.ssh/magic-mirror.pem`)
- Set permissions: `chmod 400 ~/.ssh/magic-mirror.pem`

## Step 2: Connect to EC2 Instance

```bash
# Get your instance public IP from AWS Console
ssh -i ~/.ssh/magic-mirror.pem ubuntu@<EC2_PUBLIC_IP>
```

## Step 3: Install Dependencies

### 3.1 Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### 3.2 Install Miniconda
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 3.3 Install Git
```bash
sudo apt install git -y
```

## Step 4: Clone and Setup Project

### 4.1 Clone Repository
```bash
cd ~
git clone https://github.com/YOUR_USERNAME/tresata_challenge.git
cd tresata_challenge
```

### 4.2 Update Submodules
```bash
git submodule update --init --recursive
```

## Step 5: Configure Environment

### 5.1 Create .env File
```bash
cp .env.example .env
nano .env
```

### 5.2 Set Environment Variables
```bash
# Required
ANTHROPIC_API_KEY=your-actual-anthropic-api-key

# Optional - Use your EC2 public IP or domain
DOMAIN_NAME=<EC2_PUBLIC_IP>

# Port configuration (3737 is safer than 6000)
PORT=3737

# For NANDA Registry (optional)
SMITHERY_API_KEY=your-smithery-key
```

Press `Ctrl+X`, then `Y`, then `Enter` to save.

## Step 6: Run Setup Script

```bash
chmod +x 1_setup.sh
./1_setup.sh
```

This will:
- Create conda environment `nanda_agent`
- Install Python dependencies
- Set up the project structure

## Step 7: Test the Agent Locally

### 7.1 Start the Backend
```bash
./2_run_backend.sh
```

### 7.2 Test Health Endpoint
In a new SSH session:
```bash
curl http://localhost:3737/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "agent": "magic_mirror",
  "timestamp": "..."
}
```

### 7.3 Test A2A Endpoint
```bash
curl -X POST http://localhost:3737/a2a \
  -H "Content-Type: application/json" \
  -d '{
    "parts": [{"type": "text", "text": "Hello"}],
    "role": "user"
  }'
```

Press `Ctrl+C` to stop the test.

## Step 8: Run as Background Service

### 8.1 Create systemd Service File
```bash
sudo nano /etc/systemd/system/magic-mirror.service
```

### 8.2 Add Service Configuration
```ini
[Unit]
Description=Magic Mirror Agent
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/tresata_challenge
Environment="PATH=/home/ubuntu/miniconda3/envs/nanda_agent/bin:/home/ubuntu/miniconda3/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/home/ubuntu/miniconda3/envs/nanda_agent/bin/python /home/ubuntu/tresata_challenge/tresata_challenge_adapter/nanda.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 8.3 Enable and Start Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable magic-mirror
sudo systemctl start magic-mirror
```

### 8.4 Check Service Status
```bash
sudo systemctl status magic-mirror
```

### 8.5 View Logs
```bash
# Real-time logs
sudo journalctl -u magic-mirror -f

# Last 100 lines
sudo journalctl -u magic-mirror -n 100
```

## Step 9: Configure Firewall (Optional)

```bash
# Enable UFW firewall
sudo ufw allow 22/tcp
sudo ufw allow 3737/tcp
sudo ufw allow 5050/tcp
sudo ufw enable
```

## Step 10: Access the Agent

### 10.1 Get Your EC2 Public IP
```bash
curl http://checkip.amazonaws.com
```

### 10.2 Test from Your Local Machine
```bash
# Health check
curl http://<EC2_PUBLIC_IP>:3737/api/health

# Send a message
curl -X POST http://<EC2_PUBLIC_IP>:3737/a2a \
  -H "Content-Type: application/json" \
  -d '{
    "parts": [{"type": "text", "text": "Hello Magic Mirror"}],
    "role": "user"
  }'
```

### 10.3 Access Web UI
Open in browser:
```
http://<EC2_PUBLIC_IP>:5050
```

## Step 11: Register with NANDA (Optional)

### 11.1 Run Registration
```bash
cd ~/tresata_challenge
./3_register_agent.sh
```

### 11.2 Note Your Agent URL
The script will output:
```
Agent URL: http://<EC2_PUBLIC_IP>:3737/a2a
Chat URL: https://chat.nanda-registry.com/landing.html?agentId=agentm123456
```

### 11.3 Test via NANDA Chat
Open the Chat URL in your browser and interact with your agent.

## Troubleshooting

### Service Won't Start
```bash
# Check logs
sudo journalctl -u magic-mirror -n 50

# Check if port is available
sudo lsof -i :3737

# Check environment file
cat ~/tresata_challenge/.env
```

### Port Blocked by Browser
If you get `ERR_UNSAFE_PORT` errors:
- Use port 3737 (safe port)
- Or use a reverse proxy (nginx) on port 443

### API Key Issues
```bash
# Verify API key is loaded
source ~/miniconda3/etc/profile.d/conda.sh
conda activate nanda_agent
python -c "import os; print(os.getenv('ANTHROPIC_API_KEY'))"
```

### Connection Timeout
- Check EC2 Security Group allows inbound on port 3737
- Check UFW firewall: `sudo ufw status`
- Verify service is running: `sudo systemctl status magic-mirror`

### SSL/HTTPS Issues
If you need HTTPS, see "Optional: Setup HTTPS with Nginx" below.

## Optional: Setup HTTPS with Nginx

### 1. Install Nginx and Certbot
```bash
sudo apt install nginx certbot python3-certbot-nginx -y
```

### 2. Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/magic-mirror
```

Add:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3737;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### 3. Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/magic-mirror /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 4. Get SSL Certificate
```bash
sudo certbot --nginx -d your-domain.com
```

### 5. Access via HTTPS
```
https://your-domain.com/api/health
https://your-domain.com/a2a
```

## Monitoring and Maintenance

### Check Service Health
```bash
# Service status
sudo systemctl status magic-mirror

# Recent logs
sudo journalctl -u magic-mirror -n 100 --no-pager

# Follow logs in real-time
sudo journalctl -u magic-mirror -f
```

### Restart Service
```bash
sudo systemctl restart magic-mirror
```

### Update Code
```bash
cd ~/tresata_challenge
git pull
sudo systemctl restart magic-mirror
```

### Stop Service
```bash
sudo systemctl stop magic-mirror
```

## Cost Estimation

### EC2 Instance (t3.medium)
- Hourly: ~$0.042
- Monthly (24/7): ~$30

### Data Transfer
- First 1 GB/month: Free
- Next 9.999 TB: $0.09/GB

### Total Estimated Cost
- Light usage: ~$30-40/month
- Heavy usage: ~$50-100/month

## Security Best Practices

1. **Use Security Groups**: Limit SSH to your IP only
2. **Keep System Updated**: `sudo apt update && sudo apt upgrade`
3. **Use Strong Keys**: Rotate API keys regularly
4. **Enable HTTPS**: Use Certbot for free SSL certificates
5. **Monitor Logs**: Check for unusual activity
6. **Backup .env**: Keep API keys secure and backed up
7. **Use IAM Roles**: For AWS resource access (if needed)

## Next Steps

- Set up CloudWatch for monitoring
- Configure auto-scaling (for production)
- Set up backup and disaster recovery
- Implement rate limiting
- Add authentication to endpoints

## Support

For issues specific to:
- **AWS EC2**: AWS Support or documentation
- **Magic Mirror Agent**: Check `issues.md` or create GitHub issue
- **NANDA Registry**: NANDA documentation

---

**Note**: This guide assumes basic familiarity with AWS, Linux, and command-line tools. For production deployments, consider additional security hardening, monitoring, and backup strategies.
