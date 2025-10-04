#!/usr/bin/env python3
"""
Local Test Interface for Magic Mirror Agent
This script allows you to test your agent locally without NANDA registry
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
env_path = Path(__file__).parent / '.env'
load_dotenv(dotenv_path=env_path)

# Import the agent
sys.path.insert(0, str(Path(__file__).parent / 'tresata_challenge_adapter'))
from nanda_adapter.examples.langchain_diy import create_magic_mirror

def test_agent_interactive():
    """Interactive testing of the magic mirror agent"""

    # Check for API key
    if not os.getenv("ANTHROPIC_API_KEY"):
        print("❌ ANTHROPIC_API_KEY not found in .env file")
        print("Please create a .env file with your API key")
        sys.exit(1)

    # Create the magic mirror improvement function
    print("✨ Creating Magic Mirror Agent...")
    try:
        mirror = create_magic_mirror()
        print("✅ Magic Mirror is ready!\n")
    except Exception as e:
        print(f"❌ Error creating agent: {e}")
        sys.exit(1)

    # Interactive loop
    print("=" * 60)
    print("🪞 Magic Mirror Agent - Local Test Interface")
    print("=" * 60)
    print("Type your questions and the magic mirror will respond in verse!")
    print("Commands: 'quit' or 'exit' to stop, 'clear' to clear screen\n")

    while True:
        try:
            # Get user input
            user_input = input("👤 You: ").strip()

            if not user_input:
                continue

            # Handle commands
            if user_input.lower() in ['quit', 'exit', 'q']:
                print("\n👋 Farewell! The mirror dims...\n")
                break

            if user_input.lower() == 'clear':
                os.system('clear' if os.name != 'nt' else 'cls')
                continue

            # Call the magic mirror
            print("\n🪞 Magic Mirror speaks:\n")
            try:
                response = mirror(user_input)
                print(f"   {response}\n")
            except Exception as e:
                print(f"❌ Error: {e}\n")

        except KeyboardInterrupt:
            print("\n\n👋 Farewell! The mirror dims...\n")
            break
        except EOFError:
            break

def test_agent_single(message):
    """Test with a single message"""

    if not os.getenv("ANTHROPIC_API_KEY"):
        print("❌ ANTHROPIC_API_KEY not found in .env file")
        sys.exit(1)

    print("✨ Creating Magic Mirror Agent...")
    mirror = create_magic_mirror()

    print(f"\n👤 You: {message}")
    print("\n🪞 Magic Mirror speaks:\n")
    response = mirror(message)
    print(f"   {response}\n")

if __name__ == "__main__":
    # Check if message provided as argument
    if len(sys.argv) > 1:
        message = " ".join(sys.argv[1:])
        test_agent_single(message)
    else:
        test_agent_interactive()
