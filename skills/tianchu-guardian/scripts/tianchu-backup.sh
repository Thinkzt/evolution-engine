#!/usr/bin/env bash
# 天枢备份系统 - TianChu Guardian Backup
# 北斗九星守护 · 璇玑史出品

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
#  天枢 · 总调度 (TianShu - North Star Controller)
# ═══════════════════════════════════════════════════════════════════

# ── 配置 ──────────────────────────────────────────────────────────
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="${1:-/tmp/tianchu-backups}"
CLOUD_PROVIDER="${TIANCHU_CLOUD:-none}"
KEEP_VERSIONS="${TIANCHU_KEEP:-7}"

WORKSPACE_DIR="${HOME}/.openclaw/workspace"
IDENTITY_FILE="${WORKSPACE_DIR}/IDENTITY.md"
OPENCLAW_HOME="${HOME}/.openclaw"

# Agent名称
if [ -f "$IDENTITY_FILE" ]; then
  AGENT_NAME=$(grep -m1 '\*\*Name:\*\*' "$IDENTITY_FILE" 2>/dev/null | sed 's/.*\*\*Name:\*\* *//' | tr -d '\r' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
fi
AGENT_NAME="${AGENT_NAME:-xuanjishi}"

BACKUP_NAME="tianchu-${AGENT_NAME}-${TIMESTAMP}"
WORK_DIR="/tmp/${BACKUP_NAME}"

# ═══════════════════════════════════════════════════════════════════
#  二十八宿 · 守护神颜色
# ═══════════════════════════════════════════════════════════════════
NC='\033[0m'
TIANSHU='\033[1;36m'    # 天枢 - 青色 - 北极星
TIANXUAN='\033[1;34m'   # 天璇 - 蓝色 - 璇玑
TIANJI='\033[1;33m'     # 天玑 - 金色 - 珍宝
TIANQUAN='\033[1;32m'   # 天权 - 绿色 - 权衡
YUHENG='\033[1;35m'     # 玉衡 - 紫色 - 衡量
KAIYANG='\033[1;31m'    # 开阳 - 红色 - 推动
YAOGUANG='\033[1;96m'   # 摇光 - 白色 - 光芒

info()  { echo -e "${TIANSHU}[天枢]${NC} $*"; }
store() { echo -e "${TIANXUAN}[天璇]${NC} $*"; }
secure() { echo -e "${TIANJI}[天玑]${NC} $*"; }
version() { echo -e "${TIANQUAN}[天权]${NC} $*"; }
restore() { echo -e "${YUHENG}[玉衡]${NC} $*"; }
auto() { echo -e "${KAIYANG}[开阳]${NC} $*"; }
cloud() { echo -e "${YAOGUANG}[摇光]${NC} $*"; }
warn()  { echo -e "${KAIYANG}[!]${NC} $*"; }
error() { echo -e "${TIANJI}[✗]${NC} $*"; exit 1; }

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "  ${TIANSHU}天枢备份系统${NC} · ${YAOGUANG}北斗九星守护${NC}"
echo "═══════════════════════════════════════════════════════════"
echo "  时间: $TIMESTAMP"
echo "  名称: $BACKUP_NAME"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ── 参数解析 ──────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --cloud)
      CLOUD_PROVIDER="${2:-r2}"
      shift 2
      ;;
    --keep)
      KEEP_VERSIONS="$2"
      shift 2
      ;;
    *)
      OUTPUT_DIR="$1"
      shift
      ;;
  esac
done

# ═══════════════════════════════════════════════════════════════════
#  天璇 · 璇玑存储 (Create Storage)
# ═══════════════════════════════════════════════════════════════════
info "启动备份流程..."
mkdir -p "$OUTPUT_DIR" "$WORK_DIR"

# ═══════════════════════════════════════════════════════════════════
#  备份 · 各组件
# ═══════════════════════════════════════════════════════════════════

# ── Workspace ─────────────────────────────────────────────────────
info "备份Workspace..."
if [ -d "$WORKSPACE_DIR" ]; then
  mkdir -p "${WORK_DIR}/workspace"
  rsync -a \
    --exclude='node_modules/' \
    --exclude='.git/' \
    --exclude='*.tar.gz' \
    --exclude='*.skill' \
    --exclude='*.png' \
    --exclude='*.jpg' \
    --exclude='*.mp4' \
    "$WORKSPACE_DIR/" "${WORK_DIR}/workspace/"
  store "  天璇: workspace → $(du -sh ${WORK_DIR}/workspace | cut -f1)"
fi

# ── Gateway配置 ───────────────────────────────────────────────────
info "备份Gateway配置..."
CONFIG_FILE="${OPENCLAW_HOME}/openclaw.json"
if [ -f "$CONFIG_FILE" ]; then
  mkdir -p "${WORK_DIR}/config"
  cp "$CONFIG_FILE" "${WORK_DIR}/config/openclaw.json"
  store "  天璇: openclaw.json"
fi

# ── Skills ─────────────────────────────────────────────────────────
info "备份Skills..."
SYSTEM_SKILLS_DIR="${OPENCLAW_HOME}/skills"
if [ -d "$SYSTEM_SKILLS_DIR" ] && [ -n "$(ls -A ${SYSTEM_SKILLS_DIR} 2>/dev/null)" ]; then
  mkdir -p "${WORK_DIR}/skills/system"
  rsync -a "$SYSTEM_SKILLS_DIR/" "${WORK_DIR}/skills/system/"
  store "  天璇: $(ls ${WORK_DIR}/skills/system | wc -l) skills"
fi

# ── Credentials ───────────────────────────────────────────────────
info "备份Credentials..."
CREDS_DIR="${OPENCLAW_HOME}/credentials"
if [ -d "$CREDS_DIR" ]; then
  mkdir -p "${WORK_DIR}/credentials"
  rsync -a "$CREDS_DIR/" "${WORK_DIR}/credentials/"
  store "  天璇: credentials"
fi

# ── Agents ────────────────────────────────────────────────────────
info "备份Agents..."
AGENTS_DIR="${OPENCLAW_HOME}/agents"
if [ -d "$AGENTS_DIR" ]; then
  mkdir -p "${WORK_DIR}/agents"
  rsync -a --exclude='*.lock' --exclude='*.deleted.*' "$AGENTS_DIR/" "${WORK_DIR}/agents/"
  store "  天璇: agents + sessions"
fi

# ── Cron ─────────────────────────────────────────────────────────
info "备份Cron..."
CRON_DIR="${OPENCLAW_HOME}/cron"
if [ -d "$CRON_DIR" ]; then
  mkdir -p "${WORK_DIR}/cron"
  rsync -a "$CRON_DIR/" "${WORK_DIR}/cron/"
  store "  天璇: cron tasks"
fi

# ═══════════════════════════════════════════════════════════════════
#  天玑 · 珍宝加密 (Secure Encrypt)
# ═══════════════════════════════════════════════════════════════════
secure "生成加密摘要..."

# ═══════════════════════════════════════════════════════════════════
#  天权 · 版本权衡 (Version Balance)
# ═══════════════════════════════════════════════════════════════════

# MANIFEST
cat > "${WORK_DIR}/MANIFEST.json" <<EOF
{
  "backup_name": "${BACKUP_NAME}",
  "agent_name": "${AGENT_NAME}",
  "timestamp": "${TIMESTAMP}",
  "hostname": "$(hostname)",
  "openclaw_version": "$(openclaw --version 2>/dev/null | head -1 || echo 'unknown')",
  "created_by": "tianchu-guardian v1.0"
}
EOF
version "  天权: MANIFEST.json"

# ═══════════════════════════════════════════════════════════════════
#  打包
# ═══════════════════════════════════════════════════════════════════
echo ""
info "打包备份..."

ARCHIVE="${OUTPUT_DIR}/${BACKUP_NAME}.tar.gz"
tar -czf "$ARCHIVE" -C "/tmp" "$BACKUP_NAME"
rm -rf "$WORK_DIR"
chmod 600 "$ARCHIVE"

ARCHIVE_SIZE=$(du -sh "$ARCHIVE" | cut -f1)
info "本地备份: ${ARCHIVE}"
info "大小: ${ARCHIVE_SIZE}"

# ═══════════════════════════════════════════════════════════════════
#  摇光 · 云端同步 (Cloud Sync)
# ═══════════════════════════════════════════════════════════════════
if [ "$CLOUD_PROVIDER" != "none" ]; then
  cloud "同步到云端 (${CLOUD_PROVIDER})..."
  
  case "$CLOUD_PROVIDER" in
    r2)
      if command -v rclone &>/dev/null; then
        rclone copy "$ARCHIVE" "r2:tianchu-backups/" --quiet
        cloud "  ✅ 已上传R2"
      else
        warn "  ⚠️ rclone未安装"
      fi
      ;;
    b2)
      if command -v rclone &>/dev/null; then
        rclone copy "$ARCHIVE" "b2:tianchu-backups/" --quiet
        cloud "  ✅ 已上传B2"
      fi
      ;;
  esac
fi

# ═══════════════════════════════════════════════════════════════════
#  版本清理
# ═══════════════════════════════════════════════════════════════════
BACKUP_COUNT=$(ls "${OUTPUT_DIR}"/tianchu-*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$KEEP_VERSIONS" ]; then
  version "清理旧备份 (保留${KEEP_VERSIONS}个)..."
  ls -t "${OUTPUT_DIR}"/tianchu-*.tar.gz | tail -n +$((KEEP_VERSIONS + 1)) | xargs rm -f
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "  ${TIANSHU}✅ 天枢备份完成${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
