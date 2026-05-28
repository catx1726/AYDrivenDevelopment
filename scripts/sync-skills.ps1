# Sync skills from platform-agnostic directory to platform-specific directories
# Skills are organized under skills/<category>/ but flattened at the target.
# Usage: .\scripts\sync-skills.ps1

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$SourceDir = Join-Path $ProjectRoot "skills"

# Target directories for different AI CLI platforms
$Targets = @(
    (Join-Path $ProjectRoot ".gemini" "skills")
)

Write-Host "🔄 Syncing skills from ${SourceDir}..."

foreach ($target in $Targets) {
    $parent = Split-Path -Parent $target
    if (Test-Path $parent) {
        if (-not (Test-Path $target)) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        } else {
            Remove-Item -Path "$target\*" -Recurse -Force -ErrorAction SilentlyContinue
        }

        # Flatten: copy contents from all subdirectories in skills/
        $categoryDirs = Get-ChildItem -Path $SourceDir -Directory -ErrorAction SilentlyContinue
        foreach ($catDir in $categoryDirs) {
            $items = Get-ChildItem -Path $catDir.FullName
            foreach ($item in $items) {
                $dest = Join-Path $target $item.Name
                if ($item.PSIsContainer) {
                    Copy-Item -Path $item.FullName -Destination $dest -Recurse -Force
                } else {
                    Copy-Item -Path $item.FullName -Destination $dest -Force
                }
            }
        }
        Write-Host "✅ Synced to ${target}"
    } else {
        Write-Host "⏭️  Skipped ${target} (parent directory does not exist)"
    }
}

Write-Host "🎉 Skills sync complete."
