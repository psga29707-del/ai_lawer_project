"""
法小智 AI Agent：基于 LangChain Agent 框架的智能合同修改助手
==============================================================
工作流程:
  1. Agent 分析合同，自主识别有问题的条款
  2. 对每个问题条款，按需调用 search_law 检索相关法条
  3. 基于准确的法条依据，逐条修改
  4. 最终汇总输出完整修改版
"""

import logging
from typing import Annotated

from langchain.agents import create_agent
from langchain_core.tools import tool
from langchain_openai import ChatOpenAI

from config import LLM_API_KEY, LLM_BASE_URL, LLM_MODEL
from services.database import search_relevant_laws

logger = logging.getLogger(__name__)

llm = ChatOpenAI(
    model=LLM_MODEL,
    temperature=0.2,
    openai_api_key=LLM_API_KEY,
    openai_api_base=LLM_BASE_URL,
)


# ── 工具定义（Agent 的"手"） ──────────────────────────────

@tool
def search_law(query: Annotated[str, "法律问题关键词，如'试用期工资'、'竞业限制补偿金'"]):
    """从法律知识库中检索与问题相关的法律条文"""
    try:
        results = search_relevant_laws(query, n_results=3)
        return "\n\n".join(results) if results else "未检索到相关法律条文。"
    except Exception as e:
        logger.error("法律检索失败: %s", e)
        return "检索失败，请稍后重试。"


# ── Agent System Prompt ────────────────────────────────────

AGENT_SYSTEM_PROMPT = """你是"法小智"——一位精通劳动法的智能合同审查与修改助手。

## 你的工作流程
1. 仔细阅读用户提供的合同条款
2. 逐条判断是否合法、公平
3. 对每一条有问题的条款，使用 search_law 工具检索对应的法律依据
4. 依据检索到的法律条文进行修改
5. 最终输出完整的修改后合同

## 核心原则
- 每修改一条有问题的条款，都必须先检索对应的法条作为依据
- 保留合同中合法合理的部分，不要无中生有
- 修改方向始终是"最大化保护劳动者权益且合法合规"
- 逐条处理：发现问题 → 检索法条 → 修改 → 下一条
- 所有条款审查修改完成后，输出完整修改版

## 输出格式要求
请按以下格式输出：

# 修改后合同

（完整的修改后合同文本）

---

# 修改说明

## 修改点 1：XXX
- **原条款**：...
- **问题**：...
- **法律依据**：...
- **修改后**：...

## 修改点 2：XXX
（以此类推）
"""


# ── 构建 Agent ────────────────────────────────────────────

agent = create_agent(
    model=llm,
    tools=[search_law],
    system_prompt=AGENT_SYSTEM_PROMPT,
    name="法小智-Agent",
)


def agent_modify_contract(contract_text: str) -> str:
    """Agent 版合同修改：逐条分析→检索→修改→汇总"""
    try:
        result = agent.invoke({"messages": [("human", contract_text)]})
        # 取最后一条 AI 消息作为输出
        messages = result.get("messages", [])
        for msg in reversed(messages):
            if hasattr(msg, "type") and msg.type == "ai":
                return msg.content
        # 兜底：返回全部消息的文本
        return "\n".join(str(m.content) for m in messages if hasattr(m, "content"))
    except Exception as e:
        logger.exception("Agent 合同修改失败")
        raise RuntimeError(f"合同修改失败: {e}") from e
