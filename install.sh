#!/bin/bash
# hermes-cavemen 一键安装脚本
# 用法: curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/install.sh | bash

set -e

REPO="Cnnnnnn/hermes-cavemen"
RAW="https://raw.githubusercontent.com/${REPO}/main"

detect_platform() {
    if [ -n "$HERMES_CONFIG_DIR" ]; then
        echo "hermes"
    elif [ -d "$HOME/.hermes" ]; then
        echo "hermes"
    elif [ -d "$HOME/.openclaw" ]; then
        echo "openclaw"
    elif command -v hermes &>/dev/null; then
        echo "hermes"
    elif command -v openclaw &>/dev/null; then
        echo "openclaw"
    else
        echo "hermes"
    fi
}

PLATFORM=$(detect_platform)
echo "[hermes-cavemen] Detected platform: $PLATFORM"

SOUL_DIR=""
MEMORY_PATH=""

case "$PLATFORM" in
    hermes)
        SOUL_DIR="${HERMES_CONFIG_DIR:-${HOME}/.hermes}"
        SOUL_TARGET="${SOUL_DIR}/SOUL.md"
        MEMORY_PATH="${SOUL_DIR}/memories/MEMORY.md"
        ;;
    openclaw)
        SOUL_DIR="${HOME}/.openclaw"
        SOUL_TARGET="${SOUL_DIR}/SOUL.md"
        MEMORY_PATH="${SOUL_DIR}/memories/MEMORY.md"
        ;;
esac

echo "[hermes-cavemen] SOUL.md → ${SOUL_TARGET}"

mkdir -p "${SOUL_DIR}"
mkdir -p "$(dirname "${MEMORY_PATH}")"

# 下载 SOUL.md
curl -s "${RAW}/SOUL.md" -o /tmp/SOUL_md_new
if [ ! -s /tmp/SOUL_md_new ]; then
    echo "[hermes-cavemen] ERROR: Failed to download SOUL.md"
    exit 1
fi

# 追加 Terse Mode 规则（如果还没有）
INSTALLED=0
if [ -f "${SOUL_TARGET}" ]; then
    if grep -q "## Terse Mode" "${SOUL_TARGET}"; then
        INSTALLED=1
    else
        echo "" >> "${SOUL_TARGET}"
        echo "" >> "${SOUL_TARGET}"
        python3 -c "
with open('/tmp/SOUL_md_new') as f:
    new = f.read()
with open('${SOUL_TARGET}', 'a') as f:
    f.write(new)
"
        echo "[hermes-cavemen] Appended Terse Mode to existing SOUL.md"
    fi
else
    python3 -c "
import shutil
shutil.copy('/tmp/SOUL_md_new', '${SOUL_TARGET}')
"
    echo "[hermes-cavemen] Created new SOUL.md"
fi

# 写 MEMORY.md
MEMORY_LINE="terse_level: full"
python3 -c "
import os
mem_path = '${MEMORY_PATH}'
os.makedirs(os.path.dirname(mem_path), exist_ok=True)

if os.path.exists(mem_path):
    with open(mem_path) as f:
        content = f.read()
    lines = content.split('\n')
    found = False
    for i, line in enumerate(lines):
        if line.strip().startswith('terse_level:'):
            lines[i] = '${MEMORY_LINE}'
            found = True
            break
    if not found:
        lines.append('${MEMORY_LINE}')
    with open(mem_path, 'w') as f:
        f.write('\n'.join(lines))
else:
    with open(mem_path, 'w') as f:
        f.write('${MEMORY_LINE}\n')
"
echo "[hermes-cavemen] MEMORY.md updated — terse_level: full"

# ===== 版本检查（已安装时） =====
if [ "${INSTALLED}" = "1" ]; then
    echo ""
    echo "[hermes-cavemen] Terse Mode already installed — checking for updates..."

    REMOTE_VERSION=$(curl -s "${RAW}/VERSION" 2>/dev/null | tr -d '[:space:]' || echo "")
    LOCAL_VERSION=""
    if [ -f "${SOUL_DIR}/.hermes-cavemen-version" ]; then
        LOCAL_VERSION=$(cat "${SOUL_DIR}/.hermes-cavemen-version" 2>/dev/null | tr -d '[:space:]')
    elif grep -q "hermes-cavemen" "${SOUL_TARGET}" 2>/dev/null; then
        LOCAL_VERSION="1.0.0"
    fi

    if [ -n "$REMOTE_VERSION" ] && [ -n "$LOCAL_VERSION" ] && [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
        echo "[hermes-cavemen] Update available: v${LOCAL_VERSION} → v${REMOTE_VERSION}"
        echo ""
        echo "Run to update:"
        echo "  curl -s ${RAW}/update.sh | bash"
        echo ""
    elif [ -n "$REMOTE_VERSION" ]; then
        echo "[hermes-cavemen] Already on latest version (v${REMOTE_VERSION}) ✓"
    fi
fi

# 记录当前版本
if [ -n "$REMOTE_VERSION" ]; then
    echo "$REMOTE_VERSION" > "${SOUL_DIR}/.hermes-cavemen-version"
fi

echo ""
echo "[hermes-cavemen] ✓ Install complete! Restart session — Terse Mode (full) active"
echo "[hermes-cavemen] Switch: /terse ultra | /terse wenyan | /terse wenyan-lite"
echo "[hermes-cavemen] Exit:   normal mode / 正常模式"
