---
name: openclaw-backup-fusion
license: MIT
metadata:
  version: "0.1.0"
  category: backup
  author: 璇玑史
  sources:
    - LeoYeAI/openclaw-backup (664⭐)
description: >
  璇玑史OpenClaw备份恢复系统 - 一键备份到云端。
  核心：备份/恢复/云同步/版本管理/加密。
triggers:
  - 备份
  - 恢复
  - 云同步
  - 一键备份
---

# openclaw-backup-fusion

璇玑史OpenClaw备份恢复系统 - 基于LeoYeAI/openclaw-backup (664⭐)

## 核心架构

```
┌─────────────────────────────────────────────────────────────┐
│              璇玑史备份系统 v1.0                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   本地数据 ──→ 备份打包 ──→ 云端同步                        │
│      ↓                              ↓                       │
│   定时cron ──→ 版本管理 ←── 免费云存储                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 备份范围

| 组件 | 说明 | 包含 |
|------|------|------|
| 🧠 Workspace | 记忆/Skills/配置文件 | MEMORY.md, SOUL.md, skills |
| ⚙️ Gateway | openclaw.json | Bot tokens, API keys |
| 🔑 Credentials | 配对状态 | 无需重新配对 |
| 📜 Sessions | 对话历史 | 完整历史记录 |
| ⏰ Cron | 定时任务 | 所有调度 |
| 🛡️ Scripts | 脚本 | Guardian等 |

## 免费云存储方案

| 方案 | 免费额度 | 适用场景 |
|------|---------|---------|
| **Cloudflare R2** | 10GB/月 | 首选，兼容S3 API |
| **Backblaze B2** | 10GB | 备选，性价比高 |
| **GitHub Gist** | 100MB | 小文件备份 |
| **WebDAV** | 自建 | 私有云盘 |

## 使用方法

### 一键备份到云端
```bash
# 完整备份
bash scripts/xuanji_backup.sh --cloud r2

# 本地备份
bash scripts/xuanji_backup.sh --local

# 定时备份
bash scripts/xuanji_backup.sh --schedule "0 2 * * *"
```

### 恢复
```bash
# 预览恢复内容
bash scripts/xuanji_restore.sh backup.tar.gz --dry-run

# 执行恢复
bash scripts/xuanji_restore.sh backup.tar.gz
```

## 璇玑史特色

| 功能 | 说明 |
|------|------|
| 🔒 加密备份 | 敏感数据AES-256加密 |
| 📤 自动云同步 | 备份后自动上传R2 |
| 🔢 版本管理 | 保留最近7个版本 |
| ⏰ 定时任务 | 自动定时备份 |
| 📊 备份报告 | 每次备份生成报告 |

---

*璇玑史出品 | 思想即未来*
