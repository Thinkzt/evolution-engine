#!/usr/bin/env bash
# 天枢守护 · Cloudflare R2云同步
# 使用Cloudflare R2 API（非S3）
# 北斗九星守护 · 璇玑史出品

set -euo pipefail

# ═══════════════════════════════════════════════════════════════════
#  配置
# ═══════════════════════════════════════════════════════════════════
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="${1:-/tmp/tianchu-backups}"
KEEP_VERSIONS="${TIANCHU_KEEP:-7}"

WORKSPACE_DIR="${HOME}/.openclaw/workspace"
OPENCLAW_HOME="${HOME}/.openclaw"

# Cloudflare R2 配置（从环境变量或配置文件读取）
CF_ACCOUNT_ID="${CF_ACCOUNT_ID:-718cbb96a7a12d94da8bb0a7c7a1fc74}"
CF_API_TOKEN="${CF_API_TOKEN:-cfat_FoHMeaKIUa6XJhQNStDBY33jAzPEXApktg5x8CJg0ce5883c}"
R2_BUCKET="${R2_BUCKET:-xuanji-backups}"

# Agent名称
IDENTITY_FILE="${WORKSPACE_DIR}/IDENTITY.md"
if [ -f "$IDENTITY_FILE" ]; then
  AGENT_NAME=$(grep -m1 '\*\*Name:\*\*' "$IDENTITY_FILE" 2>/dev/null | sed 's/.*\*\*Name:\*\* *//' | tr -d '\r' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
fi
AGENT_NAME="${AGENT_NAME:-xuanjishi}"

BACKUP_NAME="tianchu-${AGENT_NAME}-${TIMESTAMP}"
WORK_DIR="/tmp/${BACKUP_NAME}"

# API端点
CF_API="https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/r2/buckets/${R2_BUCKET}/objects"

# ═══════════════════════════════════════════════════════════════════
#  颜色
# ═══════════════════════════════════════════════════════════════════
NC='\033[0m'
TIANSHU='\033[1;36m'
YAOGUANG='\033[1;96m'
KAIYANG='\033[1;31m'

info()  { echo -e "${TIANSHU}[天枢]${NC} $*"; }
cloud() { echo -e "${YAOGUANG}[摇光]${NC} $*"; }
auto()  { echo -e "${KAIYANG}[开阳]${NC} $*"; }
warn()  { echo -e "${KAIYANG}[!]${NC} $*"; }

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "  ${TIANSHU}天枢守护 · R2云同步${NC}"
echo "═══════════════════════════════════════════════════════════"
echo "  Bucket: ${R2_BUCKET}"
echo "  Account: ${CF_ACCOUNT_ID}"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ── 创建本地备份 ──────────────────────────────────────────────────
info "创建本地备份..."
mkdir -p "$OUTPUT_DIR" "$WORK_DIR"

# Workspace
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
fi

# Config
CONFIG_FILE="${OPENCLAW_HOME}/openclaw.json"
[ -f "$CONFIG_FILE" ] && mkdir -p "${WORK_DIR}/config" && cp "$CONFIG_FILE" "${WORK_DIR}/config/"

# Skills
SYSTEM_SKILLS_DIR="${OPENCLAW_HOME}/skills"
[ -d "$SYSTEM_SKILLS_DIR" ] && [ -n "$(ls -A ${SYSTEM_SKILLS_DIR} 2>/dev/null)" ] && \
  mkdir -p "${WORK_DIR}/skills/system" && rsync -a "$SYSTEM_SKILLS_DIR/" "${WORK_DIR}/skills/system/"

# Agents
AGENTS_DIR="${OPENCLAW_HOME}/agents"
[ -d "$AGENTS_DIR" ] && mkdir -p "${WORK_DIR}/agents" && \
  rsync -a --exclude='*.lock' --exclude='*.deleted.*' "$AGENTS_DIR/" "${WORK_DIR}/agents/"

# Cron
CRON_DIR="${OPENCLAW_HOME}/cron"
[ -d "$CRON_DIR" ] && mkdir -p "${WORK_DIR}/cron" && rsync -a "$CRON_DIR/" "${WORK_DIR}/cron/"

# Manifest
cat > "${WORK_DIR}/MANIFEST.json" <<EOF
{
  "backup_name": "${BACKUP_NAME}",
  "agent_name": "${AGENT_NAME}",
  "timestamp": "${TIMESTAMP}",
  "hostname": "$(hostname)",
  "created_by": "tianchu-guardian v1.0"
}
EOF

# 打包
info "打包备份..."
ARCHIVE="${OUTPUT_DIR}/${BACKUP_NAME}.tar.gz"
tar -czf "$ARCHIVE" -C "/tmp" "$BACKUP_NAME"
rm -rf "$WORK_DIR"
chmod 600 "$ARCHIVE"

ARCHIVE_SIZE=$(du -sh "$ARCHIVE" | cut -f1)
info "本地备份: ${ARCHIVE} (${ARCHIVE_SIZE})"

# ── 上传到R2 ───────────────────────────────────────────────────────
cloud "上传到Cloudflare R2..."

# 上传函数
upload_to_r2() {
  local file="$1"
  local key="$2"
  
  curl -s -X PUT \
    "${CF_API}/${key}" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @"$file" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('success'):
    print('.', end='', flush=True)
else:
    print('✗', end='', flush=True)
"
}

# 上传备份文件
BACKUP_KEY="backups/$(basename $ARCHIVE)"
upload_to_r2 "$ARCHIVE" "$BACKUP_KEY"

# 上传Manifest
echo "$ARCHIVE" | upload_to_r2 /dev/stdin "backups/${BACKUP_NAME}_archive_path.txt"

echo ""
cloud "上传完成!"

# ── 验证 ──────────────────────────────────────────────────────────
info "验证R2内容..."
curl -s -X GET "${CF_API}" \
  -H "Authorization: Bearer ${CF_API_TOKEN}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('success'):
    files = data.get('result', [])
    print(f'  R2存储桶共有 {len(files)} 个文件')
    for f in files[-3:]:
        print(f\"  - {f['key']} ({f['size']} bytes)\")
"

# ── 清理旧备份 ────────────────────────────────────────────────────
info "检查本地旧备份..."
BACKUP_COUNT=$(ls "${OUTPUT_DIR}"/tianchu-*.tar.gz 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$KEEP_VERSIONS" ]; then
  auto "清理旧备份 (保留${KEEP_VERSIONS}个)..."
  ls -t "${OUTPUT_DIR}"/tianchu-*.tar.gz | tail -n +$((KEEP_VERSIONS + 1)) | xargs rm -f
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "  ${YAOGUANG}✅ 天枢R2云同步完成${NC}"
echo "═══════════════════════════════════════════════════════════"
