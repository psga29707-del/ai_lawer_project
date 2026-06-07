"""
法条数据准备脚本
================
1. 修复并解析 law_data.json
2. 生成结构化的 Markdown 文件存入 legal_knowledge_base/
"""

import json
import re
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parent.parent
LAW_KB_DIR = BACKEND_ROOT / "legal_knowledge_base"
JSON_PATH = BACKEND_ROOT.parent.parent / "lawdata_temp" / "law_data.json"


def fix_and_load_json(path: Path) -> list[dict]:
    """修复破损的 JSON 并提取 articles 数组"""
    raw = path.read_text(encoding="utf-8")

    # ========== 文本级修复 ==========

    # 1. 修复 `"database_content":,` → `"database_content": [`
    raw = raw.replace('"database_content":,', '"database_content": [', 1)

    # 2. 在第一个 article 前补上缺失的字段
    first_article_preamble = """    {
      "article_id": "LCL-19-CONSOLIDATED",
      "category": "试用期规制",
      "statutes": [
        {
          "source": "《中华人民共和国劳动合同法》第十九条",
          "full_text": "劳动合同期限三个月以上不满一年的，试用期不得超过一个月；劳动合同期限一年以上不满三年的，试用期不得超过二个月；三年以上固定期限和无固定期限的劳动合同，试用期不得超过六个月。同一用人单位与同一劳动者只能约定一次试用期。以完成一定工作任务为期限的劳动合同或者劳动合同期限不满三个月的，不得约定试用期。试用期包含在劳动合同期限内。劳动合同仅约定试用期的，试用期不成立，该期限为劳动合同期限。"
        }
      ],
"""
    # 在第一个 "key_summary" 前插入
    raw = raw.replace('\n      "key_summary"', first_article_preamble + '\n      "key_summary"', 1)

    # 3. 修复空的 implementing_regulations:  → : []
    raw = re.sub(r'"implementing_regulations":\s*,', '"implementing_regulations": [],', raw)

    # 4. 修复空的 supreme_court_typical_cases: (无值, 后面跟着 })
    raw = re.sub(r'"supreme_court_typical_cases":\s*\n\s*\}', '"supreme_court_typical_cases": []\n    }', raw)
    # 还要处理它后面跟逗号情况:
    raw = re.sub(r'"supreme_court_typical_cases":\s*,', '"supreme_court_typical_cases": [],', raw)

    # 5. 移除 BOM（如果有）
    raw = raw.lstrip('﻿')

    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        # 如果还失败，输出错误周围的上下文
        lines = raw.split('\n')
        lineno = e.lineno
        for i in range(max(0, lineno-3), min(len(lines), lineno+3)):
            marker = " >>>" if i == lineno - 1 else ""
            print(f"  {i+1}:{marker} {lines[i][:200]}")
        raise

    articles = data.get("database_content", [])
    print(f"成功解析 {len(articles)} 条法条综合条目")
    return articles


def format_article_markdown(article: dict) -> str:
    """将单条 article 转为带 YAML 前言的 Markdown"""
    article_id = article["article_id"]
    category = article.get("category", "")
    statutes = article.get("statutes", [])

    # 提取来源名称（多个 statute 合并）
    sources = [s["source"] for s in statutes]
    source_str = "、".join(sources)

    # 第一款 statute 的简短标题
    first_statute_text = statutes[0]["full_text"] if statutes else ""
    title_prefix = statutes[0]["source"] if statutes else article_id

    # YAML 前言
    aliases = [article_id]
    # 尝试从 summary 中提取关键词
    key_summary = article.get("key_summary", "")
    tags = [category] if category else []

    md = f"""---
id: {article_id}
source: {source_str}
category: {category}
aliases: {json.dumps(aliases, ensure_ascii=False)}
tags: {json.dumps(tags, ensure_ascii=False)}
---

# {title_prefix}

## 条文原文

"""

    for s in statutes:
        md += f"**{s['source']}**\n\n{s['full_text']}\n\n"

    # 要点总结
    if key_summary:
        md += f"""## 要点总结

{key_summary}

"""

    # 实施条例
    impl_regs = article.get("implementing_regulations", [])
    if impl_regs and len(impl_regs) > 0:
        md += "## 实施条例细则\n\n"
        for reg in impl_regs:
            source = reg.get("source", "")
            relevance = reg.get("relevance", "")
            text = reg.get("full_text", "")
            md += f"**{source}**"
            if relevance:
                md += f"（{relevance}）"
            md += f"\n\n{text}\n\n"

    # 地方裁审口径
    local_stds = article.get("local_standards", {})
    if local_stds:
        md += "## 地方裁审口径\n\n"
        region_map = {
            "guangdong_court_opinion": "广东",
            "beijing_court_opinion": "北京",
            "shanghai_court_opinion": "上海",
            "zhejiang_court_opinion": "浙江",
            "jiangsu_court_opinion": "江苏",
        }
        for key, opinion in local_stds.items():
            region = region_map.get(key, key)
            md += f"### {region}\n\n{opinion}\n\n"

    # 典型案例
    cases = article.get("supreme_court_typical_cases", [])
    if cases and len(cases) > 0:
        md += "## 典型案例\n\n"
        for case in cases:
            name = case.get("case_name", "")
            source = case.get("case_source", "")
            essence = case.get("judgment_essence", "")
            md += f"### {name}\n\n"
            md += f"**来源**：{source}\n\n" if source else ""
            md += f"**裁判要旨**：{essence}\n\n" if essence else ""

    return md


def determine_file_path(article: dict) -> Path:
    """根据 category 和 article_id 确定 Markdown 文件存放路径"""
    article_id = article["article_id"]
    category = article.get("category", "")

    # 映射 category 到子目录
    category_to_dir = {
        "试用期规制": "labor_law",
        "培训与服务期": "labor_law",
        "竞业限制规制": "labor_law",
        "劳动者违约金限制": "labor_law",
        "劳动者主动解约": "labor_law",
        "劳动者被迫解约": "labor_law",
        "用人单位即时辞退": "labor_law",
        "用人单位无过错解除": "labor_law",
        "离职经济补偿": "labor_law",
        "工时与劳动保护": "labor_law",
        "诉讼证明责任": "labor_law",
    }

    sub_dir = category_to_dir.get(category, "other")
    # 文件名: article_id 加简短英文描述
    id_to_name = {
        "LCL-19-CONSOLIDATED": "probation_period",
        "LCL-20-CONSOLIDATED": "probation_wage",
        "LCL-21-CONSOLIDATED": "probation_termination_protection",
        "LCL-22-CONSOLIDATED": "training_service_period",
        "LCL-23-24-CONSOLIDATED": "non_compete_restriction",
        "LCL-25-CONSOLIDATED": "penalty_limit",
        "LCL-37-CONSOLIDATED": "worker_resignation",
        "LCL-38-CONSOLIDATED": "constructive_dismissal",
        "LCL-39-CONSOLIDATED": "employer_immediate_termination",
        "LCL-40-CONSOLIDATED": "no_fault_termination",
        "LCL-46-47-CONSOLIDATED": "severance_payment",
        "LL-36-41-44-CONSOLIDATED": "working_hours_overtime",
        "SPC-JI-I-42-CONSOLIDATED": "burden_of_proof_overtime",
    }
    name = id_to_name.get(article_id, article_id.lower().replace("-", "_"))

    dir_path = LAW_KB_DIR / sub_dir
    dir_path.mkdir(parents=True, exist_ok=True)
    return dir_path / f"{name}.md"


def main():
    # 1. 加载并修复 JSON
    articles = fix_and_load_json(JSON_PATH)

    # 2. 确保根目录存在
    LAW_KB_DIR.mkdir(parents=True, exist_ok=True)

    # 3. 为每条 article 生成 Markdown 文件
    created = []
    for article in articles:
        file_path = determine_file_path(article)
        md_content = format_article_markdown(article)
        file_path.write_text(md_content, encoding="utf-8")
        created.append(file_path.name)
        print(f"  [OK] {file_path.relative_to(BACKEND_ROOT)}")

    print(f"\n完成！共生成 {len(created)} 个 Markdown 文件到 {LAW_KB_DIR.relative_to(BACKEND_ROOT)}/")


if __name__ == "__main__":
    main()
