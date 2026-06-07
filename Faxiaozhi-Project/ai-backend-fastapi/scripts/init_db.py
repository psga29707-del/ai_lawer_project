import logging
import sys
from pathlib import Path

from langchain_core.documents import Document

BACKEND_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND_ROOT))

from config import CHROMA_COLLECTION_NAME, CHROMA_PERSIST_DIR
from services.database import law_vectorstore

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

BASE_LAW_DOCUMENTS = [
    {
        "id": "labor_law_19",
        "content": "《中华人民共和国劳动合同法》第十九条：劳动合同期限三个月以上不满一年的，试用期不得超过一个月；劳动合同期限一年以上不满三年的，试用期不得超过二个月；三年以上固定期限和无固定期限的劳动合同，试用期不得超过六个月。同一用人单位与同一劳动者只能约定一次试用期。",
        "topic": "试用期",
    },
    {
        "id": "labor_law_20",
        "content": "《中华人民共和国劳动合同法》第二十条：劳动者在试用期的工资不得低于本单位相同岗位最低档工资或者劳动合同约定工资的百分之八十，并不得低于用人单位所在地的最低工资标准。",
        "topic": "试用期工资",
    },
    {
        "id": "labor_law_22",
        "content": "《中华人民共和国劳动合同法》第二十二条：用人单位为劳动者提供专项培训费用，对其进行专业技术培训的，可以与该劳动者订立协议，约定服务期。劳动者违反服务期约定的，应当按照约定向用人单位支付违约金。违约金的数额不得超过用人单位提供的培训费用。用人单位要求劳动者支付的违约金不得超过服务期尚未履行部分所应分摊的培训费用。",
        "topic": "服务期与违约金",
    },
    {
        "id": "labor_law_23",
        "content": "《中华人民共和国劳动合同法》第二十三条：用人单位与劳动者可以在劳动合同中约定保守用人单位的商业秘密和与知识产权相关的保密事项。对负有保密义务的劳动者，用人单位可以在劳动合同或者保密协议中与劳动者约定竞业限制条款，并约定在解除或者终止劳动合同后，在竞业限制期限内按月给予劳动者经济补偿。劳动者违反竞业限制约定的，应当按照约定向用人单位支付违约金。",
        "topic": "竞业限制",
    },
    {
        "id": "labor_law_25",
        "content": "《中华人民共和国劳动合同法》第二十五条：除本法第二十二条和第二十三条规定的情形外，用人单位不得与劳动者约定由劳动者承担违约金。",
        "topic": "违约金限制",
    },
]


def build_documents() -> list[Document]:
    return [
        Document(
            page_content=item["content"],
            metadata={
                "id": item["id"],
                "topic": item["topic"],
                "source": "劳动合同法",
            },
        )
        for item in BASE_LAW_DOCUMENTS
    ]


def main():
    try:
        documents = build_documents()
        law_vectorstore.add_documents(documents)
        logger.info(
            "ChromaDB 法律知识库初始化完成。集合: %s | 持久化目录: %s",
            CHROMA_COLLECTION_NAME,
            CHROMA_PERSIST_DIR,
        )
    except Exception as exc:
        logger.exception("法律知识库初始化失败")
        raise


if __name__ == "__main__":
    main()
