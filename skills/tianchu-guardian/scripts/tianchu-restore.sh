#!/usr/bin/env bash
# 玉衡恢复系统 - TianChu Restore
# 北斗九星守护 · 璇玑史出品

set -euo pipefail

ARCHIVE="$1"
DRY_RUN=false
if [[ "${2:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

OPENCLAW_HOME="${HOME}/.openclaw"
WORK_DIR="/tmp/tianchu-restore-$$"

# 颜色
NC='\033[0m'
YUHENG='\033[1;35m'   # 玉衡 - 紫色
TIANSHU='\033[1;36m'  # 天枢 - 青色
WARN='\033[1;33m'     # 警告

restore() { echo -e "${YUHENG}[玉衡]${NC} $*"; }
info() { echo -e "${TIANSHU}[天枢]${NC} $*"; }
warn() { echo -e "${WARN}[!]${NC} $*"; }

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "  ${YUHENG}玉衡恢复系统${NC}"
echo "═══════════════════════════════════════════════════════════"

# 检查
[ -f "$ARCHIVE" ] || { warn "备份文件不存在: $ARCHIVE"; exit 1; }

if [ "$DRY_RUN" = true ]; then
  warn "🔍 预览模式 — 不会修改任何文件"
  echo ""
fi

# 预览内容
info "解析备份内容..."
tar -tzf "$ARCHIVE" | head -30
echo "..."
tar -tzf "$ARCHIVE" | wc -l | xargs echo "总计文件数:"

# Manifest
MANIFEST=$(tar -xzf "$ARCHIVE" -C /tmp "*/MANIFEST.json" 2>/dev/null && \
  find /tmp -name "MANIFEST.json" -newer "$ARCHIVE" 2>/dev/null | head -1)
if [ -n "$MANIFEST" ] && [ -f "$MANIFEST" ]; then
  echo ""
  info "备份信息:"
  cat "$MANIFEST"
fi

if [ "$DRY_RUN" = true ]; then
  echo ""
  warn "预览完成 — 使用以下命令执行恢复:"
  echo "   $0 $ARCHIVE"
  rm -rf "$WORK_DIR"
  exit 0
fi

# 执行恢复
warn "⚠️ 即将恢复备份，这会覆盖现有数据！"
read -p "确认继续? (yes/no): " CONFIRM
[ "$CONFIRM" != "yes" ] && info "已取消" && exit 0

info "开始恢复..."
mkdir -p "$WORK_DIR"
tar -xzf "$ARCHIVE" -C "$WORK_DIR"

BACKUP_DIR=$(find "$WORK_DIR" -mindepth 1 -maxdepth 1 -type d | head -1)

# 恢复
[ -d "${BACKUP_DIR}/workspace" ] && rsync -a "${BACKUP_DIR}/workspace/" "${OPENCLAW_HOME}/workspace/"
[ -f "${BACKUP_DIR}/config/openclaw.json" ] && cp "${BACKUP_DIR}/config/openclaw.json" "${OPENCLAW_HOME}/openclaw.json"
[ -d "${BACKUP_DIR}/skills/system" ] && rsync -a "${BACKUP_DIR}/skills/system/" "${OPENCLAW_HOME}/skills/"
[ -d "${BACKUP_DIR}/credentials" ] && rsync -a "${BACKUP_DIR}/credentials/" "${OPENCLAW_HOME}/credentials/"
[ -d "${BACKUP_DIR}/agents" ] && rsync -a "${BACKUP_DIR}/agents/" "${OPENCLAW_HOME}/agents/"
[ -d "${BACKUP_DIR}/cron" ] && rsync -a "${BACKUP_DIR}/cron/" "${OPENCLAW_HOME}/cron/"

rm -rf "$WORK_DIR"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "  ${YUHENG}✅ 玉衡恢复完成${NC}"
echo "═══════════════════════════════════════════════════════════"
