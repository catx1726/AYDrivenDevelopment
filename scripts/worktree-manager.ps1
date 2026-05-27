# Worktree 管理脚本 — 支持并行隔离开发 (PowerShell 版)
# Usage: .\scripts\worktree-manager.ps1 <command> [args]
#
# Commands:
#   create <issue-number> <branch-suffix>  创建新 worktree 和分支
#   list                                   列出所有 worktree
#   push <issue-number>                    推送指定 worktree 的分支
#   cleanup <issue-number>                 清理并删除 worktree
#   cleanup-merged                         删除已合并的 worktree

param(
    [Parameter(Position = 0)]
    [string]$Command = "help",

    [Parameter(Position = 1)]
    [string]$Arg1,

    [Parameter(Position = 2)]
    [string]$Arg2
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$RepoName = Split-Path -Leaf $RepoRoot

function Show-Help {
    Write-Host "Worktree Manager — 并行开发隔离工具"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\scripts\worktree-manager.ps1 create <issue-number> <branch-suffix>   创建 worktree"
    Write-Host "  .\scripts\worktree-manager.ps1 list                                      列出 worktree"
    Write-Host "  .\scripts\worktree-manager.ps1 push <issue-number>                       推送分支"
    Write-Host "  .\scripts\worktree-manager.ps1 cleanup <issue-number>                    删除 worktree"
    Write-Host "  .\scripts\worktree-manager.ps1 cleanup-merged                            清理已合并的 worktree"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\scripts\worktree-manager.ps1 create 123 feature/auth"
    Write-Host "  .\scripts\worktree-manager.ps1 cleanup 123"
}

function Invoke-Create {
    param([string]$IssueNumber, [string]$BranchSuffix)

    if (-not $IssueNumber -or -not $BranchSuffix) {
        Write-Host "❌ Usage: create <issue-number> <branch-suffix>"
        exit 1
    }

    $BranchName = "issue-${IssueNumber}-${BranchSuffix}"
    $ParentDir = Split-Path -Parent $RepoRoot
    $TargetPath = Join-Path $ParentDir "${RepoName}-issue-${IssueNumber}"

    if (Test-Path $TargetPath) {
        Write-Host "⚠️  Worktree already exists at $TargetPath"
        Write-Host "   Use: cd \"$TargetPath\""
        return
    }

    Write-Host "🌲 Creating worktree..."
    Write-Host "   Branch: $BranchName"
    Write-Host "   Path:   $TargetPath"

    git worktree add "$TargetPath" -b "$BranchName"

    Write-Host ""
    Write-Host "✅ Worktree created. Next steps:"
    Write-Host "   cd \"$TargetPath\""
    Write-Host "   # Start your work here"
    Write-Host "   # When done: .\scripts\worktree-manager.ps1 push $IssueNumber"
}

function Invoke-List {
    Write-Host "📋 Worktree list:"
    git worktree list --porcelain | Select-String "^worktree " | ForEach-Object {
        $Path = $_ -replace "^worktree ", ""
        $Branch = (git -C "$Path" rev-parse --abbrev-ref HEAD 2>$null) -or "detached"
        Write-Host "   $Path ($Branch)"
    }
}

function Invoke-Push {
    param([string]$IssueNumber)

    if (-not $IssueNumber) {
        Write-Host "❌ Usage: push <issue-number>"
        exit 1
    }

    $ParentDir = Split-Path -Parent $RepoRoot
    $TargetPath = Join-Path $ParentDir "${RepoName}-issue-${IssueNumber}"

    if (-not (Test-Path $TargetPath)) {
        Write-Host "❌ Worktree not found: $TargetPath"
        exit 1
    }

    $BranchName = git -C "$TargetPath" rev-parse --abbrev-ref HEAD
    Write-Host "🚀 Pushing branch $BranchName..."
    git -C "$TargetPath" push -u origin "$BranchName"
    Write-Host "✅ Pushed. Create PR with: gh pr create --base main --head $BranchName"
}

function Invoke-Cleanup {
    param([string]$IssueNumber)

    if (-not $IssueNumber) {
        Write-Host "❌ Usage: cleanup <issue-number>"
        exit 1
    }

    $ParentDir = Split-Path -Parent $RepoRoot
    $TargetPath = Join-Path $ParentDir "${RepoName}-issue-${IssueNumber}"

    if (-not (Test-Path $TargetPath)) {
        Write-Host "❌ Worktree not found: $TargetPath"
        exit 1
    }

    $BranchName = git -C "$TargetPath" rev-parse --abbrev-ref HEAD 2>$null

    $Status = git -C "$TargetPath" status --porcelain 2>$null
    if ($Status) {
        Write-Host "⚠️  Uncommitted changes detected in $TargetPath"
        Write-Host "   Commit or stash before cleanup."
        exit 1
    }

    Write-Host "🧹 Removing worktree: $TargetPath"
    git worktree remove "$TargetPath" 2>$null
    if (Test-Path $TargetPath) {
        Remove-Item -Recurse -Force "$TargetPath"
    }

    if ($BranchName -and $BranchName -ne "main" -and $BranchName -ne "master") {
        $Confirm = Read-Host "🗑  Also delete branch '$BranchName'? [y/N]"
        if ($Confirm -match "^[Yy]$") {
            git branch -D "$BranchName" 2>$null
        }
    }

    Write-Host "✅ Cleanup complete"
}

function Invoke-CleanupMerged {
    Write-Host "🔍 Scanning for merged branches with worktrees..."
    git worktree list --porcelain | Select-String "^worktree " | ForEach-Object {
        $Path = $_ -replace "^worktree ", ""
        $Branch = git -C "$Path" rev-parse --abbrev-ref HEAD 2>$null
        if (-not $Branch) { return }
        if ($Branch -eq "main" -or $Branch -eq "master") { return }

        $Merged = git branch --merged main | Select-String $Branch
        if ($Merged) {
            Write-Host "   🗑  $Branch (merged) -> $Path"
            git worktree remove "$Path" 2>$null
            if (Test-Path $Path) { Remove-Item -Recurse -Force "$Path" }
            git branch -D "$Branch" 2>$null
        }
    }
    Write-Host "✅ Cleanup complete"
}

# Main
switch ($Command) {
    "create" { Invoke-Create -IssueNumber $Arg1 -BranchSuffix $Arg2 }
    "list" { Invoke-List }
    "push" { Invoke-Push -IssueNumber $Arg1 }
    "cleanup" { Invoke-Cleanup -IssueNumber $Arg1 }
    "cleanup-merged" { Invoke-CleanupMerged }
    "help" { Show-Help }
    "--help" { Show-Help }
    "-h" { Show-Help }
    default {
        Write-Host "❌ Unknown command: $Command"
        Show-Help
        exit 1
    }
}
