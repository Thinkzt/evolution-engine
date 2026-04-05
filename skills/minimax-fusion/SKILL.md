---
name: minimax-fusion
license: MIT
metadata:
  version: "0.1.0"
  category: skill-fusion
  author: 璇玑史
  sources:
    - MiniMax-AI/skills (9234 stars)
description: >
  璇玑史技能融合引擎，从MiniMax-AI/skills学习并融合顶级Skills。
  支持文档处理、数据分析、视觉识别等多领域能力融合。
triggers:
  - 融合技能
  - 学习skill
  - 获取能力
  - 融合
---

# minimax-fusion

璇玑史技能融合引擎 - 从顶级开源项目学习并超越

## 核心能力

### 1. Skill自动下载
```python
# 从GitHub下载MiniMax-AI Skills
async def fetch_skill(skill_name: str):
    url = f"https://api.github.com/repos/MiniMax-AI/skills/contents/skills/{skill_name}"
    # 下载完整skill结构
```

### 2. Skill结构解析
```python
# 解析SKILL.md模板
def parse_skill(skill_content: str):
    # 提取: triggers, pipelines, code patterns
    return {"triggers": [], "pipelines": [], "code": []}
```

### 3. 璇玑史融合
```python
# 融合到璇玑史体系
def fuse_to_xuanji(skill: dict):
    # 保留原版精髓
    # 增加璇玑史特色
    # 扩展应用场景
    return fused_skill
```

## 技能库

已融合技能:

| 技能名 | 状态 | 来源 |
|--------|------|------|
| minimax-docx | ✅ 已融合 | MiniMax-AI |
| minimax-xlsx | ⏳ 待融合 | MiniMax-AI |
| pptx-generator | ⏳ 待融合 | MiniMax-AI |
| vision-analysis | ⏳ 待融合 | MiniMax-AI |

## 使用方法

```bash
# 列出可用融合技能
python3 fusion.py list

# 融合指定技能
python3 fusion.py fuse <skill-name>

# 查看融合进度
python3 fusion.py status
```

## 璇玑史融合原则

1. **保留精髓** - 学习原版最优秀的设计
2. **东方智慧** - 融入五千年文明淬炼
3. **场景扩展** - 扩展到航务等专业领域
4. **持续进化** - 不断迭代优化

---

*璇玑史出品 | 思想即未来*
