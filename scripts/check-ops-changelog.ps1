# Audit Log Pre-Commit Guard (PowerShell)
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
$IsAiAgent = $false
if ($env:OPENCODE -or $env:CLAUDECODE -or $env:AGENT -or $env:CURSOR_AGENT) {
    $IsAiAgent = $true
}
if ($env:AI_AGENT) {
    $IsAiAgent = ($env:AI_AGENT -ne "0")
}

$STAGED = git diff --cached --name-only

# 排除目录：纯文档/配置/自动化生成文件
$CHANGES = $STAGED | Where-Object { $_ -notmatch '^(\.github/|README\.md|docs/|CHANGELOG\.md|\.gemini/)' }

if (-not $CHANGES) {
    exit 0
}

# 检查 ops_changelog 是否在 staged files 中
$LOG_CHANGED = $STAGED | Where-Object { $_ -match '\.project/ops_changelog\.md' }

if (-not $LOG_CHANGED) {
    Write-Host ""
    if ($IsAiAgent) {
        Write-Host "❌ 检测到需要审计的变更，但未更新 .project/ops_changelog.md。" -ForegroundColor Red
    } else {
        Write-Host "⚠️  检测到需要审计的变更，但未更新 .project/ops_changelog.md。" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "变更文件："
    $CHANGES | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
    Write-Host "请在提交前按 meta-safe-executor 协议追加审计记录："
    Write-Host "  1. read_file .project/ops_changelog.md"
    Write-Host "  2. cp .project/ops_changelog.md .project/ops_changelog.md.bak"
    Write-Host "  3. append 操作意图到 .project/ops_changelog.md"
    Write-Host "  4. read_file .project/ops_changelog.md 确认行数增加"
    Write-Host "  5. rm .project/ops_changelog.md.bak"
    Write-Host ""
    if ($IsAiAgent) {
        exit 1
    } else {
        Write-Host "ℹ️  检测到人工提交（无 AI Agent 环境变量），本次不阻断，但建议后续补记。"
        exit 0
    }
}

Write-Host "✅ 审计日志已更新。" -ForegroundColor Green
exit 0
