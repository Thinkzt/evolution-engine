#!/usr/bin/env bash
# xuanji_backup.sh - 璇玑史OpenClaw备份系统
# 基于LeoYeAI/openclaw-backup (664⭐) + 云同步

set -euo pipefail

# ── 配置 ──────────────────────────────────────────────────────────────────
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="${1:-/tmp/openclaw-backups}"
CLOUD_PROVIDER="${CLOUD_PROVIDER:-r2}"  # r2, b2, gist
KEEP_VERSIONS="${KEEP_VERSIONS:-7}"

WORKSPACE_DIR="${HOME}/.openclaw/workspace"
IDENTITY_FILE="${WORKSPACE_DIR}/IDENTITY.md"
OPENCLAW_HOME="${HOME}/.openclaw"

# Agent名称
if [ -f "$IDENTITY_FILE" ]; then
  AGENT_NAME=$(grep -m1 '\*\*Name:\*\*' "$IDENTITY_FILE" 2>/dev/null | sed 's/.*\*\*Name:\*\* *//' | tr -d '\r' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
fi
AGENT_NAME="${AGENT_NAME:-xuanjishi}"

BACKUP_NAME="xuanji-backup_${AGENT_NAME}_${TIMESTAMP}"
WORK_DIR="/tmp/${BACKUP_NAME}"

# ── 颜色 ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*"; exit 1; }
cloud() { echo -e "${BLUE}[☁️]${NC} $*"; }

echo ""
echo "🦞 璇玑史备份系统 — ${TIMESTAMP}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 解析参数 ──────────────────────────────────────────────────────────────
CLOUD_SYNC=false
SCHEDULE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --cloud)
      CLOUD_SYNC=true
      CLOUD_PROVIDER="${2:-r2}"
      shift 2
      ;;
    --schedule)
      SCHEDULE="$2"
      shift 2
      ;;
    --local)
      CLOUD_SYNC=false
      shift
      ;;
    *)
      OUTPUT_DIR="$1"
      shift
      ;;
  esac
done

# ── 创建工作目录 ──────────────────────────────────────────────────────────
mkdir -p "$OUTPUT_DIR" "$WORK_DIR"

# ── 1. Workspace ─────────────────────────────────────────────────────────
info "备份Workspace..."
if [ -d "$WORKSPACE_DIR" ]; then
  mkdir -p "${WORK_DIR}/workspace"
  rsync -a \
    --exclude='node_modules/' \
    --exclude='.git/' \
    --exclude='*.tar.gz' \
    --exclude='*.skill' \
    --exclude='*.zip' \
    --exclude='*.png' \
    --exclude='*.jpg' \
    --exclude='*.jpeg' \
    --exclude='*.gif' \
    --exclude='*.webp' \
    --exclude='*.mp4' \
    --exclude='*.mp3' \
    "$WORKSPACE_DIR/" "${WORK_DIR}/workspace/"
  info "  workspace → $(du -sh ${WORK_DIR}/workspace | cut -f1)"
fi

# ── 2. Gateway配置 ───────────────────────────────────────────────────────
info "备份Gateway配置..."
CONFIG_FILE="${OPENCLAW_HOME}/openclaw.json"
if [ -f "$CONFIG_FILE" ]; then
  mkdir -p "${WORK_DIR}/config"
  cp "$CONFIG_FILE" "${WORK_DIR}/config/openclaw.json"
fi

# ── 3. 系统Skills ────────────────────────────────────────────────────────
info "备份系统Skills..."
SYSTEM_SKILLS_DIR="${OPENCLAW_HOME}/skills"
if [ -d "$SYSTEM_SKILLS_DIR" ] && [ -n "$(ls -A ${SYSTEM_SKILLS_DIR} 2>/dev/null)" ]; then
  mkdir -p "${WORK_DIR}/skills/system"
  rsync -a "$SYSTEM_SKILLS_DIR/" "${WORK_DIR}/skills/system/"
fi

# ── 4. Credentials ───────────────────────────────────────────────────────
info "备份Credentials..."
CREDS_DIR="${OPENCLAW_HOME}/credentials"
if [ -d "$CREDS_DIR" ]; then
  mkdir -p "${WORK_DIR}/credentials"
  rsync -a "$CREDS_DIR/" "${WORK_DIR}/credentials/"
fi

# ── 5. Agents ────────────────────────────────────────────────────────────
info "备份Agent配置与会话..."
AGENTS_DIR="${OPENCLAW_HOME}/agents"
if [ -d "$AGENTS_DIR" ]; then
  mkdir -p "${WORK_DIR}/agents"
  rsync -a --exclude='*.lock' --exclude='*.deleted.*' "$AGENTS_DIR/" "${WORK_DIR}/agents/"
fi

# ── 6. Cron ─────────────────────────────────────────────────────────────
info "备份Cron任务..."
CRON_DIR="${OPENCLAW_HOME}/cron"
if [ -d "$CRON_DIR" ]; then
  mkdir -p "${WORK_DIR}/cron"
  rsync -a "$CRON_DIR/" "${WORK_DIR}/cron/"
fi

# ── 7. MANIFEST ─────────────────────────────────────────────────────────
cat > "${WORK_DIR}/MANIFEST.json" <<EOF
{
  "backup_name": "${BACKUP_NAME}",
  "agent_name": "${AGENT_NAME}",
  "timestamp": "${TIMESTAMP}",
  "hostname": "$(hostname)",
  "openclaw_version": "$(openclaw --version 2>/dev/null | head -1 || echo 'unknown')",
  "created_by": "xuanji-backup-fusion v1.0"
}
EOF

# ── 8. 打包 ──────────────────────────────────────────────────────────────
echo ""
info "打包备份..."
ARCHIVE="${OUTPUT_DIR}/${BACKUP_NAME}.tar.gz"
tar -czf "$ARCHIVE" -C "/tmp" "$BACKUP_NAME"
rm -rf "$WORK_DIR"
chmod 600 "$ARCHIVE"

ARCHIVE_SIZE=$(du -sh "$ARCHIVE" | cut -f1)
info "本地备份: ${ARCHIVE}"
info "大小: ${ARCHIVE_SIZE}"

# ── 9. 云同步 ────────────────────────────────────────────────────────────
if [ "$CLOUD_SYNC" = true ]; then
  cloud "同步到云端 (${CLOUD_PROVIDER})..."
  
  case "$CLOUD_PROVIDER" in
    r2)
      # Cloudflare R2
      if command -v rclone &>/dev/null; then
        rclone copy "$ARCHIVE" "r2:xuanji-backups/" --quiet
        cloud "  ✅ 已上传到R2"
      else
        warn "  ⚠️ rclone未安装，跳过云同步"
        warn "  安装: curl https://rclone.org/install.sh | sudo bash"
      fi
      ;;
    b2)
      # Backblaze B2
      if command -v rclone &>/dev/null; then
        rclone copy "$ARCHIVE" "b2:xuanji-backups/" --quiet
        cloud "  ✅ 已上传到B2"
      fi
      ;;
    gist)
      # GitHub Gist (小文件)
      MAX_GIST_SIZE=$((100 * 1024 * 1024))  # 100MB
      ARCHIVE_SIZE_BYTES=$(stat -f%z "$ARCHIVE" 2>/dev/null || stat -c%s "$ARCHIVE")
      if [ "$ARCHIVE_SIZE_BYTES" -lt "$MAX_GIST_SIZE" ]; then
        curl -s -X POST "https://api.github.com/gists" \
          -H "Authorization: token ${GITHUB_TOKEN:-}" \
          -d "{\"description\":\"${BACKUP_NAME}\",\"public\":false,\"files\":{\"${BACKUP_NAME}.tar.gz\":{\"content\":\"$(base64 -w0 "$ARCHIVE")\"}}}" | grep -q '"id"' && \
          cloud "  ✅ 已上传到Gist" || warn "  ⚠️ Gist上传失败"
      else
        warn "  ⚠️ 文件过大($ARCHIVE_SIZE)，跳过Gist"
      fi
      ;;
  esac
fi

# ── 10. 版本清理 ────────────────────────────────────────────────────────
BACKUP_COUNT=$(ls "${OUTPUT_DIR}"/xuanji-backup_*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$KEEP_VERSIONS" ]; then
  info "清理旧备份 (保留最近${KEEP_VERSIONS}个)..."
  ls -t "${OUTPUT_DIR}"/xuanji-backup_*.tar.gz | tail -n +$((KEEP_VERSIONS + 1)) | xargs rm -f
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 备份完成: ${BACKUP_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
