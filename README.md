# 法小智 (Faxaozhi) — AI 智能法律审查平台

<div align="center">

**面向青年就业权益保护的劳动合同智能审查系统**

![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115+-green?logo=fastapi)
![Vue 3](https://img.shields.io/badge/Vue-3.3-4FC08D?logo=vue.js)
![License](https://img.shields.io/badge/License-MIT-yellow)

</div>

---

## 项目简介

**法小智**是一个面向职场新人的 AI 法律审查助手。用户只需粘贴劳动合同或协议文本，系统即可自动识别不公平条款，并基于法律知识库生成结构化风险审查报告或合规修改建议。同时还提供 AI 法律问答聊天功能（"单纯聊聊"），支持条件 RAG、对话持久化记忆和流式输出。

> **核心场景**：
> - 刚毕业的大学生审查 Offer / 劳动合同
> - 识别试用期、违约金、竞业限制等常见陷阱
> - 一键生成合规修改后的合同文本
> - 随时咨询劳动法、职场权益相关问题

---

## 技术栈

| 层级 | 技术 | 用途 |
|------|------|------|
| **后端框架** | FastAPI + uvicorn (端口 8001) | RESTful API 网关 |
| **大模型** | 智谱 GLM-4.7（兼容 OpenAI SDK） | 审查报告生成、条款修改 |
| **Embedding** | 智谱 embedding-2 | 语义向量化 |
| **向量数据库** | ChromaDB（本地持久化） | 法条语义检索（RAG） |
| **关系数据库** | MySQL + SQLAlchemy 异步 ORM | 用户注册 / 登录 |
| **AI Agent** | LangChain Agent 框架 | 逐条分析 → 检索 → 修改 |
| **前端** | JSP + Vue 3 + Bootstrap 5 + Three.js | 暗色控制台审查工作台 + 聊天界面 |
| **AI 对话** | SSE 流式 + 条件 RAG + 持久化记忆 | "单纯聊聊"法律问答功能 |
| **部署** | 前端 → Tomcat / 后端 → uvicorn | 前后端分离 |

---

## 项目结构

```
ai_lawer_project/
└── Faxiaozhi-Project/
    ├── ai-backend-fastapi/          # FastAPI 后端服务
    │   ├── main.py                  # API 路由入口（11 个接口）
    │   ├── config.py                # 全局配置（LLM/Chroma/MySQL/Prompts/聊天）
    │   ├── models/                  # SQLAlchemy 数据模型
    │   │   ├── base.py
    │   │   ├── user.py              # UserModel（users 表）
    │   │   ├── conversation.py      # ConversationModel（对话记录表）
    │   │   └── message.py           # MessageModel（消息记录表）
    │   ├── services/                # 核心业务服务
    │   │   ├── mysql_db.py          # MySQL 异步引擎 + 会话管理
    │   │   ├── database.py          # ChromaDB 向量存储 + 语义检索
    │   │   ├── llm_agent.py         # LCEL 链（RAG + LLM 推理）
    │   │   ├── legal_agent.py       # LangChain Agent 智能修改
    │   │   └── chat_service.py      # 流式聊天服务（条件RAG + 记忆加载）
    │   ├── scripts/                 # 工具脚本
    │   │   ├── init_db.py           # ChromaDB 初始化（5 条基础法条）
    │   │   ├── import_markdown_to_chroma.py  # 批量导入 Markdown 法条
    │   │   └── prepare_law_markdown.py       # JSON 法条 → Markdown 转换
    │   ├── legal_knowledge_base/    # 法律知识库（19 个 Markdown 文件）
    │   │   ├── labor_law/           # 劳动法相关（16 条）
    │   │   ├── education_law/       # 教育法 / 实习规定
    │   │   ├── consumer_protection/ # 培训贷防范
    │   │   └── judicial_cases/      # 典型案例
    │   └── chroma_data/             # ChromaDB 持久化（24 条向量）
    ├── web-frontend-jsp/            # JSP 前端页面
    │   ├── login.jsp                # 登录 / 注册（毛玻璃 + Shader 背景）
    │   ├── inspect.jsp              # 合同审查控制台（暗色主题）
    │   └── WEB-INF/web.xml          # Tomcat 部署配置
    └── docs/
        └── specs/                   # 设计规格文档
```

---

## 快速开始

### 前置依赖

- Python 3.12+
- MySQL 8.0+
- 智谱 GLM API Key（[开放平台申请](https://open.bigmodel.cn/)）

### 安装

```bash
# 1. 克隆仓库
git clone https://github.com/psga29707-del/ai_lawer_project.git
cd ai_lawer_project/Faxiaozhi-Project/ai-backend-fastapi

# 2. 安装 Python 依赖
pip install -r requirements.txt

# 3. 配置环境变量（或直接修改 config.py）
# LLM_API_KEY=你的智谱API密钥
# MYSQL_PASSWORD=你的MySQL密码

# 4. 初始化 ChromaDB 法律知识库
python scripts/init_db.py
# （可选）批量导入 19 条法条
python scripts/import_markdown_to_chroma.py

# 5. 启动后端服务
python -m uvicorn main:app --reload --port 8001
```

### 部署前端

将 `web-frontend-jsp/` 整个文件夹复制到 Tomcat 的 `webapps/` 目录下，重命名为 `faxiaozhi`，访问：

```
http://localhost:8080/faxiaozhi/login.jsp
```

> 前端页面默认连接 `http://127.0.0.1:8001/api/v1` 后端，可根据实际地址修改 `login.jsp` 和 `inspect.jsp` 中的 `API_BASE`。

---

## API 接口一览

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/v1/register` | 用户注册（SHA256 密码） |
| POST | `/api/v1/login` | 用户登录验证 |
| POST | `/api/v1/review` | **免登录**一键合同审查（RAG + LLM） |
| POST | `/api/v1/user_review` | 需登录的用户审查（MySQL 校验） |
| POST | `/api/v1/agent_modify` | **Agent 智能修改**（逐条分析→检索→重写） |
| POST | `/api/v1/modify` | 简单版合同修改 |
| POST | `/api/v1/chat/conversations` | 获取用户对话列表 |
| POST | `/api/v1/chat/conversations/create` | 创建新对话 |
| POST | `/api/v1/chat/conversations/{id}/messages` | 获取对话消息历史 |
| DELETE | `/api/v1/chat/conversations/{id}` | 删除对话 |
| POST | `/api/v1/chat/stream` | **SSE 流式聊天**（条件 RAG + 流式输出） |

### 调用示例

```bash
# 合同审查
curl -X POST http://127.0.0.1:8001/api/v1/review \
  -H "Content-Type: application/json" \
  -d '{"text": "试用期三个月，试用期工资为转正工资的60%"}'

# Agent 智能修改
curl -X POST http://127.0.0.1:8001/api/v1/agent_modify \
  -H "Content-Type: application/json" \
  -d '{"text": "员工离职需提前三个月通知，否则支付违约金"}'

# 流式聊天（SSE）
curl -N -X POST http://127.0.0.1:8001/api/v1/chat/stream \
  -H "Content-Type: application/json" \
  -d '{"username": "your_name", "message": "试用期最长多久？"}'
```

---

## 核心工作流程

### 合同审查流程

```
用户输入合同文本
       ↓
ChromaDB 语义检索（top-3 相关法条）
       ↓
LCEL 链组装（System Prompt + RAG 上下文 + 合同文本）
       ↓
GLM-4.7 LLM 推理 + 指数退避重试（防 429 限流）
       ↓
Markdown 格式审查报告
```

### Agent 智能修改流程

```
Agent 分析合同
       ↓
逐条识别问题条款
       ↓
调用 search_law 工具检索对应法条
       ↓
基于法条逐条修改
       ↓
汇总输出完整修改版 + 修改说明
```

### "单纯聊聊"聊天流程

```
用户输入消息
       ↓
关键词检测（是否涉及法律话题？）
       ├── 是 → ChromaDB 检索相关法条（条件 RAG）
       └── 否 → 跳过检索，直接进入 LLM
       ↓
从 MySQL 加载最近 10 轮对话历史
       ↓
构建消息列表（系统人设 + RAG 上下文 + 历史 + 当前消息）
       ↓
LLM 流式生成（SSE 逐 token 推送）
       ↓
流结束后自动保存对话到 MySQL
```

---

## 法律知识库

ChromaDB 中已存储 **24 条**法律知识，涵盖：

- **劳动合同法核心条款**：试用期、试用期工资、服务期违约金、竞业限制、经济补偿
- **劳动保护**：工时与加班规定、社保、未成年工保护
- **离职相关**：员工辞职、被迫辞职、用人单位解除、经济补偿
- **典型案例**：8 个劳动纠纷司法案例
- **专项领域**：实习生规定、培训贷防范、加班举证责任

---

## 已知限制

| 问题 | 说明 | 缓解方案 |
|------|------|----------|
| **检索慢** | ChromaDB 检索 ~9s（因智谱 embedding-2 API 响应慢） | 前端设 120s 超时 |
| **生成慢** | LLM 生成 30-50s | 已使用流式 SSE 分片输出 |
| **密码安全** | 目前使用 SHA256（非 bcrypt/argon2） | 后续迭代改进 |
| **无 Token** | 登录后未签发 JWT Token | 当前用 localStorage 存用户名 |
| **环境依赖** | 需使用系统 Python（非 Anaconda）避免 langchain-openai 版本过旧 | 确认 `langchain-openai>=1.3.0` |

---

## 开发计划

- [ ] 换用本地 embedding 模型加速检索
- [ ] 引入 Redis 缓存热点法条
- [ ] 支持 PDF 合同文件上传
- [ ] 管理后台：用户管理 + 法条编辑
- [ ] 增加律师在线咨询对接功能

---

## 许可证

[MIT License](LICENSE)

---

<div align="center">
  <sub>© 2026 法小智 · 面向青年就业权益保护 · 仅供学习参考</sub>
</div>
