#!/usr/bin/env bash
# 检查 commit message 是否符合 Conventional Commits 规范
# Usage: check-conventional-commit.sh <commit-msg-file>
#
# 人机区分：AI CLI（如 OpenCode/Claude Code 等）启动的终端会自带
# OPENCODE=1 / AGENT=1 等环境变量，人工在普通终端/IDE 内提交时不会有
# 这些变量。也可用 AI_AGENT=1 / AI_AGENT=0 显式覆盖探测结果。
# - AI 提交：格式不合规时强制阻断（exit 1），保持机器产出的规范一致性。
# - 人工提交：仅警告不阻断（exit 0），避免因忘记前缀反复被打回。

IS_AI_AGENT=0
if [ -n "$OPENCODE" ] || [ -n "$CLAUDECODE" ] || [ -n "$AGENT" ] || [ -n "$CURSOR_AGENT" ]; then
    IS_AI_AGENT=1
fi
if [ -n "$AI_AGENT" ]; then
    if [ "$AI_AGENT" = "0" ]; then
        IS_AI_AGENT=0
    else
        IS_AI_AGENT=1
    fi
fi

MSG_FILE="${1:-.git/COMMIT_EDITMSG}"

if [ ! -f "$MSG_FILE" ]; then
  echo "❌ Commit message file not found: $MSG_FILE"
  exit 1
fi

# 读取第一行（忽略注释和空行）
MSG=$(grep -v "^#" "$MSG_FILE" | grep -v "^$" | head -n 1)

if [ -z "$MSG" ]; then
  echo "❌ Commit message is empty"
  exit 1
fi

if ! echo "$MSG" | grep -qE '^(feat|fix|docs|style|refactor|test|chore|ci|revert)(\(.+\))?: .+'; then
  if [ "$IS_AI_AGENT" = "1" ]; then
    echo "❌ Commit message must follow Conventional Commits"
  else
    echo "⚠️  Commit message does not follow Conventional Commits"
  fi
  echo "   Current: $MSG"
  echo "   Example: feat(auth): add login endpoint"
  if [ "$IS_AI_AGENT" = "1" ]; then
    exit 1
  else
    echo "ℹ️  检测到人工提交（无 AI Agent 环境变量），本次不阻断，建议下次补上类型前缀。"
    exit 0
  fi
fi

echo "✅ Commit message follows Conventional Commits"
exit 0
