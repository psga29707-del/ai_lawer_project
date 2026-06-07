import logging

from langchain_chroma import Chroma
from langchain_openai import OpenAIEmbeddings

from config import (
    CHROMA_COLLECTION_NAME,
    CHROMA_PERSIST_DIR,
    EMBEDDING_MODEL,
    LLM_API_KEY,
    LLM_BASE_URL,
)

CHROMA_PERSIST_DIR.mkdir(parents=True, exist_ok=True)

logger = logging.getLogger(__name__)

try:
    # langchain_chroma 内部自动使用 chromadb.PersistentClient 做本地持久化
    law_vectorstore = Chroma(
        collection_name=CHROMA_COLLECTION_NAME,
        embedding_function=OpenAIEmbeddings(
            model=EMBEDDING_MODEL,
            openai_api_key=LLM_API_KEY,
            openai_api_base=LLM_BASE_URL,
            check_embedding_ctx_length=False,
        ),
        persist_directory=str(CHROMA_PERSIST_DIR),
    )
except Exception as exc:
    logger.exception("ChromaDB 向量存储初始化失败")
    raise RuntimeError(
        "ChromaDB 初始化失败，请检查 chroma_data 目录、OpenAI Embeddings 配置和网络连接。"
    ) from exc


def search_relevant_laws(query: str, n_results: int = 3) -> list[str]:
    """使用 Chroma 本地向量存储执行语义检索，返回相关法条文本列表。"""
    try:
        documents = law_vectorstore.similarity_search(query, k=n_results)
        return [doc.page_content for doc in documents]
    except Exception as exc:
        logger.exception("ChromaDB 语义检索失败")
        raise RuntimeError(
            "本地法律知识库检索失败，请检查 ChromaDB 数据目录与向量嵌入配置。"
        ) from exc
