<#
.SYNOPSIS
    Scaffolds new projects by pulling rules directly from GitHub.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$GitHubRepo = "0mattsmith/ai-workflow-templates",

    [Parameter(Mandatory=$false)]
    [string]$Branch = "main"
)

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       REMOTE GITHUB AI WORKFLOW - PROJECT SETUP          " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Project Inputs
$projectName = Read-Host "Enter Project Name (e.g., auth-service)"
if ([string]::IsNullOrWhiteSpace($projectName)) { Write-Error "Project name required."; exit 1 }

# Set default location to User Folder > Documents > Development
$docsPath = [Environment]::GetFolderPath("MyDocuments")
$defaultPath = Join-Path -Path $docsPath -ChildPath "Development"

if (-not (Test-Path $defaultPath)) {
    New-Item -ItemType Directory -Path $defaultPath -Force | Out-Null
}

$targetParentDir = Read-Host "Enter destination directory [Default: $defaultPath]"
if ([string]::IsNullOrWhiteSpace($targetParentDir)) { $targetParentDir = $defaultPath }

$projectPath = Join-Path -Path $targetParentDir -ChildPath $projectName
if (-not (Test-Path $projectPath)) { New-Item -ItemType Directory -Path $projectPath -Force | Out-Null }

Write-Host "`nEnter your initial Project Brief / Feature Concept." -ForegroundColor Yellow
Write-Host "(Paste prompt, then type 'EOF' on a new line and press Enter):" -ForegroundColor Yellow

$briefLines = @()
while ($true) {
    $line = [Console]::ReadLine()
    if ($line -eq "EOF") { break }
    $briefLines += $line
}
$projectBrief = $briefLines -join "`n"

# 2. Directory Structure
Write-Host "`n[1/4] Creating local state directories..." -ForegroundColor Green
$folders = @(".workflow/active", ".workflow/archive", "src", "tests")
foreach ($folder in $folders) {
    $fullPath = Join-Path -Path $projectPath -ChildPath $folder
    if (-not (Test-Path $fullPath)) { New-Item -ItemType Directory -Path $fullPath -Force | Out-Null }
}

# 3. Save Brief
$initialBrief = @"
# INITIAL PROJECT BRIEF: $projectName
**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm")

## Goal & Description
$projectBrief
"@
Set-Content -Path (Join-Path $projectPath ".workflow/active/brief.md") -Value $initialBrief -Encoding utf8

# 4. Generate Dynamic Workflow Runner
Write-Host "[2/4] Generating remote-synced workflow runner (workflow.ps1)..." -ForegroundColor Green

$runnerScript = @"
[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=`$true)]
    [ValidateSet("plan", "build", "review", "archive", "status", "sync-rules", "launch-workers")]
    [string]`$Action,

    [Parameter(Position=1)]
    [string]`$PhaseName = "phase-01",

    [switch]`$Offline
)

`$root = `$PSScriptRoot
`$active = Join-Path `$root ".workflow/active"
`$archive = Join-Path `$root ".workflow/archive"
`$repoBase = "https://raw.githubusercontent.com/$GitHubRepo/$Branch/rules"

function Get-RuleContent([string]`$ruleFile) {
    if (`$Offline) {
        `$localPath = Join-Path `$root ".workflow/rules/`$ruleFile"
        if (Test-Path `$localPath) { return Get-Content `$localPath -Raw }
        Write-Error "Offline mode selected but `$localPath not found."
        exit 1
    }
    
    `$url = "`$repoBase/`$ruleFile"
    Write-Host "Fetching latest rules from GitHub (`$ruleFile)..." -ForegroundColor DarkGray
    try {
        `$headers = @{}
        if (`$env:GITHUB_TOKEN) { `$headers["Authorization"] = "token `$(`$env:GITHUB_TOKEN)" }
        return Invoke-RestMethod -Uri `$url -Headers `$headers -Method Get -TimeoutSec 10
    } catch {
        Write-Warning "Could not fetch `$ruleFile from GitHub. Falling back to cached copy if available."
        `$localPath = Join-Path `$root ".workflow/rules/`$ruleFile"
        if (Test-Path `$localPath) { return Get-Content `$localPath -Raw }
        throw `$_.Exception.Message
    }
}

switch (`$Action) {
    "plan" {
        Write-Host "=== PLANNING MODEL (Remote Ruleset Synced) ===" -ForegroundColor Cyan
        `$sys = Get-RuleContent "planning.md"
        `$inputContext = if (Test-Path "`$active/review.md") { Get-Content "`$active/review.md" -Raw } else { Get-Content "`$active/brief.md" -Raw }
        
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            claude "`$sys`n`nINPUT CONTEXT:`n`$inputContext"
        } else {
            Write-Host "System Prompt Loaded in Memory. Ready for Planner." -ForegroundColor Green
        }
    }
    "build" {
        Write-Host "=== BUILDING MODEL (Remote Ruleset Synced) ===" -ForegroundColor Cyan
        `$sys = Get-RuleContent "building.md"
        `$plan = Get-Content (Join-Path `$active "plan.md") -Raw
        
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            claude "`$sys`n`nACTIVE PLAN:`n`$plan"
        } else {
            Write-Host "System Prompt Loaded in Memory. Ready for Builder." -ForegroundColor Green
        }
    }
    "review" {
        Write-Host "=== REVIEWING MODEL (Remote Ruleset Synced) ===" -ForegroundColor Cyan
        `$sys = Get-RuleContent "reviewing.md"
        `$plan = Get-Content (Join-Path `$active "plan.md") -Raw
        `$handover = Get-Content (Join-Path `$active "handover.md") -Raw
        
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            claude "`$sys`n`nPLAN:`n`$plan`n`nHANDOVER PROOFS:`n`$handover"
        } else {
            Write-Host "System Prompt Loaded in Memory. Ready for Reviewer." -ForegroundColor Green
        }
    }
    "sync-rules" {
        Write-Host "Downloading local offline cache of rules from GitHub..." -ForegroundColor Cyan
        `$cacheDir = Join-Path `$root ".workflow/rules"
        if (-not (Test-Path `$cacheDir)) { New-Item -ItemType Directory -Path `$cacheDir -Force | Out-Null }
        @("planning.md", "building.md", "reviewing.md", "workflow.md") | ForEach-Object {
            `$content = Get-RuleContent `$_
            Set-Content -Path (Join-Path `$cacheDir `$_) -Value `$content -Encoding utf8
            Write-Host "  Cached: `$_" -ForegroundColor Green
        }
    }
    "archive" {
        `$targetArchive = Join-Path `$archive `$PhaseName
        if (-not (Test-Path `$targetArchive)) { New-Item -ItemType Directory -Path `$targetArchive -Force | Out-Null }
        Get-ChildItem -Path `$active -Filter "*.md" | ForEach-Object {
            Move-Item -Path `$_.FullName -Destination `$targetArchive -Force
        }
        Write-Host "Active workflow artifacts archived to: .workflow/archive/`$PhaseName" -ForegroundColor Green
    }
    "status" {
        Write-Host "=== Active Workflow Artifacts ===" -ForegroundColor Yellow
        Get-ChildItem -Path `$active | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
        git status --short
    }
    "launch-workers" {
        Write-Host "Spawning dedicated terminal windows for Workers..." -ForegroundColor Cyan
        Start-Process wt -ArgumentList "new-tab --title 'PLANNER' -d '`$root' powershell -NoExit -Command 'Write-Host PLANNING WORKER -ForegroundColor Cyan; .\workflow.ps1 plan'"
        Start-Process wt -ArgumentList "new-tab --title 'BUILDER' -d '`$root' powershell -NoExit -Command 'Write-Host BUILDING WORKER -ForegroundColor Green; .\workflow.ps1 build'"
        Start-Process wt -ArgumentList "new-tab --title 'REVIEWER' -d '`$root' powershell -NoExit -Command 'Write-Host REVIEWING WORKER -ForegroundColor Magenta; .\workflow.ps1 review'"
    }
}
"@

Set-Content -Path (Join-Path $projectPath "workflow.ps1") -Value $runnerScript -Encoding utf8

# 5. Git Init
Write-Host "[3/4] Initializing local Git repository..." -ForegroundColor Green
Push-Location $projectPath
try {
    if (-not (Test-Path ".git")) {
        git init --quiet
        Set-Content -Path ".gitignore" -Value "node_modules/`nbin/`nobj/`ndist/`n.env`n*.log`n.workflow/rules/" -Encoding utf8
        git add .
        git commit -m "chore: scaffold project with remote GitHub workflow runner" --quiet
        git branch -M main
    }
} finally {
    Pop-Location
}

Write-Host "[4/4] Pre-caching rules locally for offline fallback..." -ForegroundColor Green
Push-Location $projectPath
try {
    .\workflow.ps1 sync-rules
} catch {
    Write-Warning "Initial rule sync skipped. Rules will fetch live at runtime."
} finally {
    Pop-Location
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE: Rules linked to GitHub ($GitHubRepo)    " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
