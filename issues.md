


# mixture of oop and functional programming
NANDA is a class

MCPClient



but others 


multi-modal support

langchain is actually depreciated, langgraph is the current mainstream

(but nanda is somehow take place of the langgraph)

however, both framework lack enough support for realtime and computer use apis


is ui simple and easy to use?

is ui developer friendly?

nanda build in send does not have a
  interface, it's just a backend

  无法访问此网站
网址为 http://localhost:6000/tasks/send 的网页可能暂时无法连接，或者它已永久性地移动到了新网址。
ERR_UNSAFE_PORT

Ah! The browser is blocking port 6000 as
  unsafe. Chrome/browsers block certain
  ports for security.

  port issue



send task on ui does not work (http://127.0.0.1:PORT/tasks/send)

/tasks/send only handles POST
  requests, not GET. That's why the browser
  shows nothing - there's no GET handler.
  The button in the UI is just a link that
  doesn't work. Let's add a simple chat UI



the nanda agent website state management issue: after login, it still display not logged in state.

https://chat2.nanda-registry.com:8046

Amazon EC2 platform is not accessible from China even with VPN.


## agent_bridge.py

Hardcoded SMITHERY_API_KEY = os.getenv("SMITHERY_API_KEY") or "bfcb8cec-9d56-4957-8156-bced0bfca532" inside, and it should not print to the console afterwards.

verify=False # add this line to disable SSL verification

when making request 
# Make request to the registry endpoint
        response = requests.get(endpoint_url, params={
            'registry_provider': requested_registry,
            'qualified_name': qualified_name
        })

the get does not verify authentication and sanitization.

form_mcp_server_url
            config_b64 = base64.b64encode(json.dumps(config).encode())            

the config json is not encrypted.


Scaling:

  thread.daemon = True
  thread.start()
  - 问题: 没有限制并发线程数
  - 建议: 使用线程池


  registered_ui_clients = set()
  - 问题: 集合可能无限增长
  - 建议: 添加清理机制

Failure catch:
some return None with a print message
some directly return message. 
it should be better to make all error handling using the same mechanism.


  if not agent_url.endswith('/a2a'):

this test is too simple, it may be faked, like fakeurl/agent/a2a/a2a


typo: 
        if additional_context and additional_context.strip():
            full_prompt = f"ADDITIONAL CONTEXT FRseOM USER: {additional_context}\n\nMESSAGE: {prompt}"

agennts : should be agents



## mcp_utils.py

ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY") or "your-key"
this looks like llm generated and have issue. 

should be fixed by raising error if no key exists:

  ANTHROPIC_API_KEY =
  os.getenv("ANTHROPIC_API_KEY")
  if not ANTHROPIC_API_KEY:
      raise ValueError("ANTHROPIC_API_KEY 
  environment variable not set")


  if transport_type.lower() == "sse":
  - 问题: 只检查 "sse"，其他值都会走 HTTP
  路径，没有严格验证
  - 建议:

  ALLOWED_TRANSPORTS = {"http", "sse"}
  if transport_type.lower() not in
  ALLOWED_TRANSPORTS:
      raise ValueError(f"Invalid transport 
  type: {transport_type}")

Scaling:

  🟡 中等: 异步资源清理不完整 (Lines 
  195-200)

  async def __aexit__(self, exc_type, 
  exc_val, exc_tb):
      await self.exit_stack.aclose()
      self.session = None
  - 问题:
    a. 如果 exit_stack.aclose()
  失败，session 不会被清理
    b. 没有检查 exit_stack 是否为 None
    c. 未记录清理过程中的异常
  - 建议:
  async def __aexit__(self, exc_type, 
  exc_val, exc_tb):
      try:
          if self.exit_stack:
              await self.exit_stack.aclose()
      except Exception as e:
          print(f"Error closing exit stack: 
  {e}")
      finally:
          self.session = None
      return False  # Don't suppress 
  exceptions

  🟡 中等: 连接未关闭的风险 (Lines 47-80)

  async def 
  connect_to_mcp_and_get_tools(self, 
  mcp_server_url, transport_type="http"):
      try:
          transport = await
  self.exit_stack.enter_async_context(...)
          # ...
      except Exception as e:
          print(f"Error connecting to MCP 
  server: {e}")
          return None
  - 问题: 异常时直接返回 None，但已经通过
  enter_async_context
  添加的资源可能未正确清理
  - 建议:
  在异常处理中显式关闭资源或重新抛出异常


Error handling:
  except json.JSONDecodeError:
      pass

      should be

  except json.JSONDecodeError as e:
      logger.warning(f"Failed to parse JSON 
  response: {e}")


hardcoded API call

# Call Claude API
message = self.anthropic.messages.create(
    model="claude-3-5-sonnet-20241022",
    max_tokens=1024,
    messages=messages,
    tools=available_tools,
)

should make it modular.


  5. 潜在 Bug

  🟡 中等: 无限循环风险 (Lines 115-178)

  while True:
      has_tool_calls = False
      for block in message.content:
          if block.type == "tool_use":
              has_tool_calls = True
              # ...
      if not has_tool_calls:
          break
  - 问题: 如果 Claude 持续返回 tool_use
  且从不停止，会导致无限循环
  - 建议: 添加最大迭代次数限制
  MAX_TOOL_ITERATIONS = 10
  iteration = 0
  while True:
      iteration += 1
      if iteration > MAX_TOOL_ITERATIONS:
          logger.warning("Exceeded max tool 
  call iterations")
          break



## nanda.py 


  1. 安全漏洞 (Security Vulnerabilities)

  🔴 严重: 硬编码 API Key 后备值 (Line 80)

  ANTHROPIC_API_KEY =
  os.getenv("ANTHROPIC_API_KEY") or "your 
  key"
  - 问题: 与其他文件相同的硬编码问题，会导致
  使用无效凭证
  - 建议:
  ANTHROPIC_API_KEY =
  os.getenv("ANTHROPIC_API_KEY")
  if not ANTHROPIC_API_KEY:
      raise ValueError("ANTHROPIC_API_KEY 
  environment variable must be set")


  🟡 中等: 默认不安全端口 (Lines 84, 144, 
  160)

  PORT = int(os.getenv("PORT", "6000"))
  port=6000,  # Default port in function 
  signature
  - 问题: 端口 6000 被浏览器标记为不安全
  (ERR_UNSAFE_PORT)
  - 用户已反馈: "8000 is not safe, use a
  rare port"
  - 建议: 改为 3737 或其他安全端口
  PORT = int(os.getenv("PORT", "3737"))
  port=3737,


🟡 中等: 外部 IP 检测不安全 (Lines 176, 
  186)

  response = requests.get("http://checkip.am
  azonaws.com", timeout=10)
  response =
  requests.get("http://ifconfig.me",
  timeout=10)
  - 问题:
    a. 使用不加密的 HTTP（应使用 HTTPS）
    b. 依赖外部服务，可能被 DNS
  劫持或中间人攻击
    c. 在中国网络环境下 AWS
  不可访问（用户提到 "Amazon EC2 platform is
   not accessible from China even with
  VPN"）
  - 建议:
  try:
      response =
  requests.get("https://api.ipify.org",
  timeout=10, verify=True)
      # Or use local network introspection 
  instead
  except requests.exceptions.SSLError:
      # Fallback for environments with SSL 
  issues
      pass



Scaling:

  🔴 严重: 文件句柄泄漏 (Line 259)

  log_file =
  open(f"{log_dir}/bridge_run.txt", "a")
  - 问题:
    a. 文件打开后从未关闭
    b. 变量未被使用（僵尸变量）
    c. 长期运行的服务器会累积打开的文件句柄
  - 建议: 删除此行或使用 context manager
  # If logging is needed, use proper logging
   module
  import logging
  logging.basicConfig(
      filename=f"{log_dir}/bridge_run.txt",
      level=logging.INFO,
      format='%(asctime)s - %(name)s - 
  %(levelname)s - %(message)s'
  )


  🟡 中等: 线程资源未清理 (Lines 268-269, 
  328-329)

  bridge_thread = threading.Thread(target=st
  art_bridge_server, daemon=False)
  bridge_thread.start()
  flask_thread = threading.Thread(target=sta
  rt_flask_server, daemon=False)
  flask_thread.start()
  - 问题:
    a. 线程启动后无法被停止（没有保存引用）
    b. cleanup() 函数不会清理这些线程
    c. 异常时线程可能继续运行
  - 建议: 保存线程引用并在 cleanup 中处理
  self.bridge_thread = threading.Thread(...)
  self.flask_thread = threading.Thread(...)

  def cleanup(signum=None, frame=None):
      print("Cleaning up processes...")
      if hasattr(self, 'bridge_thread') and
  self.bridge_thread.is_alive():
          # Add graceful shutdown mechanism
          pass



  🟢 轻微: 硬编码的睡眠时间 (Lines 272, 332)

  time.sleep(2)
  - 问题:
    a. 魔法数字，不可配置
    b. 2
  秒可能不足（网络慢时）或过长（本地测试时）
  - 建议:
  STARTUP_WAIT_TIME =
  float(os.getenv("STARTUP_WAIT_SECONDS",
  "2"))
  time.sleep(STARTUP_WAIT_TIME)


    🔴 严重: 无限循环无法中断 (Lines 347-352)

  try:
      while True:
          time.sleep(1)
  except KeyboardInterrupt:
      print("\n🛑 Server stopped by user")
      cleanup()
  - 问题:
    a. 在后台运行时（python3 script.py 
  &），无法通过 Ctrl+C 停止
    b. 如果线程崩溃，主进程仍会继续运行
    c. 没有健康检查机制
  - 建议:
  try:
      while True:
          # Check if threads are still alive
          if not bridge_thread.is_alive() or
   not flask_thread.is_alive():
              logger.error("One or more 
  server threads died unexpectedly")
              break
          time.sleep(1)
  except KeyboardInterrupt:
      logger.info("Server stopped by user")
  finally:
      cleanup()


🟡 中等: 端口冲突无法检测 (Lines 137, 
  318-323)

  run_server(self.bridge, host="0.0.0.0",
  port=PORT)
  run_ui_agent_https.app.run(host="0.0.0.0",
   port=api_port, ...)
  - 问题: 如果端口被占用，程序会崩溃，且错误
  信息不明确
  - 建议: 启动前检查端口可用性
  import socket

  def is_port_available(port):
      try:
          with socket.socket(socket.AF_INET,
   socket.SOCK_STREAM) as s:
              s.bind(("", port))
              return True
      except OSError:
          return False

  if not is_port_available(PORT):
      raise RuntimeError(f"Port {PORT} is 
  already in use")



  🟡 中等: 随机 Agent ID 可能冲突 (Lines 
  218-227)

  random_number = random.randint(100000,
  999999)
  if "nanda-registry.com" in domain:
      agent_id = f"agentm{random_number}"
  - 问题:
    a. 没有检查 ID 是否已存在
    b. random 模块不是加密安全的
    c. 6 位数字空间较小，容易碰撞
  - 建议:
  import secrets
  random_number = secrets.randbelow(1000000)
   + 1000000  # 7-digit number
  # Or use UUID
  import uuid
  agent_id = f"agent-{uuid.uuid4().hex[:8]}"



🟡 中等: 硬编码域名 (Lines 222, 344)

  if "nanda-registry.com" in domain:
  print(f"https://chat.nanda-registry.com/la
  nding.html?agentId={agent_id}")
  - 问题:
    a. 域名检查太简单，可被
  fake-nanda-registry.com 绕过
    b. 硬编码 URL 不灵活
  - 建议:
  ALLOWED_REGISTRY_DOMAINS =
  ["nanda-registry.com"]
  parsed_domain = domain.split(':')[0]  # 
  Remove port if exists
  if parsed_domain in
  ALLOWED_REGISTRY_DOMAINS:
      agent_id = f"agentm{random_number}"

  REGISTRY_LANDING_URL = os.getenv(
      "REGISTRY_LANDING_URL",
      "https://chat.nanda-registry.com/landi
  ng.html"
  )
  print(f"{REGISTRY_LANDING_URL}?agentId={ag
  ent_id}")




NANDA adapter 存在多个严重的认证和信任机制缺陷:

  🔴 关键安全漏洞

  1. 完全缺乏身份认证机制

  - agent_bridge.py:706-1001 - handle_message 方法接受任何来源的消息,无任何身份验证
  - 任何客户端都可以向 /a2a 端点发送消息而无需提供凭证
  - 没有 API 密钥、令牌或任何形式的身份验证检查

  # agent_bridge.py:706
  def handle_message(self, msg: Message) -> Message:
      # 直接处理消息,无认证检查
      user_text = msg.content.text

  2. Agent 间通信缺乏信任验证

  - agent_bridge.py:349-406 - send_to_agent 函数允许伪造发送者身份
  - agent_bridge.py:520-614 - handle_external_message 仅通过消息格式解析来识别发送者
  - 攻击者可以轻易伪造 __FROM_AGENT__ 字段冒充其他 Agent

  # agent_bridge.py:368
  formatted_message = f"__EXTERNAL_MESSAGE__\n__FROM_AGENT__{agent_id}\n..."
  # 这个格式可以被任何攻击者复制

  3. Registry 注册机制无验证

  - agent_bridge.py:97-118 - 注册到 Registry 时无需身份验证
  - 任何人都可以注册任意 agent_id,导致:
    - Agent ID 劫持攻击
    - 中间人攻击
    - 服务拒绝攻击

  # agent_bridge.py:109
  response = requests.post(f"{registry_url}/register", json=data)
  # 无任何凭证或签名验证

  4. SSL/TLS 证书验证被禁用

  - agent_bridge.py:333 - verify=False 禁用 SSL 证书验证
  - run_ui_agent_https.py:87, 107, 211, 244 - 多处禁用证书验证
  - 这使系统容易受到中间人攻击

  # agent_bridge.py:333
  response = requests.post(ui_client_url, json={...}, verify=False)

  5. 环境变量中硬编码的敏感信息

  - agent_bridge.py:30 - API 密钥可能被硬编码为 "your key"
  - agent_bridge.py:75-77 - Smithery API 密钥硬编码在代码中
  - 密钥泄露风险极高

  # agent_bridge.py:30
  ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY") or "your key"
  # agent_bridge.py:75
  SMITHERY_API_KEY = os.getenv("SMITHERY_API_KEY") or "bfcb8cec-9d56-4957-8156-bced0bfca532"

  6. 无消息完整性保护

  - 消息在传输过程中没有签名或 MAC
  - 无法验证消息是否被篡改
  - 攻击者可以修改消息内容而不被检测

  7. 缺乏速率限制和资源控制

  - 无请求频率限制
  - 容易遭受 DoS 攻击
  - 恶意 Agent 可以耗尽系统资源

  8. UI 客户端通信无认证

  - agent_bridge.py:313-346 - send_to_ui_client 无需认证
  - run_ui_agent_https.py:231-275 - /api/receive_message 端点无访问控制
  - 任何人都可以向 UI 推送虚假消息

  9. MCP 服务器调用无授权检查

  - agent_bridge.py:826-879 - MCP 命令处理无权限验证
  - 用户可以调用任意 MCP 服务器
  - Smithery API 密钥通过 URL 参数传递(agent_bridge.py:476)

  10. 日志可能泄露敏感信息

  - agent_bridge.py:154-172 - 所有消息被记录到 JSON 文件
  - 无加密或访问控制
  - 可能包含敏感用户数据

  📊 风险评估

  | 漏洞类型        | 严重程度  | 可利用性  | 影响范围      |
  |-------------|-------|-------|-----------|
  | 无身份认证       | 🔴 严重 | 🔴 极易 | 整个系统      |
  | Agent 身份伪造  | 🔴 严重 | 🔴 极易 | Agent 间通信 |
  | Registry 劫持 | 🟠 高  | 🔴 极易 | 服务发现      |
  | SSL 验证禁用    | 🔴 严重 | 🟠 中等 | 所有网络通信    |
  | 硬编码密钥       | 🟠 高  | 🔴 极易 | API 访问    |
  | 无完整性保护      | 🟠 高  | 🟠 中等 | 消息传输      |
  | 无速率限制       | 🟡 中  | 🔴 极易 | 服务可用性     |
  | UI 推送无认证    | 🟠 高  | 🔴 极易 | 用户界面      |

  🎯 攻击场景示例

  1. Agent 劫持攻击: 攻击者注册一个已存在的 agent_id,截获发往该 Agent 的所有消息
  2. 消息注入攻击: 伪造 __EXTERNAL_MESSAGE__ 格式,以其他 Agent 身份发送虚假消息
  3. 中间人攻击: 利用 verify=False,拦截并修改 HTTPS 通信
  4. 资源耗尽攻击: 大量无认证请求导致服务崩溃

  🛡️ 建议修复措施

  1. 实施强身份认证: JWT 令牌、API 密钥或 mTLS
  2. Agent 间通信签名: 使用公钥基础设施(PKI)验证 Agent 身份
  3. 启用 SSL 证书验证: 移除所有 verify=False
  4. 密钥管理: 使用密钥管理服务(如 AWS KMS、HashiCorp Vault)
  5. 消息签名: 实现 HMAC 或数字签名确保完整性
  6. 实施速率限制: 使用 Flask-Limiter 等中间件
  7. 访问控制: 基于角色的访问控制(RBAC)
  8. 审计日志加密: 加密敏感日志并限制访问


前后端的结合:
我们需要再每个api call都加入令牌身份验证

## Current Authentication Issues (2024-10-05)

### 1. EC2 SSL Certificate Problem
**Error**: `Certificate files not found at specified paths`
**Root Cause**:
- System expects `./fullchain.pem` and `./privkey.pem`
- Can't use Let's Encrypt with IP address (18.224.228.207)
- Previous OpenSSL command created empty files (0 bytes)

**Solution**:
```bash
cd ~/tresata_challenge
rm -f privkey.pem fullchain.pem

# Two-step certificate generation
openssl genrsa -out privkey.pem 4096
openssl req -new -x509 -key privkey.pem -out fullchain.pem -days 365 -subj "/CN=18.224.228.207"

# Verify
ls -lh *.pem
# Expected: fullchain.pem (~1.8K), privkey.pem (~3.2K)
```

### 2. CORS and API Timeout Issues
**Symptoms**:
- `Cross-Origin Request Blocked` on https://chat.nanda-registry.com:6900/api/check-user
- Google Sign-In successful but backend API calls timing out (5s timeout)
- Error: `API call timed out after 5 seconds`

**Root Causes**:
- Registry server may be down or unreachable from client
- CORS preflight requests failing
- Backend not responding to `/api/check-user` endpoint

**Investigation Needed**:
- Check if registry server is running
- Verify CORS headers on all endpoints (especially OPTIONS method)
- Test API endpoint directly: `curl https://chat.nanda-registry.com:6900/api/check-user`

### 3. Authentication Flow Issues
**Current Flow**:
1. ✅ Google Sign-In successful (usgaojin@gmail.com)
2. ❌ `/api/check-user` call times out
3. ❌ Cannot complete user registration

**Proposed Fix** - Add Session Token Authentication:

#### Frontend Changes (landing.html or chat interface):
```javascript
// Auto-initialize session on page load
let sessionToken = localStorage.getItem('nanda_session');

async function initSession() {
    if (!sessionToken) {
        const response = await fetch('https://chat.nanda-registry.com:6900/api/session/init', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                email: userEmail,  // From Google Sign-In
                provider: 'google'
            })
        });
        const data = await response.json();
        sessionToken = data.token;
        localStorage.setItem('nanda_session', sessionToken);
    }
}

// Add token to all API calls
async function apiCall(endpoint, data) {
    const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-Session-Token': sessionToken,  // Add authentication
            'X-User-Email': userEmail
        },
        body: JSON.stringify(data)
    });

    // Handle token expiration
    if (response.status === 401) {
        sessionToken = null;
        localStorage.removeItem('nanda_session');
        await initSession();
        return apiCall(endpoint, data);  // Retry
    }

    return response.json();
}
```

#### Backend Changes Needed:
1. Add `/api/session/init` endpoint to create sessions
2. Add session verification middleware to all API endpoints
3. Implement HMAC-signed tokens to prevent forgery
4. Add proper CORS handling for OPTIONS requests

### 4. Network Environment Challenges
**Context**: Deployment from China with MIT VPN
**Issues**:
- AWS services intermittently unreachable
- Anthropic/OpenAI APIs blocked in mainland China
- SSL certificate verification may fail due to network proxies

**Recommendations**:
- Use Chinese model providers (Alibaba Qwen, Baidu Wenxin) as fallback
- Implement retry logic with exponential backoff
- Add `verify=False` option for development (with warning)
- Consider using Cloudflare or Chinese CDN for static assets



The current code uses SSL mode when domain != "localhost", but on EC2 you need to disable SSL.

## ✅ Solution Implemented (2024-10-05)

### Changes Made

1. **Modified `langchain_diy.py`**: Added `ENABLE_SSL` environment variable support
   - Default: `ssl=False` for EC2 deployment
   - Can be enabled with `ENABLE_SSL=true` when certificates are available

2. **Updated `.env`**: Added SSL configuration
   ```bash
   ENABLE_SSL=false  # No certificates needed for HTTP mode
   ```

3. **Created `EC2_DEPLOYMENT.md`**: Complete guide for HTTP deployment without SSL
   - Step-by-step EC2 setup
   - Security considerations for HTTP mode
   - Future SSL upgrade path

### How to Deploy on EC2 (HTTP Mode)

```bash
# On your EC2 instance:
cd ~/tresata_challenge

# Make sure .env has ENABLE_SSL=false
echo "ENABLE_SSL=false" >> .env

# Run the backend
./2_run_backend.sh
```

The agent will now start on **HTTP mode** without requiring SSL certificates!

### Access URLs

- **Agent Bridge**: `http://YOUR_EC2_IP:3737/a2a`
- **API Health**: `http://YOUR_EC2_IP:3737/api/health`
- **API Send**: `http://YOUR_EC2_IP:3737/api/send`

Make sure port 3737 is open in your EC2 Security Group.

What I did:




I'm currently traveling in China (temporarly for a conference) and using MIT VPN to be able to access the development - it is really hard under such internet environment. I have to say it is really leveraging the difficulties, as both openai and claude is not supporting Hong Kong and China Mainland. If possible, I'd also suggest add Chinese model provider support and test nanda access in the China network.

PS: I got the challenge email during airport transfer and more than half of the challenge time I was on air and immigration process. I have to say it is an extremely challenging timing for me given the short timeframe. I was trying my best to squeeze out all possible seconds during I was waiting the boarding and not sleep the whole night before the DDL - the Chinese internet make everything a new level of challenge - which I'd love to tackle!

Thank you so much for your understanding. Maybe some of the behavior of the project is not as expected on your end - it may due to internet issue, and I was trying my best to make it work on my end.

