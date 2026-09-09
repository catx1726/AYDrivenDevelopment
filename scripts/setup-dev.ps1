# 开发环境一键安装脚本 (PowerShell)
# - 安装 lefthook
# - 注册 Git hooks
# - 验证安装结果

Write-Host "🔧 Setting up development environment..."

# 1. Check Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js is required but not installed."
    Write-Host "   Please install Node.js (https://nodejs.org) and retry."
    exit 1
}

# 2. Install lefthook
echo "📦 Installing lefthook..."
npx lefthook install

# 3. Verify hooks are registered
echo "🔍 Verifying hooks..."
if (Test-Path ".git/hooks/pre-commit") {
    Write-Host "   ✅ pre-commit hook registered"
} else {
    Write-Host "   ❌ pre-commit hook missing"
    exit 1
}

if (Test-Path ".git/hooks/commit-msg") {
    Write-Host "   ✅ commit-msg hook registered"
} else {
    Write-Host "   ❌ commit-msg hook missing"
    exit 1
}

# 4. Quick validation test
echo "🧪 Running quick validation..."
bash scripts/check-agents-md.sh 2>$null
if ($LASTEXITCODE -ne 0) {
    powershell -File scripts/check-agents-md.ps1
}

# 5. Check GitHub CLI (warning only - required for Issue/PR lifecycle, not for hooks)
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ GitHub CLI installed and authenticated"
    } else {
        Write-Host "   ⚠️ GitHub CLI installed but NOT authenticated. Run: gh auth login"
    }
} else {
    Write-Host "   ⚠️ GitHub CLI not found. Issue/PR lifecycle requires it. Install: https://cli.github.com"
}

# 6. Check python3 (warning only - optional, used by context-guard.sh elapsed calculation)
if (Get-Command python3 -ErrorAction SilentlyContinue) {
    Write-Host "   ✅ python3 found (context-guard elapsed calculation available)"
} else {
    Write-Host "   ⚠️ python3 not found. context-guard elapsed will show 'unknown' (token detection unaffected)."
}

Write-Host ""
Write-Host "✅ Setup complete! Your commits are now guarded by:"
Write-Host "   • AGENTS.md size check (≤ 100 lines)"
Write-Host "   • Destructive command detection"
Write-Host "   • Conventional Commit enforcement"
