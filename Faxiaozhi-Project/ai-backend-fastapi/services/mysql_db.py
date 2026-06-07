from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from config import ASYNC_SQLALCHEMY_URL

async_engine = create_async_engine(
    ASYNC_SQLALCHEMY_URL,
    echo=False,
    future=True,
    pool_recycle=300,
)

async_session = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db_session():
    """FastAPI Depends 依赖注入用的异步生成器，由 async_sessionmaker 自动管理生命周期。"""
    async with async_session() as session:
        yield session
