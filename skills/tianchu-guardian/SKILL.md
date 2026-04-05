---
name: tianchu-guardian
license: MIT
metadata:
  version: "0.1.0"
  category: backup
  author: 璇玑史
  name_cn: 天枢守护
  name_en: TianChu Guardian
description: >
  璇玑史备份恢复系统 - 二十八宿守护神命名。
  天枢·璇玑·天玑·天权·玉衡·开阳·摇光
  
  核心：备份/恢复/云同步/版本管理/加密
  命名：中国五千年文化底蕴·北斗七星体系
triggers:
  - 备份
  - 恢复
  - 云同步
  - 天枢
  - 二十八宿
---

# 天枢守护 - TianChu Guardian

璇玑史备份恢复系统 · 北斗七星命名体系

> **天枢、天璇、天玑、天权、玉衡、开阳、摇光**
> 北斗九星，守护永恒

## 二十八宿架构

| 星名 | 职责 | 说明 |
|------|------|------|
| 🐉 **天枢** | 总调度 | 备份总控、流程协调 |
| 💎 **天璇** | 璇玑存储 | 本地目录管理 |
| 🔐 **天玑** | 珍宝加密 | AES-256安全 |
| ⚖️ **天权** | 版本权衡 | 版本比较与清理 |
| 🔄 **玉衡** | 恢复协调 | 执行恢复、状态回滚 |
| 🚀 **开阳** | 推动执行 | 定时任务、自动调度 |
| ☁️ **摇光** | 云端同步 | R2/B2/Gist多后端 |

## 备份范围

| 组件 | 说明 |
|------|------|
| 🧠 Workspace | MEMORY.md, skills, SOUL.md |
| ⚙️ Gateway | openclaw.json |
| 🔑 Credentials | 无需重新配对 |
| 📜 Agents | 对话历史 |
| ⏰ Cron | 定时任务 |

## 使用方法

```bash
# 本地备份
bash scripts/tianchu-backup.sh

# 云同步备份
TIANCHU_CLOUD=r2 bash scripts/tianchu-backup.sh

# 安全恢复
bash scripts/tianchu-restore.sh backup.tar.gz --dry-run
```

---

*璇玑史出品 · 北斗九星守护*
