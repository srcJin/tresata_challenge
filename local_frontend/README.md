# Magic Mirror - Local Frontend

A beautiful web interface for testing your Magic Mirror agent locally.

## Features

- 🎨 Clean, modern chat interface
- 🪞 Real-time communication with Magic Mirror agent
- 💬 Poetic responses in mystical verse
- ✨ Connection status indicator
- 📱 Responsive design

## Quick Start

### 1. Start the Backend
First, make sure the backend agent is running:
```bash
cd ..
./2_run_backend.sh
```

### 2. Start the Frontend Server
In a new terminal:
```bash
python local_frontend/server.py
```

### 3. Open in Browser
Navigate to: **http://localhost:8080**

## Architecture

```
┌─────────────────┐         ┌─────────────────┐
│  Web Browser    │         │  Backend Agent  │
│  localhost:8080 │ ◄─────► │  localhost:6000 │
│                 │         │                 │
│  - index.html   │         │  - A2A API      │
│  - style.css    │         │  - Magic Mirror │
│  - app.js       │         │    Logic        │
└─────────────────┘         └─────────────────┘
```

## Files

- **index.html** - Main HTML structure
- **style.css** - Styling and animations
- **app.js** - JavaScript logic and API calls
- **server.py** - Simple HTTP server with CORS support
- **README.md** - This file

## Usage

1. Type your question in the input box
2. Press Enter or click Send
3. Watch the Magic Mirror respond in poetic verse!

## Troubleshooting

**"Backend not running" error:**
- Make sure you started the backend: `./2_run_backend.sh`
- Check that port 6000 is not blocked

**CORS errors:**
- The frontend server handles CORS automatically
- Make sure you're accessing via `localhost:8080`, not `file://`

**No response from agent:**
- Check `.env` file has valid `ANTHROPIC_API_KEY`
- Check backend terminal for error messages

## Technology Stack

- Pure HTML/CSS/JavaScript (no frameworks)
- Python 3 HTTP server
- A2A protocol for agent communication

## Development

To modify the frontend:
1. Edit HTML/CSS/JS files
2. Refresh browser (no build step needed)
3. Check browser console for debugging

Enjoy chatting with your Magic Mirror! ✨🪞
