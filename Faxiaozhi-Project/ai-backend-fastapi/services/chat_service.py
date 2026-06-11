"""
聊天服务模块："单纯聊聊"功能核心
====================================
提供关键词检测、条件RAG、对话记忆加载、流式LLM生成等功能。
"""
import asyncio
import logging
from datetime import datetime
from typing import AsyncGenerator

from langchain_core.messages import SystemMessage, HumanMessage, AIMessage
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from sqlalchemy import select, desc, func, delete
from sqlalchemy.ext.asyncio import AsyncSession

from config import (
    LLM_API_KEY, LLM_BASE_URL, LLM_MODEL,
    CHAT_SYSTEM_PROMPT, CHAT_HISTORY_MAX_ROUNDS, LEGAL_KEYWORDS,
)
from models.conversation import ConversationModel
from models.message import MessageModel
from services.database import search_relevant_laws

logger = logging.getLogger(__name__)

# 独立的聊天专用 LLM 实例（开启 streaming）
chat_llm = ChatOpenAI(
    model=LLM_MODEL,
    temperature=0.7,
    openai_api_key=LLM_API_KEY,
    openai_api_base=LLM_BASE_URL,
    streaming=True,
)


def detect_legal_keywords(text: str) -> list[str]:
    """检测用户输入是否包含法律关键词。

    使用预定义关键词列表做子串匹配，不依赖NLP。
    返回匹配到的关键词列表，空列表表示无法律相关话题。
    """
    matched = []
    for keyword in LEGAL_KEYWORDS:
        if keyword in text:
            matched.append(keyword)
    return matched


async def load_conversation_history(
    session: AsyncSession,
    conversation_id: int,
    max_rounds: int = CHAT_HISTORY_MAX_ROUNDS,
) -> list[dict]:
    """从 MySQL 加载最近 N 轮对话历史。"""
    stmt = (
        select(MessageModel)
        .where(MessageModel.conversation_id == conversation_id)
        .order_by(desc(MessageModel.created_at))
        .limit(max_rounds * 2)  # user + assistant 算一轮
    )
    result = await session.execute(stmt)
    messages = result.scalars().all()
    messages.reverse()  # 恢复时间正序
    return [{"role": m.role, "content": m.content} for m in messages]


def _build_llm_messages(
    user_message: str,
    history: list[dict],
    laws_context: str | None,
) -> list:
    """构建完整 LLM 消息列表：系统人设 + (RAG上下文) + 历史 + 当前消息。"""
    messages = [SystemMessage(content=CHAT_SYSTEM_PROMPT)]

    if laws_context:
        messages.append(HumanMessage(
            content=f"【以下是从法律知识库检索到的相关法规，请在回答中参考使用】\n\n{laws_context}\n\n（请基于上述法律依据和你的专业知识回答用户问题。）"
        ))

    for msg in history:
        if msg["role"] == "user":
            messages.append(HumanMessage(content=msg["content"]))
        else:
            messages.append(AIMessage(content=msg["content"]))

    messages.append(HumanMessage(content=user_message))
    return messages


async def generate_chat_response(
    user_message: str,
    conversation_id: int,
    session: AsyncSession,
) -> AsyncGenerator[str, None]:
    """核心聊天生成函数（流式）。

    流程：
    1. 关键词检测
    2. 匹配时检索 ChromaDB 获取 RAG 上下文
    3. 从 MySQL 加载对话历史
    4. 构建消息列表
    5. LLM.astream() 逐 token 产出
    6. 流结束后保存用户消息和助手回复到 MySQL
    """
    # 1. 关键词检测
    matched_keywords = detect_legal_keywords(user_message)
    if matched_keywords:
        logger.info("聊天关键词命中: %s", matched_keywords)

    # 2. 条件 RAG
    laws_context = None
    if matched_keywords:
        try:
            results = await asyncio.to_thread(
                search_relevant_laws, user_message, 3
            )
            if results:
                laws_context = "\n\n".join(results)
        except Exception as e:
            logger.warning("聊天 RAG 检索失败: %s", e)

    # 3. 加载历史
    history = await load_conversation_history(session, conversation_id)

    # 4. 构建消息
    msg_list = _build_llm_messages(user_message, history, laws_context)
    prompt = ChatPromptTemplate.from_messages(msg_list)
    chain = prompt | chat_llm | StrOutputParser()

    # 5. 流式生成并累积完整回复
    full_response = ""
    try:
        async for chunk in chain.astream({}):
            full_response += chunk
            yield chunk
    except Exception as e:
        logger.exception("聊天流式生成失败")
        # 即使生成中断也保存已生成的部分
        if full_response.strip():
            await _save_messages(session, conversation_id, user_message, full_response)
        raise

    # 6. 保存消息到 MySQL
    if full_response.strip():
        await _save_messages(session, conversation_id, user_message, full_response)


async def _save_messages(
    session: AsyncSession,
    conversation_id: int,
    user_message: str,
    assistant_response: str,
):
    """保存用户消息和助手回复到数据库，并更新对话标题。"""
    # 保存用户消息
    user_msg = MessageModel(
        conversation_id=conversation_id,
        role="user",
        content=user_message,
    )
    session.add(user_msg)

    # 保存助手回复
    assistant_msg = MessageModel(
        conversation_id=conversation_id,
        role="assistant",
        content=assistant_response,
    )
    session.add(assistant_msg)

    # 更新对话时间戳和自动标题
    conversation = await session.get(ConversationModel, conversation_id)
    if conversation:
        conversation.updated_at = datetime.now()
        # 首条用户消息自动生成标题
        if not conversation.title or conversation.title == "新对话":
            count_stmt = select(func.count()).where(
                MessageModel.conversation_id == conversation_id,
                MessageModel.role == "user",
            )
            count_result = await session.execute(count_stmt)
            msg_count = count_result.scalar()
            if msg_count == 1:
                conversation.title = user_message[:30] + ("..." if len(user_message) > 30 else "")

    await session.commit()
