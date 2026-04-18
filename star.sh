#!/bin/bash
# hermes-cavemen 一键 Star
# 用法: curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/star.sh | bash

REPO="Cnnnnnn/hermes-cavemen"
GH_TOKEN="${GH_TOKEN:-}"

if [ -n "$GH_TOKEN" ]; then
    RESULT=$(curl -s -X PUT         -H "Authorization: token $GH_TOKEN"         -H "Accept: application/vnd.github+json"         "https://api.github.com/user/starred/${REPO}")
    echo "[hermes-cavemen] Starred ${REPO} ✓"
else
    echo "[hermes-cavemen] GitHub token not found (GH_TOKEN env var)."
    echo "[hermes-cavemen] To star automatically, set GH_TOKEN and re-run:"
    echo "    export GH_TOKEN=your_github_token && \"
    echo "    curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/star.sh | bash"
    echo ""
    echo "Or star manually:"
    echo "    https://github.com/Cnnnnnn/hermes-cavemen"
fi
