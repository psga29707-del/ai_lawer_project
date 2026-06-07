import logging
import time

from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from openai import RateLimitError

from config import (
    LLM_API_KEY,
    LLM_BASE_URL,
    LLM_MODEL,
    MODIFY_SYSTEM_PROMPT,
    SYSTEM_PROMPT,
)
from services.database import search_relevant_laws

logger = logging.getLogger(__name__)

_RETRY_MAX = 3
_RETRY_DELAY = 5  # seconds

llm = ChatOpenAI(
    model=LLM_MODEL,
    temperature=0.2,
    openai_api_key=LLM_API_KEY,
    openai_api_base=LLM_BASE_URL,
)


def _invoke_with_retry(chain, inputs: dict) -> str:
    """带指数退避重试的 LCEL 链调用，应对 API 限流（429）。"""
    last_exc = None
    for attempt in range(1, _RETRY_MAX + 1):
        try:
            return chain.invoke(inputs)
        except RateLimitError as exc:
            last_exc = exc
            wait = _RETRY_DELAY * (2 ** (attempt - 1))
            logger.warning("LLM 调用限流 (429)，第 %s/%s 次重试，等待 %ss", attempt, _RETRY_MAX, wait)
            time.sleep(wait)
    raise RuntimeError(f"LLM 调用多次重试后仍失败（429 限流）") from last_exc


def _build_rag_prompt(system_prompt: str) -> ChatPromptTemplate:
    """构造包含系统人设与 RAG 上下文的 ChatPromptTemplate（LCEL 就绪）。"""
    human_template = """以下是从法律知识库检索到的相关法规与条款：

{laws_context}

---

请基于上述法律依据，审查以下合同文本：

{contract_text}
"""
    return ChatPromptTemplate.from_messages([
        ("system", system_prompt),
        ("human", human_template),
    ])


def generate_legal_report(contract_text: str) -> str:
    """生成合同法律审查报告：RAG 检索 → LCEL 链推理 → Markdown 报告。"""
    try:
        relevant_laws = search_relevant_laws(contract_text, n_results=3)
        laws_context = "\n\n".join(relevant_laws) if relevant_laws else "未检索到相关法律条文。"
        prompt = _build_rag_prompt(SYSTEM_PROMPT)
        chain = prompt | llm | StrOutputParser()
        return _invoke_with_retry(chain, {
            "contract_text": contract_text,
            "laws_context": laws_context,
        })
    except Exception as exc:
        logger.exception("生成审查报告时大模型调用失败")
        raise RuntimeError(str(exc)) from exc


def modify_contract_text(contract_text: str) -> str:
    """根据检索到的法律依据，输出合规化的合同文本重写结果。"""
    try:
        relevant_laws = search_relevant_laws(contract_text, n_results=3)
        laws_context = "\n\n".join(relevant_laws) if relevant_laws else "未检索到相关法律条文。"
        prompt = _build_rag_prompt(MODIFY_SYSTEM_PROMPT)
        chain = prompt | llm | StrOutputParser()
        return _invoke_with_retry(chain, {
            "contract_text": contract_text,
            "laws_context": laws_context,
        })
    except Exception as exc:
        logger.exception("合同文本修改调用失败")
        raise RuntimeError(str(exc)) from exc
