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

# ── 聊天模块配置 ─────────────────────────────────────────
CHAT_SYSTEM_PROMPT = """你是一位专注于青年就业权益保护的公益律师"法小智"。

## 你的职责
1. 帮助刚步入职场的年轻人解答劳动法、劳动合同法相关的问题。
2. 用通俗易懂的语言解释法律条文，让非法律专业人士也能理解。
3. 如果用户问的不是法律问题，也可以友好地聊天，但尽量引导回法律话题。

## 回答原则
- 回答应当准确、清晰、有依据。
- 涉及具体法律条文时，引用条文编号和内容。
- 如果不知道确切答案，坦诚告知，不要编造法律条文。
- 保持友好、耐心的公益律师形象。"""

# 聊天历史最多保留的消息轮数（用户+助手一对算1轮）
CHAT_HISTORY_MAX_ROUNDS = 10

# 法律关键词列表（用于判断是否需要 RAG 检索）
LEGAL_KEYWORDS = [
    "试用期", "工资", "加班", "加班费", "加班工资", "加班时间",
    "竞业限制", "竞业", "违约金", "赔偿金", "经济补偿", "补偿金",
    "社保", "五险一金", "公积金", "养老保险", "医疗保险", "失业保险",
    "劳动合同", "合同", "签约", "签约期限", "固定期限", "无固定期限",
    "辞职", "离职", "辞退", "开除", "解雇", "解除", "终止",
    "工伤", "职业病", "医疗期", "病假", "婚假", "产假", "年假",
    "培训", "服务期", "培训费", "培训服务期",
    "实习", "实习期", "见习", "见习期",
    "offer", "录用", "录用通知", "聘用",
    "劳动法", "劳动合同法", "劳动仲裁", "仲裁", "诉讼", "法院",
    "最低工资", "标准工时", "综合工时", "不定时工作",
    "派遣", "劳务派遣", "外包",
    "培训贷", "贷款", "收费", "押金", "保证金",
    "小时工", "兼职工", "派遣工",
]

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
