# 法律知识库文件夹说明

## 文件夹用途
存放法律条文、司法解释、典型案例等法律知识资料，用于后续导入数据库。

## 文件组织建议

### 按法律类型分类
```
legal_knowledge_base/
├── labor_law/                    # 劳动合同法相关
│   ├── probation.md              # 试用期条款
│   ├── penalty_clause.md         # 违约金条款
│   ├── non_compete.md            # 竞业限制条款
│   └── wage_protection.md        # 工资保护条款
│
├── civil_code/                   # 民法典相关
│   ├── contract_general.md       # 合同通则
│   └── contract_penalty.md       # 违约责任
│
├── education_law/                # 教育法相关（实习/兼职）
│   └── internship.md             # 实习相关规定
│
├── consumer_protection/          # 消费者权益保护
│   └── training_loan.md          # 培训贷相关
│
└── judicial_cases/               # 典型司法案例
    ├── influencer_contract.md    # 网红合同纠纷案例
    ├── training_scam.md          # 培训贷骗局案例
    └── internship_dispute.md     # 实习纠纷案例
```

## 文件格式建议

每个文件使用 Markdown 格式，包含以下信息：
- 法律条文原文
- 条文编号/出处
- 适用场景说明
- 关键词标签（便于检索）

## 示例格式

```markdown
# 《中华人民共和国劳动合同法》第十九条

## 条文内容
劳动合同期限三个月以上不满一年的，试用期不得超过一个月...

## 适用场景
- 试用期时长是否合法
- 试用期工资是否合规

## 关键词
试用期、劳动合同期限、试用期时长
```

---

**注意**：请从官方渠道获取法律条文原文，确保准确性和时效性。
