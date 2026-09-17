#!/bin/bash
set -e

# Audit Log Pre-Commit Guard
# 原则：如果存在需要审计的变更，必须同时更新 .project/ops_changelog.md
#
# 人机区分：
# AI CLI（如 OpenCode/Claude Code 等）启动的终端会自带 OPENCODE=1 / AGENT=1
# 等环境变量，人工在普通终端/IDE 内提交时不会有这些变量。也可用 AI_AGENT=1
# / AI_AGENT=0 显式覆盖探测结果（例如人工临时代 AI 调试、或新 CLI 尚未被
# 自动识别时）。
# - AI 提交：检测到变更未记录审计日志时，强制阻断（exit 1），因为 AI 的
#   自动化操作更需要留痕，防止未经审计的破坏性变更。
# - 人工提交：仅打印提醒（不阻断），减轻人工日常小改动的负担，但仍建议
#   对重要变更手动记录。
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

STAGED=$(git diff --cached --name-only)

# 排除目录：纯文档/配置/自动化生成文件
CHANGES=$(echo "$STAGED" | grep -vE '^(\.github/|README\.md|docs/|CHANGELOG\.md|\.gemini/)' || true)

if [ -z "$CHANGES" ]; then
    exit 0
fi

# 检查 ops_changelog 是否在 staged files 中
LOG_CHANGED=$(echo "$STAGED" | grep '\.project/ops_changelog\.md' || true)

if [ -z "$LOG_CHANGED" ]; then
    echo ""
    if [ "$IS_AI_AGENT" = "1" ]; then
        echo "❌ 检测到需要审计的变更，但未更新 .project/ops_changelog.md。"
    else
        echo "⚠️  检测到需要审计的变更，但未更新 .project/ops_changelog.md。"
    fi
    echo ""
    echo "变更文件："
    echo "$CHANGES"
    echo ""
    echo "请在提交前按 meta-safe-executor 协议追加审计记录："
    echo "  1. read_file .project/ops_changelog.md"
    echo "  2. cp .project/ops_changelog.md .project/ops_changelog.md.bak"
    echo "  3. append 操作意图到 .project/ops_changelog.md"
    echo "  4. read_file .project/ops_changelog.md 确认行数增加"
    echo "  5. rm .project/ops_changelog.md.bak"
    echo ""
    if [ "$IS_AI_AGENT" = "1" ]; then
        exit 1
    else
        echo "ℹ️  检测到人工提交（无 AI Agent 环境变量），本次不阻断，但建议后续补记。"
        exit 0
    fi
fi

echo "✅ 审计日志已更新。"
exit 0
