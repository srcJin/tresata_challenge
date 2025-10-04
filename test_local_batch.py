#!/usr/bin/env python3
"""
Batch Test Script for Magic Mirror Agent
Automatically tests a set of predefined questions and logs results
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables
env_path = Path(__file__).parent / '.env'
load_dotenv(dotenv_path=env_path)

# Import the agent
sys.path.insert(0, str(Path(__file__).parent / 'tresata_challenge_adapter'))
from nanda_adapter.examples.langchain_diy import create_magic_mirror

# Configuration
AGENT_NAME = "magic_mirror"
TEST_RESULTS_DIR = Path(__file__).parent / "test_results"

# Test questions
TEST_QUESTIONS = [
    "Who is the fairest of them all?",
    "What do you see in your reflection?",
    "Tell me the future of artificial intelligence",
    "What is the meaning of life?",
    "Mirror, mirror on the wall, who has the wisest words of all?",
    "How do I become a better person?",
    "What secrets does the universe hold?",
    "Will it rain tomorrow?",
    "What is love?",
    "Can you see my destiny?",
]

def create_log_filename():
    """Generate log filename with agent name and timestamp"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return f"{AGENT_NAME}_{timestamp}.json"

def run_batch_tests():
    """Run all test questions and log results"""

    # Check for API key
    if not os.getenv("ANTHROPIC_API_KEY"):
        print("❌ ANTHROPIC_API_KEY not found in .env file")
        print("Please create a .env file with your API key")
        sys.exit(1)

    # Create test results directory
    TEST_RESULTS_DIR.mkdir(exist_ok=True)

    # Create the magic mirror
    print("✨ Creating Magic Mirror Agent...")
    try:
        mirror = create_magic_mirror()
        print("✅ Magic Mirror is ready!\n")
    except Exception as e:
        print(f"❌ Error creating agent: {e}")
        sys.exit(1)

    # Prepare results with test parameters
    results = {
        "agent": AGENT_NAME,
        "agent_type": "magic_mirror",
        "agent_model": "claude-3-haiku-20240307",
        "agent_framework": "langchain",
        "timestamp": datetime.now().isoformat(),
        "test_count": len(TEST_QUESTIONS),
        "test_parameters": {
            "temperature": "default",
            "max_tokens": "default",
            "prompt_type": "poetic_verse",
            "response_style": "mystical_rhyming"
        },
        "environment": {
            "python_version": sys.version.split()[0],
            "test_mode": "batch"
        },
        "conversations": []
    }

    print("=" * 70)
    print("🧪 Magic Mirror - Batch Testing")
    print("=" * 70)
    print(f"📊 Running {len(TEST_QUESTIONS)} test questions...")
    print(f"💾 Results will be saved to: test_results/")
    print("")

    # Run tests
    successful = 0
    failed = 0

    for i, question in enumerate(TEST_QUESTIONS, 1):
        print(f"[{i}/{len(TEST_QUESTIONS)}] Testing: {question[:60]}...")

        start_time = datetime.now()
        conversation = {
            "question_number": i,
            "question": question,
            "question_length": len(question),
            "response": None,
            "response_length": None,
            "response_time_ms": None,
            "error": None,
            "timestamp": start_time.isoformat()
        }

        try:
            # Get response from agent
            response = mirror(question)
            end_time = datetime.now()
            response_time = (end_time - start_time).total_seconds() * 1000

            conversation["response"] = response
            conversation["response_length"] = len(response)
            conversation["response_time_ms"] = round(response_time, 2)
            successful += 1

            # Show preview
            preview = response[:100] + "..." if len(response) > 100 else response
            print(f"    ✅ Response ({response_time:.0f}ms): {preview}")
            print("")

        except Exception as e:
            end_time = datetime.now()
            response_time = (end_time - start_time).total_seconds() * 1000

            conversation["error"] = str(e)
            conversation["response_time_ms"] = round(response_time, 2)
            failed += 1
            print(f"    ❌ Error: {e}")
            print("")

        results["conversations"].append(conversation)

    # Calculate statistics
    successful_conversations = [c for c in results["conversations"] if c["error"] is None]
    if successful_conversations:
        response_times = [c["response_time_ms"] for c in successful_conversations]
        response_lengths = [c["response_length"] for c in successful_conversations]

        results["statistics"] = {
            "total_tests": len(TEST_QUESTIONS),
            "successful": successful,
            "failed": failed,
            "success_rate": round((successful / len(TEST_QUESTIONS)) * 100, 2),
            "avg_response_time_ms": round(sum(response_times) / len(response_times), 2),
            "min_response_time_ms": round(min(response_times), 2),
            "max_response_time_ms": round(max(response_times), 2),
            "avg_response_length": round(sum(response_lengths) / len(response_lengths), 2),
            "min_response_length": min(response_lengths),
            "max_response_length": max(response_lengths)
        }
    else:
        results["statistics"] = {
            "total_tests": len(TEST_QUESTIONS),
            "successful": 0,
            "failed": len(TEST_QUESTIONS),
            "success_rate": 0
        }

    # Save results
    log_file = TEST_RESULTS_DIR / create_log_filename()
    with open(log_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    # Summary
    print("=" * 70)
    print("📊 Batch Test Summary")
    print("=" * 70)
    print(f"✅ Successful: {successful}/{len(TEST_QUESTIONS)}")
    print(f"❌ Failed: {failed}/{len(TEST_QUESTIONS)}")
    if successful > 0:
        stats = results["statistics"]
        print(f"⚡ Avg Response Time: {stats['avg_response_time_ms']:.0f}ms")
        print(f"📏 Avg Response Length: {stats['avg_response_length']:.0f} chars")
    print(f"💾 Results saved to: {log_file}")
    print("")

    if successful == len(TEST_QUESTIONS):
        print("🎉 All tests passed!")
    elif failed == len(TEST_QUESTIONS):
        print("⚠️  All tests failed - check your configuration")
    else:
        print("⚠️  Some tests failed - check the log file for details")

    print("")

    # Display sample responses
    print("=" * 70)
    print("📝 Sample Responses")
    print("=" * 70)

    for conv in results["conversations"][:3]:  # Show first 3
        print(f"\n❓ Q: {conv['question']}")
        if conv['response']:
            print(f"🪞 A: {conv['response']}\n")
        else:
            print(f"❌ Error: {conv['error']}\n")

    print("=" * 70)
    print(f"📄 Full results: {log_file}")
    print("=" * 70)

def custom_batch_test(questions_file):
    """Run batch test with custom questions from a file"""

    if not os.path.exists(questions_file):
        print(f"❌ Questions file not found: {questions_file}")
        sys.exit(1)

    with open(questions_file, 'r') as f:
        custom_questions = [line.strip() for line in f if line.strip()]

    global TEST_QUESTIONS
    TEST_QUESTIONS = custom_questions

    print(f"📄 Loaded {len(custom_questions)} questions from {questions_file}")
    run_batch_tests()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Custom questions file provided
        custom_batch_test(sys.argv[1])
    else:
        # Use default questions
        run_batch_tests()
