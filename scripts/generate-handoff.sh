#!/bin/bash
set -e

# Generate Handoff — 生成标准化上下文交接文档
# 用法: bash scripts/generate-handoff.sh <task-id> [status] [--session-id <id>] [--agent <agent@model>]
# 示例: bash scripts/generate-handoff.sh T-123 in_progress --session-id ses_abc123 --agent opencode@glm-5.3-max

# 会话身份锚点（跨会话可寻址）：session_id/agent 可由参数或环境变量提供，cwd 自动记录
SESSION_ID=""
AGENT=""
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --session-id) SESSION_ID="$2"; shift 2 ;;
    --agent) AGENT="$2"; shift 2 ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
if [ -z "$AGENT" ]; then
  if [ -n "$OPENCODE" ]; then AGENT="opencode"
  elif [ -n "$CLAUDECODE" ]; then AGENT="claude-code"
  elif [ -n "$CURSOR_AGENT" ]; then AGENT="cursor"
  fi
fi
CWD="$(pwd)"

TASK_ID="${ARGS[0]:-TASK-UNKNOWN}"
STATUS="${ARGS[1]:-in_progress}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
DATE=$(date +%Y-%m-%d)
FILENAME="docs/superpowers/handoffs/${TASK_ID}-${TIMESTAMP}.md"

mkdir -p docs/superpowers/handoffs

cat > "$FILENAME" <<EOF
---
handoff_id: ${TASK_ID}-${TIMESTAMP}
session_id: ${SESSION_ID:-<未提供，回查 AI 本地会话存储>}
agent: ${AGENT:-<未识别>}
cwd: ${CWD}
source_session: $(whoami)@$(hostname)
target_session: <新会话标识>
status: ${STATUS}
created_at: ${DATE}
---

# 上下文交接文档

## 任务目标（一句话）
<!-- 用一句话概括当前任务的最终目标 -->

## 已完成工作
<!-- 只保留结论，不保留过程 -->
- [x] 子任务 A：结论是什么
- [x] 子任务 B：结论是什么

## 待办工作
<!-- 只保留下一步行动，不保留背景 -->
- [ ] 子任务 C：需要做什么
- [ ] 子任务 D：需要做什么

## 关键决策
<!-- 必须链接到 docs/superpowers/decisions/ 下的归档文件；若有未归档决策，先用 scripts/archive-decision 留档 -->
- 决策 1：[链接到决策归档文件 docs/superpowers/decisions/xxx.md]
- 决策 2：简要描述

## 已知陷阱
<!-- 新会话必须避开的坑 -->
- 陷阱 1：...
- 陷阱 2：...

## 文件地图
<!-- 新增/修改的关键文件 -->
| 文件 | 状态 | 说明 |
|------|------|------|
| \`src/xxx.ts\` | 新增 | 实现了 Y 功能 |
| \`docs/xxx.md\` | 修改 | 更新了 Z 规范 |

## 引用文档
<!-- 详细内容已 offloading 到这些文件 -->
- [调研报告](docs/superpowers/handoffs/xxx.md)
- [分析结果](docs/superpowers/analysis/yyy.md)
EOF

echo "✅ Handoff 已生成: $FILENAME"
echo "   请编辑该文件，填充任务目标、已完成工作、待办工作等章节。"
