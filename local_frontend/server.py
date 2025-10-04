#!/usr/bin/env python3
"""
Simple HTTP server to serve the local frontend
Runs on port 8080 to avoid conflict with backend on port 6000
"""

import http.server
import socketserver
import os
from pathlib import Path

# Configuration
PORT = 8080
DIRECTORY = Path(__file__).parent

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP request handler with CORS support"""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(DIRECTORY), **kwargs)

    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def log_message(self, format, *args):
        # Custom log format
        print(f"[Frontend] {self.address_string()} - {format % args}")

def main():
    """Start the frontend server"""

    os.chdir(DIRECTORY)

    with socketserver.TCPServer(("", PORT), CORSRequestHandler) as httpd:
        print("=" * 60)
        print("🌐 Magic Mirror - Local Frontend Server")
        print("=" * 60)
        print(f"📍 Frontend URL: http://localhost:{PORT}")
        print(f"🔗 Backend API: http://localhost:6000")
        print("")
        print("💡 Make sure the backend is running:")
        print("   ./2_run_backend.sh")
        print("")
        print("✨ Open your browser and navigate to:")
        print(f"   http://localhost:{PORT}")
        print("")
        print("Press Ctrl+C to stop the server")
        print("=" * 60)
        print("")

        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n👋 Shutting down frontend server...")
            print("Goodbye!\n")

if __name__ == "__main__":
    main()
