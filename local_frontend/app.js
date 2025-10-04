// Magic Mirror Agent - Local Frontend
const API_URL = 'http://localhost:6000';

// DOM Elements
const chatContainer = document.getElementById('chatContainer');
const chatForm = document.getElementById('chatForm');
const messageInput = document.getElementById('messageInput');
const sendButton = document.getElementById('sendButton');
const statusDot = document.getElementById('statusDot');
const statusText = document.getElementById('statusText');

// State
let isConnected = false;
let conversationId = generateUUID();

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    checkConnection();
    chatForm.addEventListener('submit', handleSubmit);
});

// Check if backend is running
async function checkConnection() {
    try {
        const response = await fetch(`${API_URL}/api/health`, {
            method: 'GET',
            mode: 'cors',
        });

        if (response.ok) {
            setConnected(true);
        } else {
            setConnected(false);
        }
    } catch (error) {
        setConnected(false);
    }
}

// Set connection status
function setConnected(connected) {
    isConnected = connected;

    if (connected) {
        statusDot.className = 'status-dot connected';
        statusText.textContent = 'Connected to Magic Mirror';
        messageInput.disabled = false;
        sendButton.disabled = false;
    } else {
        statusDot.className = 'status-dot error';
        statusText.textContent = 'Backend not running';
        messageInput.disabled = true;
        sendButton.disabled = true;

        showError('Backend server is not running. Please start it with: ./2_run_backend.sh');
    }
}

// Handle form submission
async function handleSubmit(e) {
    e.preventDefault();

    const message = messageInput.value.trim();
    if (!message) return;

    // Clear input
    messageInput.value = '';

    // Display user message
    addMessage('user', message);

    // Show loading indicator
    const loadingEl = addLoading();

    // Disable input while processing
    messageInput.disabled = true;
    sendButton.disabled = true;

    try {
        // Send message to agent
        const response = await sendMessageToAgent(message);

        // Remove loading
        loadingEl.remove();

        // Display agent response
        if (response && response.text) {
            addMessage('agent', response.text);
        } else {
            addMessage('agent', 'The mirror remains silent...');
        }

    } catch (error) {
        console.error('Error:', error);
        loadingEl.remove();
        addMessage('agent', 'Error: Unable to reach the magic mirror. ' + error.message);
    } finally {
        // Re-enable input
        messageInput.disabled = false;
        sendButton.disabled = false;
        messageInput.focus();
    }
}

// Send message to agent via A2A protocol
async function sendMessageToAgent(message) {
    const payload = {
        parts: [
            {
                type: 'text',
                text: message
            }
        ],
        role: 'user',
        metadata: {
            conversation_id: conversationId,
            message_id: generateUUID()
        }
    };

    const response = await fetch(`${API_URL}/a2a`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload)
    });

    if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();

    // Extract text from response
    if (data.parts && data.parts.length > 0) {
        return {
            text: data.parts[0].text || data.parts[0].data?.text || 'No response'
        };
    }

    return { text: 'No response from agent' };
}

// Add message to chat
function addMessage(role, content) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${role}`;

    const label = document.createElement('div');
    label.className = 'message-label';
    label.textContent = role === 'user' ? 'You' : '🪞 Magic Mirror';

    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content';
    contentDiv.textContent = content;

    if (role === 'user') {
        messageDiv.appendChild(contentDiv);
    } else {
        messageDiv.appendChild(label);
        messageDiv.appendChild(contentDiv);
    }

    chatContainer.appendChild(messageDiv);
    scrollToBottom();
}

// Add loading indicator
function addLoading() {
    const loadingDiv = document.createElement('div');
    loadingDiv.className = 'message agent';
    loadingDiv.id = 'loading';

    const label = document.createElement('div');
    label.className = 'message-label';
    label.textContent = '🪞 Magic Mirror';

    const contentDiv = document.createElement('div');
    contentDiv.className = 'message-content loading';
    contentDiv.innerHTML = `
        <div class="loading-dot"></div>
        <div class="loading-dot"></div>
        <div class="loading-dot"></div>
    `;

    loadingDiv.appendChild(label);
    loadingDiv.appendChild(contentDiv);
    chatContainer.appendChild(loadingDiv);
    scrollToBottom();

    return loadingDiv;
}

// Show error message
function showError(message) {
    const errorDiv = document.createElement('div');
    errorDiv.className = 'error-message';
    errorDiv.textContent = message;
    chatContainer.insertBefore(errorDiv, chatContainer.firstChild.nextSibling);
}

// Scroll to bottom of chat
function scrollToBottom() {
    chatContainer.scrollTop = chatContainer.scrollHeight;
}

// Generate UUID
function generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        const r = Math.random() * 16 | 0;
        const v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}

// Auto-focus input on load
window.addEventListener('load', () => {
    if (!messageInput.disabled) {
        messageInput.focus();
    }
});
