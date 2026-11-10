# Check Adoption — 子库接入前置自检 (PowerShell)
# 用法: .\scripts\check-adoption.ps1（在子库根目录运行，从母库路径调用）
# 返回: exit 0=就绪, 1=缺接入资产, 2=缺关键工具

$MISSING_ASSETS = 0
$MISSING_TOOLS = 0

Write-Host "============================================"
Write-Host "  子库接入自检 (Check Adoption)"
Write-Host "============================================"

Write-Host ""
Write-Host "[1/3] 接入资产（按母库 child-repo-guide.md §3 安装）"
foreach ($f in @('scripts/context-guard.sh', 'lefthook.yml', '.github/workflows/audit_check.yml')) {
    if (Test-Path $f) { Write-Host "  ✅ $f" } else { Write-Host "  ❌ $f 缺失"; $MISSING_ASSETS = 1 }
}
foreach ($d in @('docs/superpowers/handoffs', 'docs/superpowers/decisions', '.project')) {
    if (Test-Path $d) { Write-Host "  ✅ $d/" } else { Write-Host "  ❌ $d/ 缺失"; $MISSING_ASSETS = 1 }
}
if ((Test-Path AGENTS.md) -and (Select-String -Path AGENTS.md -Pattern 'SOP-HOME' -Quiet)) {
    Write-Host "  ✅ AGENTS.md 桥接"
} else {
    Write-Host "  ❌ AGENTS.md 桥接缺失（用 child-repo-guide.md §4 模板创建）"
    $MISSING_ASSETS = 1
}
# .gitignore 冲突检测（Eclipse 规则忽略 .project 会静默断掉审计链）
if (Test-Path .gitignore) {
    git check-ignore -q .project 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ⚠️ .project/ 被 .gitignore 忽略（Eclipse 规则冲突）——审计日志无法入库，钩子将持续失败"
        Write-Host "     修复：在 .gitignore 中追加一行  !/.project/"
    }
}

Write-Host ""
Write-Host "[2/3] 工具链"
if (Get-Command git -ErrorAction SilentlyContinue) { Write-Host "  ✅ git" } else { Write-Host "  ❌ git 缺失"; $MISSING_TOOLS = 2 }
if (Get-Command node -ErrorAction SilentlyContinue) { Write-Host "  ✅ Node.js" } else { Write-Host "  ❌ Node.js 缺失（lefthook 安装需要）: https://nodejs.org"; $MISSING_TOOLS = 2 }
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ GitHub CLI"
    gh auth status 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ gh 已认证"
    } else {
        Write-Host "  ❌ gh 未认证: 需 Driver 在终端手动执行 gh auth login（浏览器交互式，AI 不可代办）"
        $MISSING_TOOLS = 2
    }
} else {
    Write-Host "  ❌ GitHub CLI 缺失（Issue/PR 流程需要）: https://cli.github.com"
    $MISSING_TOOLS = 2
}
if (Get-Command python3 -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ python3（可选）"
} else {
    Write-Host "  ⚠️ python3 缺失（可选，仅影响 context-guard 耗时统计）"
}

Write-Host ""
Write-Host "[3/3] AI 端 Superpowers 插件探测（文件级只读，不阻塞自检）"
# 探测矩阵与逻辑边界见 docs/superpowers/research/superpowers-install-detection-research-2026-11-10.md
$SP_DETECTED = $false

# OpenCode：V1 配置键名 plugin / V2（2.0.4+）键名 plugins；全局与项目级配置都查
$ocFiles = @(
    (Join-Path $HOME '.config/opencode/opencode.json'),
    (Join-Path $HOME '.config/opencode/opencode.jsonc'),
    (Join-Path (Get-Location) 'opencode.json'),
    (Join-Path (Get-Location) 'opencode.jsonc')
) | Where-Object { Test-Path $_ }
if ($ocFiles) {
    $ocContent = ($ocFiles | ForEach-Object { Get-Content $_ -Raw }) -join "`n"
    if ($ocContent -match '"plugins?"\s*:\s*\[[^\]]*superpowers') {
        Write-Host "  ✅ Superpowers 已配置（opencode）"
        $SP_DETECTED = $true
    } else {
        Write-Host "  ⚠️ 未检测到 Superpowers 插件（opencode）。完整生命周期（brainstorming/writing-plans/TDD）依赖它。安装："
        Write-Host '     opencode.json 加入：{ "plugins": ["superpowers@git+https://github.com/obra/superpowers.git"] }（V1 键名为 "plugin"）'
        Write-Host '     重启后验证："Tell me about your superpowers"；Windows 安装问题见上游 docs/README.opencode.md 的 Troubleshooting'
        $SP_DETECTED = $true
    }
}

# Claude Code：插件配置目录中出现 superpowers 即视为已安装
$ccPluginDir = Join-Path $HOME '.claude/plugins'
if (Test-Path $ccPluginDir) {
    $ccHit = Get-ChildItem $ccPluginDir -Recurse -Filter *.json -ErrorAction SilentlyContinue |
        Where-Object { (Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue) -match 'superpowers' }
    if ($ccHit) {
        Write-Host "  ✅ Superpowers 已安装（claude code）"
        $SP_DETECTED = $true
    }
}

# Gemini CLI / Qwen Code（qwen 为 gemini-cli fork，扩展布局相同）：extensions/ 下出现 superpowers 目录
foreach ($pair in @(@('gemini', (Join-Path $HOME '.gemini/extensions')), @('qwen', (Join-Path $HOME '.qwen/extensions')))) {
    $spName = $pair[0]; $spDir = $pair[1]
    if ((Test-Path $spDir) -and (Get-ChildItem $spDir -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'superpowers' })) {
        Write-Host "  ✅ Superpowers 已安装（${spName} extensions/）"
        $SP_DETECTED = $true
    }
}

# 项目内安装痕迹（旧 clone/submodule/npm 兜底方式）
if ((Test-Path skills/superpowers) -or (Test-Path node_modules/superpowers)) {
    Write-Host "  ✅ Superpowers 已安装（项目内 skills/ 或 node_modules/）"
    $SP_DETECTED = $true
}

# 启发式扫描其余 harness：只查其插件/扩展子目录与顶层配置文件中的肯定信号
# （刻意不扫 sessions/projects/history 等转录目录——历史会话提过 superpowers 会误报；
#   未检出≠未安装，最终仍降级为通用提示）
foreach ($h in @('codex','cursor','copilot','factory','kimi','grok','devin','antigravity','pi','hermes','muse')) {
    $spHome = Join-Path $HOME ".$h"
    if (-not (Test-Path $spHome)) { continue }
    $spHit = $null
    foreach ($sub in @('plugins','extensions')) {
        $subDir = Join-Path $spHome $sub
        if (Test-Path $subDir) {
            $spHit = Get-ChildItem $subDir -Recurse -Include *.json,*.toml -ErrorAction SilentlyContinue |
                Select-String -Pattern 'superpowers' -List -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($spHit) { break }
        }
    }
    if (-not $spHit) {
        foreach ($cf in @('config.json','config.toml','settings.json')) {
            $cfPath = Join-Path $spHome $cf
            if ((Test-Path $cfPath) -and (Select-String -Path $cfPath -Pattern 'superpowers' -Quiet)) { $spHit = $cfPath; break }
        }
    }
    if ($spHit) {
        Write-Host "  ✅ Superpowers 已安装（$h）"
        $SP_DETECTED = $true
    }
}

if (-not $SP_DETECTED) {
    Write-Host "  ℹ️ 未能按平台文件级探测 Superpowers（Claude Code 请用 /plugin 查看；其余平台按各自插件机制安装）。"
    Write-Host "     完整生命周期（brainstorming/writing-plans/TDD 等）依赖它，安装方式见母库 docs/superpowers/"
    Write-Host "     human-guide.md §6。未安装时 AI 会退化为纯文本流程，质量下降。"
}

Write-Host ""
if ($MISSING_ASSETS -eq 1 -or $MISSING_TOOLS -ne 0) {
    Write-Host "❌ 未就绪：请按母库 docs/superpowers/child-repo-guide.md §3 完成接入后重试"
    Write-Host "   （在完成接入前，禁止直接进入 brainstorming 等生命周期步骤）"
    if ($MISSING_ASSETS -eq 1) { exit 1 }
    exit $MISSING_TOOLS
}
Write-Host "✅ 接入就绪：可按标准生命周期执行，运行时产物写入当前子库"
exit 0
