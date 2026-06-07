"""
批量导入脚本：扫描 legal_knowledge_base/ 下所有 Markdown 文件导入 ChromaDB
=======================================================================
用法:
    python scripts/import_markdown_to_chroma.py          # 增量导入（跳过已有 ID）
    python scripts/import_markdown_to_chroma.py --force   # 强制清空后重导
# 注：需在 ai-backend-fastapi/ 目录下执行
"""

import argparse
import logging
import re
import sys
from pathlib import Path

from langchain_core.documents import Document

BACKEND_ROOT = Path(__file__).resolve().parent.parent

# 复用项目的 ChromaDB 配置
sys.path.insert(0, str(BACKEND_ROOT))
from config import CHROMA_COLLECTION_NAME, CHROMA_PERSIST_DIR
from services.database import law_vectorstore, search_relevant_laws

logger = logging.getLogger("import_markdown")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)

LAW_KB_DIR = BACKEND_ROOT / "legal_knowledge_base"


# ── 简易 YAML frontmatter 解析 ───────────────────────────────────

def parse_frontmatter(text: str) -> tuple[dict, str]:
    """解析 Markdown 的 YAML frontmatter（--- 包围的区域），返回 (metadata, body)"""
    m = re.match(r'^---\s*\n(.*?)\n---\s*\n(.*)', text, re.DOTALL)
    if not m:
        return {}, text

    yaml_block, body = m.group(1), m.group(2)
    metadata = {}

    for line in yaml_block.strip().split('\n'):
        line = line.strip()
        if not line or line == '---':
            continue
        colon_pos = line.find(':')
        if colon_pos == -1:
            continue
        key = line[:colon_pos].strip()
        raw_val = line[colon_pos + 1:].strip()

        # 尝试解析为 JSON 值（支持字符串、列表、数字）
        if raw_val.startswith('[') or raw_val.startswith('{') or raw_val == 'true' or raw_val == 'false':
            import json
            try:
                metadata[key] = json.loads(raw_val)
                continue
            except json.JSONDecodeError:
                pass

        # 去掉引号
        metadata[key] = raw_val.strip('"').strip("'")

    return metadata, body.strip()


def collect_markdown_files(root_dir: Path) -> list[Path]:
    """递归扫描目录下的所有 .md 文件（排除 README）"""
    files = sorted(root_dir.rglob("*.md"))
    return [f for f in files if f.name.upper() != "README.MD"]


def build_document(file_path: Path) -> tuple[Document | None, str]:
    """解析单个 Markdown 文件，返回 (Document, id) 或 (None, reason)"""
    try:
        text = file_path.read_text(encoding="utf-8")
    except Exception as e:
        return None, f"读取失败: {e}"

    metadata, body = parse_frontmatter(text)

    # 生成文档 ID：优先从 frontmatter 取，否则用相对路径
    doc_id = metadata.get("id") or "/".join(file_path.relative_to(LAW_KB_DIR).parts).replace("\\", "/")
    doc_id = doc_id.replace(".md", "")

    # 确保有足够的 body 内容
    if not body or len(body.strip()) < 10:
        return None, f"内容为空或过短（{len(body.strip())} 字符）"

    # 构建 ChromaDB metadata（只保留 hashable 类型）
    chroma_meta = {
        "id": doc_id,
        "source": metadata.get("source", ""),
        "category": metadata.get("category", ""),
        "file_path": str(file_path.relative_to(LAW_KB_DIR)).replace("\\", "/"),
    }
    tags = metadata.get("tags", [])
    if isinstance(tags, list):
        chroma_meta["tags"] = ",".join(tags)

    doc = Document(
        page_content=body.strip(),
        metadata=chroma_meta,
    )
    return doc, doc_id


def get_existing_ids() -> set:
    """查询 ChromaDB 中已有的文档 ID"""
    try:
        result = law_vectorstore.get()
        ids = result.get("ids", [])
        logger.info("ChromaDB 现有 %d 条文档", len(ids))
        return set(ids)
    except Exception as e:
        logger.warning("读取 ChromaDB 现有文档失败，按空库处理: %s", e)
        return set()


def import_all(force: bool = False):
    """批量导入的主函数"""
    logger.info("=" * 50)
    logger.info("法律知识库批量导入工具")
    logger.info("集合: %s", CHROMA_COLLECTION_NAME)
    logger.info("持久化: %s", CHROMA_PERSIST_DIR)
    logger.info("=" * 50)

    # 1. 扫描文件
    md_files = collect_markdown_files(LAW_KB_DIR)
    logger.info("在 %s 下发现 %d 个 Markdown 文件", LAW_KB_DIR.name, len(md_files))
    for f in md_files:
        logger.info("  发现: %s", f.relative_to(LAW_KB_DIR))

    if not md_files:
        logger.warning("没有找到任何 Markdown 文件，请先运行 prepare_law_markdown.py")
        return

    # 2. 获取已有 ID
    existing_ids = get_existing_ids() if not force else set()
    if force:
        logger.warning("--force 模式：将删除集合 %s 并重新导入", CHROMA_COLLECTION_NAME)

    # 3. 构建 Document 列表
    documents: list[Document] = []
    doc_ids: list[str] = []
    skipped = []
    errors = []

    for file_path in md_files:
        doc, doc_id = build_document(file_path)

        if doc is None:
            errors.append((file_path, doc_id))
            continue

        if doc_id in existing_ids:
            skipped.append((file_path, doc_id))
            continue

        documents.append(doc)
        doc_ids.append(doc_id)

    # 4. 报告
    log_section("扫描结果")
    logger.info("  新增: %d 条", len(documents))
    logger.info("  跳过（已存在）: %d 条", len(skipped))
    logger.info("  错误: %d 条", len(errors))
    if skipped:
        for path, _id in skipped:
            logger.info("    [跳过] %s (%s)", path.relative_to(LAW_KB_DIR), _id)
    if errors:
        for path, reason in errors:
            logger.info("    [错误] %s: %s", path.relative_to(LAW_KB_DIR), reason)

    # 5. 导入
    if not documents:
        logger.info("没有新的法条需要导入。")
        return

    try:
        log_section("导入中...")
        # 如果 force 模式，清空后重导
        if force:
            delete_all()

        law_vectorstore.add_documents(documents, ids=doc_ids)
        logger.info("成功导入 %d 条法条到 ChromaDB！", len(documents))

        # 6. 验证
        log_section("验证检索")
        test_queries = [
            "试用期多久合法",
            "竞业限制赔偿金",
            "加班费怎么算",
        ]
        for q in test_queries:
            results = search_relevant_laws(q, n_results=2)
            logger.info("查询: '%s'", q)
            for r in results:
                first_line = r.split('\n')[0][:80]
                logger.info("  -> %s...", first_line)

    except Exception as e:
        logger.exception("导入失败: %s", e)
        raise


def delete_all():
    """清空 ChromaDB 集合中的所有文档"""
    try:
        existing = law_vectorstore.get()
        ids = existing.get("ids", [])
        if ids:
            # 通过底层集合删除
            law_vectorstore._collection.delete(ids=ids)
            logger.info("已清空 %d 条旧数据", len(ids))
    except Exception as e:
        logger.warning("清空操作失败: %s", e)


def log_section(title: str):
    logger.info("")
    logger.info("── %s ───────────────────", title)


def main():
    parser = argparse.ArgumentParser(description="导入 Markdown 法条到 ChromaDB")
    parser.add_argument("--force", action="store_true", help="清空集合后重新导入")
    args = parser.parse_args()

    import_all(force=args.force)


if __name__ == "__main__":
    main()
