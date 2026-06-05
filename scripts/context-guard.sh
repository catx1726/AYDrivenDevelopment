#!/bin/bash
set -e

# Context Guard — 上下文健康度检查器
# 用法: bash scripts/context-guard.sh
# 返回: exit 0=NONE, 1=COMPACTION, 2=OFFLOADING, 3=RESET

SESSION_FILE=".project/context-session.json"

# 1. 计算已修改文件数（含未跟踪）
MODIFIED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')

# 2. 计算已耗时（分钟）
ELAPSED_MIN=0
if [ -f "$SESSION_FILE" ]; then
  STARTED_AT=$(python3 -c "import json; print(json.load(open('$SESSION_FILE')).get('started_at',''))" 2>/dev/null || echo "")
  if [ -n "$STARTED_AT" ]; then
    START_EPOCH=$(date -d "$STARTED_AT" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${STARTED_AT%%+*}" +%s 2>/dev/null)
    NOW_EPOCH=$(date +%s)
    if [ -n "$START_EPOCH" ]; then
      ELAPSED_MIN=$(( (NOW_EPOCH - START_EPOCH) / 60 ))
    fi
  fi
fi

# 3. 计算 handoff / decision 数量
HANDOFFS=$(ls docs/superpowers/handoffs/*.md 2>/dev/null | wc -l | tr -d ' ')
DECISIONS=$(ls docs/superpowers/decisions/*.md 2>/dev/null | wc -l | tr -d ' ')

# 4. 决策逻辑
SUGGESTION="NONE"
REASON="上下文健康。"
EXIT_CODE=0

if [ "$ELAPSED_MIN" -ge 120 ] || [ "$MODIFIED" -ge 40 ] || [ "$HANDOFFS" -ge 3 ]; then
  SUGGESTION="RESET"
  REASON="触发条件: >=120min 或 >=40 files 或 >=3 handoffs"
  EXIT_CODE=3
elif [ "$ELAPSED_MIN" -ge 60 ] || [ "$MODIFIED" -ge 25 ] || [ "$DECISIONS" -ge 5 ]; then
  SUGGESTION="OFFLOADING"
  REASON="触发条件: >=60min 或 >=25 files 或 >=5 decisions"
  EXIT_CODE=2
elif [ "$ELAPSED_MIN" -ge 30 ] || [ "$MODIFIED" -ge 10 ] || [ "$DECISIONS" -ge 3 ]; then
  SUGGESTION="COMPACTION"
  REASON="触发条件: >=30min 或 >=10 files 或 >=3 decisions"
  EXIT_CODE=1
fi

# 5. 输出仪表盘
echo "╔══════════════════════════════════════════╗"
echo "║       Context Health Dashboard           ║"
echo "╠══════════════════════════════════════════╣"
printf "║  %-20s : %-16s ║\n" "Elapsed Time" "${ELAPSED_MIN} min"
printf "║  %-20s : %-16s ║\n" "Modified Files" "$MODIFIED"
printf "║  %-20s : %-16s ║\n" "Handoff Docs" "$HANDOFFS"
printf "║  %-20s : %-16s ║\n" "Decision Archives" "$DECISIONS"
echo "╠══════════════════════════════════════════╣"
printf "║  %-20s : %-16s ║\n" "Suggestion" "$SUGGESTION"
printf "║  %-20s : %-16s ║\n" "Reason" "${REASON:0:30}"
echo "╚══════════════════════════════════════════╝"

exit $EXIT_CODE
