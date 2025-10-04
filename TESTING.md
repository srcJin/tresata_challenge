# Testing Guide for Magic Mirror Agent

This guide covers all the testing methods available for the Magic Mirror agent.

## Test Methods Overview

| Method | Script | Description | Use Case |
|--------|--------|-------------|----------|
| **CLI Interactive** | `./4_test_local.sh` | Manual terminal chat | Quick testing, debugging |
| **Batch Automated** | `./4_test_batch.sh` | Automated test suite | Regression testing, benchmarking |
| **Web Interface** | `./5_run_frontend.sh` | Browser-based UI | User experience testing, demos |

---

## 1. CLI Interactive Testing

**Purpose:** Manual testing with immediate feedback

### Usage

```bash
# Interactive mode (type questions manually)
./4_test_local.sh

# Single question mode
./4_test_local.sh "Who is the fairest of them all?"
```

### Features
- ✅ Direct Python function calls (no server needed)
- ✅ Instant responses
- ✅ Easy debugging
- ✅ Good for development

### Example Session
```
🪞 Magic Mirror Agent - Local Test Interface
Type your questions and the magic mirror will respond in verse!

👤 You: Who is the fairest of them all?

🪞 Magic Mirror speaks:

   Mirror, mirror, shining bright,
   Reflecting all within my sight...

👤 You: quit
👋 Farewell! The mirror dims...
```

---

## 2. Batch Automated Testing

**Purpose:** Automated testing with logged results

### Usage

```bash
# Run default test suite (10 questions)
./4_test_batch.sh

# Run with custom questions
./4_test_batch.sh test_results/sample_questions.txt
```

### Features
- ✅ Automated testing of multiple questions
- ✅ JSON logs with timestamps
- ✅ Success/failure tracking
- ✅ Custom question files supported

### Output

Results saved to: `test_results/magic_mirror_{timestamp}.json`

**JSON Structure:**
```json
{
  "agent": "magic_mirror",
  "timestamp": "2025-10-04T14:59:46.123456",
  "test_count": 10,
  "conversations": [
    {
      "question_number": 1,
      "question": "Who is the fairest of them all?",
      "response": "Mirror, mirror, shining bright...",
      "error": null,
      "timestamp": "2025-10-04T14:59:47.789012"
    }
  ]
}
```

### Custom Questions File

Create a text file with one question per line:

**my_questions.txt:**
```
Who is the fairest of them all?
What do you see in your reflection?
Tell me about the future
```

Run with:
```bash
./4_test_batch.sh my_questions.txt
```

---

## 3. Web Interface Testing

**Purpose:** Browser-based testing with visual UI

### Usage

**Terminal 1 - Start Backend:**
```bash
./2_run_backend.sh
```

**Terminal 2 - Start Frontend:**
```bash
./5_run_frontend.sh
```

Then open: **http://localhost:8080**

### Features
- ✅ Beautiful chat interface
- ✅ Real-time responses
- ✅ Connection status indicator
- ✅ Great for demos and presentations

### Architecture
```
Browser (localhost:8080) ←→ Frontend Server ←→ Backend Agent (localhost:6000)
```

---

## Test Results

### Location
All batch test results are saved in: `test_results/`

### File Naming
Format: `{agent_name}_{YYYYMMDD_HHMMSS}.json`

Example: `magic_mirror_20251004_145946.json`

### Viewing Results

```bash
# List all results
ls -lt test_results/*.json

# View latest result
cat test_results/magic_mirror_*.json | head -n 50

# Pretty print with jq
cat test_results/magic_mirror_20251004_145946.json | jq '.'

# Extract all questions
jq '.conversations[].question' test_results/magic_mirror_*.json

# Extract all responses
jq '.conversations[].response' test_results/magic_mirror_*.json
```

---

## Quick Reference

### Before Testing
1. Ensure environment is set up: `./1_setup_environment.sh`
2. Check `.env` has valid `ANTHROPIC_API_KEY`

### For Quick Tests
```bash
./4_test_local.sh "Test question"
```

### For Comprehensive Testing
```bash
./4_test_batch.sh
```

### For Demo/Presentation
```bash
# Terminal 1
./2_run_backend.sh

# Terminal 2
./5_run_frontend.sh
```

---

## Troubleshooting

### "ANTHROPIC_API_KEY not found"
- Create/update `.env` file with your API key
- See `.env.example` for format

### CLI test not responding
- Check internet connection
- Verify API key is valid
- Check for error messages in terminal

### Batch test failures
- Check `test_results/*.json` for error details
- Verify API rate limits not exceeded
- Check individual error messages in JSON

### Frontend shows "Backend not running"
- Start backend first: `./2_run_backend.sh`
- Verify backend is on port 6000: `curl http://localhost:6000/api/health`

---

## Default Test Questions

The batch test includes these default questions:
1. Who is the fairest of them all?
2. What do you see in your reflection?
3. Tell me the future of artificial intelligence
4. What is the meaning of life?
5. Mirror, mirror on the wall, who has the wisest words of all?
6. How do I become a better person?
7. What secrets does the universe hold?
8. Will it rain tomorrow?
9. What is love?
10. Can you see my destiny?

---

## Best Practices

✅ **Development:** Use CLI interactive testing for quick iterations

✅ **Testing:** Use batch testing before deployment/commits

✅ **Demos:** Use web interface for presentations

✅ **Debugging:** Check batch test logs for systematic issues

✅ **CI/CD:** Integrate batch tests into your pipeline
