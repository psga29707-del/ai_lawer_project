import asyncio
import hashlib
import io
import logging
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Depends, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import select, desc, delete
from sqlalchemy.ext.asyncio import AsyncSession

import json

from fastapi.responses import StreamingResponse

from config import CHROMA_PERSIST_DIR
from models import Base, UserModel, ConversationModel, MessageModel
from services.database import law_vectorstore
from services.llm_agent import generate_legal_report, modify_contract_text
from services.legal_agent import agent_modify_contract
from services.mysql_db import async_engine, get_db_session
from services.chat_service import generate_chat_response

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用生命周期：启动时自动建表，关闭时释放连接池。"""
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    print("==================================================")
    print("[法小智] FastAPI 后端服务已启动")
    print(f"[ChromaDB] 本地持久化路径: {CHROMA_PERSIST_DIR}")
    print("[MySQL] users 表已就绪（若尚未存在则已自动创建）")
    print("==================================================")
    yield
    await async_engine.dispose()


app = FastAPI(
    title="法小智 - AI微服务核心网关",
    description="法小智项目后端，支持 MySQL 用户验证与 ChromaDB 法律检索的智能合同审查服务",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class UserReviewPayload(BaseModel):
    username: str
    text: str


class ModifyPayload(BaseModel):
    text: str


class AgentModifyPayload(BaseModel):
    text: str


class RegisterPayload(BaseModel):
    username: str
    password: str


class LoginPayload(BaseModel):
    username: str
    password: str


class ChatConversationPayload(BaseModel):
    username: str


class ChatCreatePayload(BaseModel):
    username: str
    title: str = "新对话"


class ChatSendPayload(BaseModel):
    username: str
    conversation_id: int | None = None
    message: str


# ═══════════════════════════════════════════════════════════
# 文件上传与文本提取
# ═══════════════════════════════════════════════════════════

ALLOWED_EXTENSIONS = {".pdf", ".doc", ".docx"}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB


def extract_text_from_pdf(file_bytes: bytes) -> str:
    """使用 PyMuPDF 提取 PDF 文本内容。"""
    import fitz
    doc = fitz.open(stream=file_bytes, filetype="pdf")
    text_parts = []
    for page in doc:
        text_parts.append(page.get_text())
    doc.close()
    return "\n".join(text_parts).strip()


def extract_text_from_docx(file_bytes: bytes) -> str:
    """使用 python-docx 提取 Word 文本内容。"""
    from docx import Document
    doc = Document(io.BytesIO(file_bytes))
    paragraphs = [p.text for p in doc.paragraphs if p.text.strip()]
    return "\n".join(paragraphs).strip()


@app.post("/api/v1/extract")
async def extract_file(file: UploadFile = File(...)):
    """上传 PDF 或 Word 文档，返回提取的文本内容。

    - 支持格式：.pdf, .docx（.doc 提示转换）
    - 大小限制：10 MB
    """
    # 校验文件扩展名
    ext = os.path.splitext(file.filename or "")[1].lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"不支持的文件格式 '{ext}'，请上传 PDF 或 Word 文档（.docx）。",
        )

    # 读取文件内容
    file_bytes = await file.read()

    # 校验文件大小
    if len(file_bytes) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail="文件大小超过 10MB 限制，请压缩后上传。",
        )

    try:
        if ext == ".pdf":
            text = extract_text_from_pdf(file_bytes)
        elif ext == ".docx":
            text = extract_text_from_docx(file_bytes)
        else:  # .doc
            # 旧版 .doc 格式无法直接解析，提示用户转换
            return {
                "status": "error",
                "message": "暂不支持旧版 .doc 格式，请将文件另存为 .docx 后重新上传。",
                "filename": file.filename,
            }

        if not text:
            return {
                "status": "error",
                "message": "未能从文件中提取到任何文本内容，请确认文件是否为扫描件（暂不支持 OCR）。",
                "filename": file.filename,
            }

        return {
            "status": "success",
            "text": text,
            "filename": file.filename,
        }

    except Exception as exc:
        logger.exception("文件提取失败")
        raise HTTPException(status_code=500, detail=f"文件解析失败: {str(exc)}") from exc


@app.post("/api/v1/register")
async def register(
    payload: RegisterPayload,
    session: AsyncSession = Depends(get_db_session),
):
    """用户注册接口。"""
    username = payload.username.strip()
    password = payload.password.strip()
    if not username or not password:
        raise HTTPException(status_code=400, detail="用户名和密码不能为空。")

    try:
        result = await session.execute(
            select(UserModel).where(UserModel.username == username)
        )
        if result.scalars().first():
            raise HTTPException(status_code=409, detail="用户名已存在。")

        password_hash = hashlib.sha256(password.encode()).hexdigest()
        user = UserModel(username=username, password_hash=password_hash)
        session.add(user)
        await session.commit()
        return {"status": "success", "message": f"用户 {username} 注册成功"}
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("用户注册失败: %s", exc)
        raise HTTPException(status_code=500, detail="注册失败，请稍后重试。") from exc


@app.post("/api/v1/login")
async def login(
    payload: LoginPayload,
    session: AsyncSession = Depends(get_db_session),
):
    """用户登录验证。"""
    username = payload.username.strip()
    password = payload.password.strip()
    if not username or not password:
        raise HTTPException(status_code=400, detail="用户名和密码不能为空。")

    try:
        result = await session.execute(
            select(UserModel).where(UserModel.username == username)
        )
        user = result.scalars().first()
        if not user:
            raise HTTPException(status_code=404, detail="用户不存在。")

        password_hash = hashlib.sha256(password.encode()).hexdigest()
        if user.password_hash != password_hash:
            raise HTTPException(status_code=401, detail="密码错误。")

        return {"status": "success", "username": username}
    except HTTPException:
        raise
    except Exception as exc:
        logger.error("登录失败: %s", exc)
        raise HTTPException(status_code=500, detail="登录失败，请稍后重试。") from exc


@app.post("/api/v1/user_review")
async def user_review(
    payload: UserReviewPayload,
    session: AsyncSession = Depends(get_db_session),
):
    """双库融合审查接口：先校验 MySQL 用户，再执行 ChromaDB RAG + LCEL 推理。"""
    username = payload.username.strip()
    contract_text = payload.text.strip()

    if not username:
        raise HTTPException(status_code=400, detail="用户名不能为空。")
    if not contract_text:
        raise HTTPException(status_code=400, detail="合同文本不能为空。")

    try:
        result = await session.execute(
            select(UserModel).where(UserModel.username == username)
        )
        user = result.scalars().first()
    except Exception as exc:
        logger.error("用户查询失败: %s", exc)
        raise HTTPException(status_code=500, detail="用户查询失败，请稍后重试。") from exc

    if user is None:
        raise HTTPException(status_code=404, detail="用户不存在，请先注册后再进行审查。")

    try:
        report = await asyncio.to_thread(generate_legal_report, contract_text)
        return {"status": "success", "report": report}
    except Exception as exc:
        logger.error("生成审查报告失败: %s", exc)
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.post("/api/v1/modify")
async def modify_contract(payload: ModifyPayload):
    """合同一键修改接口：RAG 检索法条 → LLM 重写 → 返回合规文本。"""
    contract_text = payload.text.strip()
    if not contract_text:
        raise HTTPException(status_code=400, detail="合同文本不能为空。")

    try:
        modified = await asyncio.to_thread(modify_contract_text, contract_text)
        return {"status": "success", "modified_text": modified}
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.post("/api/v1/review")
async def simple_review(payload: ModifyPayload):
    """简化审查接口（无需用户名），供前端「一键审查」按钮调用。"""
    contract_text = payload.text.strip()
    if not contract_text:
        raise HTTPException(status_code=400, detail="合同文本不能为空。")

    try:
        report = await asyncio.to_thread(generate_legal_report, contract_text)
        return {"status": "success", "report": report}
    except Exception as exc:
        logger.exception("生成审查报告失败")
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@app.post("/api/v1/agent_modify")
async def agent_modify(payload: AgentModifyPayload):
    """Agent 智能修改接口：Agent 逐条分析→逐条检索法条→逐条修改→汇总输出。"""
    contract_text = payload.text.strip()
    if not contract_text:
        raise HTTPException(status_code=400, detail="合同文本不能为空。")

    try:
        modified = await asyncio.to_thread(agent_modify_contract, contract_text)
        return {"status": "success", "modified_text": modified}
    except Exception as exc:
        logger.exception("Agent 合同修改失败")
        raise HTTPException(status_code=500, detail=str(exc)) from exc


# ═══════════════════════════════════════════════════════════
# 聊天模块（单纯聊聊）
# ═══════════════════════════════════════════════════════════

@app.post("/api/v1/chat/conversations")
async def list_conversations(
    payload: ChatConversationPayload,
    session: AsyncSession = Depends(get_db_session),
):
    """获取用户的所有对话列表。"""
    username = payload.username.strip()
    if not username:
        raise HTTPException(status_code=400, detail="用户名不能为空。")

    result = await session.execute(
        select(UserModel).where(UserModel.username == username)
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在。")

    stmt = (
        select(ConversationModel)
        .where(ConversationModel.user_id == user.id)
        .order_by(desc(ConversationModel.updated_at))
    )
    result = await session.execute(stmt)
    conversations = result.scalars().all()
    return {
        "status": "success",
        "conversations": [
            {
                "id": c.id,
                "title": c.title,
                "created_at": c.created_at.isoformat() if c.created_at else None,
                "updated_at": c.updated_at.isoformat() if c.updated_at else None,
            }
            for c in conversations
        ],
    }


@app.post("/api/v1/chat/conversations/create")
async def create_conversation(
    payload: ChatCreatePayload,
    session: AsyncSession = Depends(get_db_session),
):
    """创建新对话。"""
    username = payload.username.strip()
    if not username:
        raise HTTPException(status_code=400, detail="用户名不能为空。")

    result = await session.execute(
        select(UserModel).where(UserModel.username == username)
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在。")

    conv = ConversationModel(user_id=user.id, title=payload.title or "新对话")
    session.add(conv)
    await session.commit()
    await session.refresh(conv)
    return {
        "status": "success",
        "conversation": {
            "id": conv.id,
            "title": conv.title,
            "created_at": conv.created_at.isoformat() if conv.created_at else None,
        },
    }


@app.post("/api/v1/chat/conversations/{conversation_id}/messages")
async def get_messages(
    conversation_id: int,
    payload: ChatConversationPayload,
    session: AsyncSession = Depends(get_db_session),
):
    """获取指定对话的消息列表。"""
    username = payload.username.strip()
    result = await session.execute(
        select(UserModel).where(UserModel.username == username)
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在。")

    conv = await session.get(ConversationModel, conversation_id)
    if not conv or conv.user_id != user.id:
        raise HTTPException(status_code=404, detail="对话不存在。")

    stmt = (
        select(MessageModel)
        .where(MessageModel.conversation_id == conversation_id)
        .order_by(MessageModel.created_at)
    )
    result = await session.execute(stmt)
    messages = result.scalars().all()
    return {
        "status": "success",
        "messages": [
            {
                "id": m.id,
                "role": m.role,
                "content": m.content,
                "created_at": m.created_at.isoformat() if m.created_at else None,
            }
            for m in messages
        ],
    }


@app.delete("/api/v1/chat/conversations/{conversation_id}")
async def delete_conversation(
    conversation_id: int,
    payload: ChatConversationPayload,
    session: AsyncSession = Depends(get_db_session),
):
    """删除对话及其所有消息。"""
    username = payload.username.strip()
    result = await session.execute(
        select(UserModel).where(UserModel.username == username)
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在。")

    conv = await session.get(ConversationModel, conversation_id)
    if not conv or conv.user_id != user.id:
        raise HTTPException(status_code=404, detail="对话不存在。")

    # 先删消息，再删对话
    await session.execute(
        delete(MessageModel).where(MessageModel.conversation_id == conversation_id)
    )
    await session.delete(conv)
    await session.commit()
    return {"status": "success", "message": "对话已删除。"}


@app.post("/api/v1/chat/stream")
async def chat_stream(
    payload: ChatSendPayload,
    session: AsyncSession = Depends(get_db_session),
):
    """流式聊天接口（SSE）。

    接收用户消息，返回 SSE 事件流：
      data: {"type": "token", "content": "..."}
      data: {"type": "done", "conversation_id": N}
      data: {"type": "error", "content": "..."}
    """
    username = payload.username.strip()
    user_message = payload.message.strip()

    if not username:
        raise HTTPException(status_code=400, detail="用户名不能为空。")
    if not user_message:
        raise HTTPException(status_code=400, detail="消息不能为空。")

    # 验证用户
    result = await session.execute(
        select(UserModel).where(UserModel.username == username)
    )
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在，请先注册。")

    # 创建或获取对话
    conversation_id = payload.conversation_id
    if conversation_id is None:
        conv = ConversationModel(user_id=user.id, title="新对话")
        session.add(conv)
        await session.commit()
        await session.refresh(conv)
        conversation_id = conv.id
    else:
        conv = await session.get(ConversationModel, conversation_id)
        if not conv or conv.user_id != user.id:
            raise HTTPException(status_code=404, detail="对话不存在。")

    async def event_stream():
        """SSE 事件流生成器。"""
        try:
            async for token in generate_chat_response(
                user_message, conversation_id, session
            ):
                data = json.dumps({"type": "token", "content": token})
                yield f"data: {data}\n\n"

            data = json.dumps({"type": "done", "conversation_id": conversation_id})
            yield f"data: {data}\n\n"
        except Exception as e:
            logger.exception("聊天流式响应异常")
            data = json.dumps({"type": "error", "content": str(e)})
            yield f"data: {data}\n\n"

    return StreamingResponse(
        event_stream(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
