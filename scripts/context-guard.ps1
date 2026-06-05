# Context Guard — 上下文健康度检查器 (PowerShell)
# 用法: .\scripts\context-guard.ps1
# 返回: exit 0=NONE, 1=COMPACTION, 2=OFFLOADING, 3=RESET

$SESSION_FILE = ".project/context-session.json"

# 1. 计算已修改文件数
$MODIFIED = (git status --short 2>$null | Measure-Object).Count

# 2. 计算已耗时（分钟）
$ELAPSED_MIN = 0
if (Test-Path $SESSION_FILE) {
    $json = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($json.started_at) {
        try {
            $STARTED = [datetime]::Parse($json.started_at)
            $ELAPSED_MIN = [math]::Floor(((Get-Date) - $STARTED).TotalMinutes)
        } catch { }
    }
}

# 3. 计算 handoff / decision 数量
$HANDOFFS = (Get-ChildItem "docs/superpowers/handoffs/*.md" -ErrorAction SilentlyContinue).Count
$DECISIONS = (Get-ChildItem "docs/superpowers/decisions/*.md" -ErrorAction SilentlyContinue).Count

# 4. 决策逻辑
$SUGGESTION = "NONE"
$REASON = "上下文健康。"
$EXIT_CODE = 0

if ($ELAPSED_MIN -ge 120 -or $MODIFIED -ge 40 -or $HANDOFFS -ge 3) {
    $SUGGESTION = "RESET"
    $REASON = "触发条件: >=120min 或 >=40 files 或 >=3 handoffs"
    $EXIT_CODE = 3
} elseif ($ELAPSED_MIN -ge 60 -or $MODIFIED -ge 25 -or $DECISIONS -ge 5) {
    $SUGGESTION = "OFFLOADING"
    $REASON = "触发条件: >=60min 或 >=25 files 或 >=5 decisions"
    $EXIT_CODE = 2
} elseif ($ELAPSED_MIN -ge 30 -or $MODIFIED -ge 10 -or $DECISIONS -ge 3) {
    $SUGGESTION = "COMPACTION"
    $REASON = "触发条件: >=30min 或 >=10 files 或 >=3 decisions"
    $EXIT_CODE = 1
}

# 5. 输出仪表盘
Write-Host "╔══════════════════════════════════════════╗"
Write-Host "║       Context Health Dashboard           ║"
Write-Host "╠══════════════════════════════════════════╣"
Write-Host ("║  {0,-20} : {1,-16} ║" -f "Elapsed Time", "${ELAPSED_MIN} min")
Write-Host ("║  {0,-20} : {1,-16} ║" -f "Modified Files", $MODIFIED)
Write-Host ("║  {0,-20} : {1,-16} ║" -f "Handoff Docs", $HANDOFFS)
Write-Host ("║  {0,-20} : {1,-16} ║" -f "Decision Archives", $DECISIONS)
Write-Host "╠══════════════════════════════════════════╣"
Write-Host ("║  {0,-20} : {1,-16} ║" -f "Suggestion", $SUGGESTION)
Write-Host ("║  {0,-20} : {1,-16} ║" -f "Reason", $REASON.Substring(0, [Math]::Min(30, $REASON.Length)))
Write-Host "╚══════════════════════════════════════════╝"

exit $EXIT_CODE
