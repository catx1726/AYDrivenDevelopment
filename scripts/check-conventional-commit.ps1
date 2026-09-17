# 检查 commit message 是否符合 Conventional Commits 规范
# Usage: check-conventional-commit.ps1 <commit-msg-file>
#
# 人机区分：AI CLI（如 OpenCode/Claude Code 等）启动的终端会自带
# OPENCODE=1 / AGENT=1 等环境变量，人工在普通终端/IDE 内提交时不会有
# 这些变量。也可用 AI_AGENT=1 / AI_AGENT=0 显式覆盖探测结果。
# - AI 提交：格式不合规时强制阻断（exit 1），保持机器产出的规范一致性。
# - 人工提交：仅警告不阻断（exit 0），避免因忘记前缀反复被打回。

$IsAiAgent = $false
if ($env:OPENCODE -or $env:CLAUDECODE -or $env:AGENT -or $env:CURSOR_AGENT) {
    $IsAiAgent = $true
}
if ($env:AI_AGENT) {
    $IsAiAgent = ($env:AI_AGENT -ne "0")
}

$MsgFile = $args[0]
if (-not $MsgFile) {
    $MsgFile = ".git/COMMIT_EDITMSG"
}

if (-not (Test-Path $MsgFile)) {
    Write-Host "❌ Commit message file not found: $MsgFile"
    exit 1
}

# 读取第一行（忽略注释和空行）
$Lines = Get-Content $MsgFile | Where-Object { $_ -notmatch "^#" -and $_ -notmatch "^$" }
$Msg = $Lines | Select-Object -First 1

if (-not $Msg) {
    Write-Host "❌ Commit message is empty"
    exit 1
}

if ($Msg -notmatch '^(feat|fix|docs|style|refactor|test|chore|ci|revert)(\(.+\))?: .+') {
    if ($IsAiAgent) {
        Write-Host "❌ Commit message must follow Conventional Commits" -ForegroundColor Red
    } else {
        Write-Host "⚠️  Commit message does not follow Conventional Commits" -ForegroundColor Yellow
    }
    Write-Host "   Current: $Msg"
    Write-Host "   Example: feat(auth): add login endpoint"
    if ($IsAiAgent) {
        exit 1
    } else {
        Write-Host "ℹ️  检测到人工提交（无 AI Agent 环境变量），本次不阻断，建议下次补上类型前缀。"
        exit 0
    }
}

Write-Host "✅ Commit message follows Conventional Commits" -ForegroundColor Green
exit 0
