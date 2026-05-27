#!/usr/bin/env bash
# 在 diff 中检测破坏性命令或危险模式
# 用于 pre-commit hook 和 Agent 执行前检查

DANGEROUS_PATTERNS=(
  "rm -rf"
  "git push --force"
  "git push -f"
  "DROP TABLE"
  "DELETE FROM"
  "> /dev/null"
  ":> "
  "Clear-Content"
  "Remove-Item -Recurse"
)

FOUND=0
DIFF=$(git diff --cached --name-only)

if [ -z "$DIFF" ]; then
  exit 0
fi

# 检查暂存区中是否有危险命令（主要在 shell 脚本中）
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  MATCH=$(git diff --cached -G"$pattern" --name-only 2>/dev/null || true)
  if [ -n "$MATCH" ]; then
    echo "⚠️  Potential destructive pattern detected: '$pattern'"
    echo "   Files: $MATCH"
    FOUND=1
  fi
done

if [ "$FOUND" -eq 1 ]; then
  echo ""
  echo "If these changes are intentional, commit with --no-verify (not recommended)."
  echo "For Agent execution, escalate to Driver for approval."
  exit 1
fi

echo "✅ No destructive patterns detected in staged changes"
exit 0
