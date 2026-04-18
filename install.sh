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

SOUL_TARGET=""
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
if [ -f "${SOUL_TARGET}" ]; then
    if grep -q "## Terse Mode" "${SOUL_TARGET}"; then
        echo "[hermes-cavemen] SOUL.md already has Terse Mode — skipping"
    else
        echo "" >> "${SOUL_TARGET}"
        echo "" >> "${SOUL_TARGET}"
        cat /tmp/SOUL_md_new >> "${SOUL_TARGET}"
        echo "[hermes-cavemen] Appended Terse Mode to existing SOUL.md"
    fi
else
    cp /tmp/SOUL_md_new "${SOUL_TARGET}"
    echo "[hermes-cavemen] Created new SOUL.md"
fi

# 写 MEMORY.md
MEMORY_LINE="terse_level: full"
if [ -f "${MEMORY_PATH}" ]; then
    if grep -q "^terse_level:" "${MEMORY_PATH}"; then
        sed -i "s/^terse_level:.*/${MEMORY_LINE}/" "${MEMORY_PATH}"
    else
        echo "${MEMORY_LINE}" >> "${MEMORY_PATH}"
    fi
else
    mkdir -p "$(dirname "${MEMORY_PATH}")"
    echo "${MEMORY_LINE}" > "${MEMORY_PATH}"
fi
echo "[hermes-cavemen] MEMORY.md updated — terse_level: full"

echo ""
echo "[hermes-cavemen] ✓ 安装完成！重启 Hermes/OpenClaw 后 Terse Mode (full) 自动生效"
echo "[hermes-cavemen] 切换级别: /terse ultra  /terse wenyan"
echo "[hermes-cavemen] 退出: normal mode / 正常模式"
