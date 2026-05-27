# 在 diff 中检测破坏性命令或危险模式
# 用于 pre-commit hook 和 Agent 执行前检查

$DangerousPatterns = @(
    "rm -rf",
    "git push --force",
    "git push -f",
    "DROP TABLE",
    "DELETE FROM",
    "> /dev/null",
    ":> ",
    "Clear-Content",
    "Remove-Item -Recurse"
)

$Found = 0
$DiffFiles = git diff --cached --name-only 2>$null

if (-not $DiffFiles) {
    exit 0
}

foreach ($pattern in $DangerousPatterns) {
    $Match = git diff --cached -G"$pattern" --name-only 2>$null
    if ($Match) {
        Write-Host "⚠️  Potential destructive pattern detected: '$pattern'"
        Write-Host "   Files: $Match"
        $Found = 1
    }
}

if ($Found -eq 1) {
    Write-Host ""
    Write-Host "If these changes are intentional, commit with --no-verify (not recommended)."
    Write-Host "For Agent execution, escalate to Driver for approval."
    exit 1
}

Write-Host "✅ No destructive patterns detected in staged changes"
exit 0
