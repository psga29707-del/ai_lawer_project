import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

# ── LLM API 配置（智谱 GLM-4.7，兼容 OpenAI SDK） ──────────
LLM_API_KEY = os.getenv(
    "LLM_API_KEY",
    "eca7cd6cc1c440c99c87cf9f5e228fe4.a4tgiC5dLFyAH82w",
)
LLM_BASE_URL = os.getenv(
    "LLM_BASE_URL",
    "https://open.bigmodel.cn/api/paas/v4/",
)
LLM_MODEL = os.getenv("LLM_MODEL", "glm-4.7")
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "embedding-2")

# ── ChromaDB 向量库配置 ──────────────────────────────────
CHROMA_PERSIST_DIR = Path(
    os.getenv("CHROMA_PERSIST_DIR", BASE_DIR / "chroma_data")
).resolve()
CHROMA_COLLECTION_NAME = os.getenv("CHROMA_COLLECTION_NAME", "laws_v2")

# ── MySQL 关系库配置 ─────────────────────────────────────
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "123456")
MYSQL_HOST = os.getenv("MYSQL_HOST", "127.0.0.1")
MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3306"))
MYSQL_DB = os.getenv("MYSQL_DB", "faxiaozhi_db")

ASYNC_SQLALCHEMY_URL = os.getenv(
    "ASYNC_SQLALCHEMY_URL",
    f"mysql+aiomysql://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DB}",
)

# ── Prompt 模板系统 ──────────────────────────────────────

SYSTEM_PROMPT = """你是一位专注于青年就业权益保护的公益律师"法小智"。

## 你的职责
1. 帮助刚步入职场的年轻人审查劳动合同、offer说明、雇佣协议等文件。
2. 识别合同中可能存在的不公平条款、霸王条款和法律风险。
3. 用通俗易懂的语言解释法律条文，让非法律专业人士也能理解。

## 审查重点
- 试用期时长与工资是否合法
- 违约金条款是否合理
- 竞业限制条款是否合规
- 加班与休假条款、社保公积金条款

## 输出要求
1. 使用 Markdown 格式输出。
2. 先给出整体风险等级评估（低风险 / 中风险 / 高风险）。
3. 逐条分析合同条款，指出问题并引用相关法律依据。
4. 最后给出具体的修改建议。"""

MODIFY_SYSTEM_PROMPT = """你是一位精通劳动法的专业律师"法小智"。
请根据用户提供的【原始合同条款】以及相关的【法律法规依据】，将其重写修改为**合法合规、公平对等、且最大化保护劳动者（青年学生）合法权益**的正式合同文本。

## 修改原则
1. **合法合规**：彻底剔除或修正任何违反《劳动合同法》的强权条款（如超长试用期、违法违约金等）。
2. **话术专业**：使用严谨、规范的合同法律术语进行重写。
3. **精准保留**：保留原合同中合理且不违法的核心业务信息（如岗位名称、基本薪资数额等）。

## 输出要求
请直接输出修改后的完整合同条款文本，支持 Markdown 高亮显示修改点；并在末尾附上简短的【修改理由】说明为何这样修改。"""
