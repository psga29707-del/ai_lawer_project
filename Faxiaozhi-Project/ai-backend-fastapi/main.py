import asyncio
import hashlib
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from config import CHROMA_PERSIST_DIR
from models import Base, UserModel
from services.database import law_vectorstore
from services.llm_agent import generate_legal_report, modify_contract_text
from services.legal_agent import agent_modify_contract
from services.mysql_db import async_engine, get_db_session

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


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
