


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





What I did:




I'm currently traveling in China (temporarly for a conference) and using MIT VPN to be able to access the development - it is really hard under such internet environment. I have to say it is really leveraging the difficulties, as both openai and claude is not supporting Hong Kong and China Mainland. If possible, I'd also suggest add Chinese model provider support and test nanda access in the China network.

PS: I got the challenge email during airport transfer and more than half of the challenge time I was on air and immigration process. I have to say it is an extremely challenging timing for me given the short timeframe. I was trying my best to squeeze out all possible seconds during I was waiting the boarding and not sleep the whole night before the DDL - the Chinese internet make everything a new level of challenge - which I'd love to tackle!

Thank you so much for your understanding. Maybe some of the behavior of the project is not as expected on your end - it may due to internet issue, and I was trying my best to make it work on my end.

