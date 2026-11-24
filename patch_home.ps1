# patch_home.ps1
# Moves the Dashboard tab to the FIRST position in Home (and opens the app on it).
# Run from the project root:
#   powershell -ExecutionPolicy Bypass -File .\patch_home.ps1
# Nothing is written unless every change can be applied safely.

$ErrorActionPreference = 'Stop'
$root   = (Get-Location).Path
$ctrl   = Join-Path $root 'lib\features\home\presentation\controllers\home_controller.dart'
$screen = Join-Path $root 'lib\features\home\presentation\screens\home_screen.dart'
$utf8   = New-Object System.Text.UTF8Encoding($false)

function Fail([string]$msg) {
    Write-Host ""
    Write-Host "FAILED: $msg" -ForegroundColor Red
    Write-Host "Nothing was changed. Send me the content of home_controller.dart and home_screen.dart and I will fix it." -ForegroundColor Yellow
    exit 1
}

foreach ($f in @($ctrl, $screen)) {
    if (-not (Test-Path $f)) { Fail "file not found: $f (run this from the project root, e.g. D:\hom\flutter\H3\rental_project)" }
}

# ------------------------------------------------------------------ home_controller.dart
$c = [System.IO.File]::ReadAllText($ctrl)

if ($c -match "titleKeys\s*=\s*\[\s*'dashboard'") { Fail "home_controller.dart already has Dashboard first (already patched)." }
if ($c -notmatch "titleKeys\s*=\s*\[[^\]]*'dashboard'") { Fail "home_controller.dart: 'dashboard' is not in titleKeys. Add the Dashboard tab first (see previous instructions)." }
if ($c -notmatch 'addKeys\s*=\s*\[') { Fail "home_controller.dart: addKeys list not found." }
if ($c -notmatch 'case\s+\d+\s*:') { Fail "home_controller.dart: onAdd() switch cases not found." }

$c = [regex]::Replace($c, 'titleKeys\s*=\s*\[[^\]]*\]', "titleKeys = ['dashboard', 'units', 'tenants', 'contracts', 'finance']")
$c = [regex]::Replace($c, 'addKeys\s*=\s*\[[^\]]*\]', "addKeys = ['', 'add_unit', 'add_tenant', 'add_contract', 'add_payment']")
$shift = [System.Text.RegularExpressions.MatchEvaluator]{ param($m) 'case ' + ([int]$m.Groups[1].Value + 1) + ':' }
$c = [regex]::Replace($c, 'case\s+(\d+)\s*:', $shift)

# ------------------------------------------------------------------ home_screen.dart
$s = [System.IO.File]::ReadAllText($screen)

# 1) IndexedStack children: DashboardScreen() first
$m = [regex]::Match($s, 'children:\s*(const\s*)?\[([^\]]*DashboardScreen\(\)[^\]]*)\]')
if (-not $m.Success) { Fail "home_screen.dart: IndexedStack children list with DashboardScreen() not found." }
$items = @(($m.Groups[2].Value -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' -and $_ -ne 'DashboardScreen()' })
$newChildren = 'children: ' + $m.Groups[1].Value + '[DashboardScreen(), ' + ($items -join ', ') + ']'
$s = $s.Replace($m.Value, $newChildren)

# 2) NavigationDestination of the dashboard: move to the start of destinations
$destPattern = "NavigationDestination\(\s*icon:\s*(const\s+)?Icon\(\s*Icons\.dashboard\s*\)\s*,\s*label:\s*'dashboard'\.tr\s*,?\s*\)\s*,?"
$dm = [regex]::Match($s, $destPattern)
if (-not $dm.Success) { Fail "home_screen.dart: the Dashboard NavigationDestination was not found." }
$destText = $dm.Value.Trim().TrimEnd(',') + ','
$s = $s.Remove($dm.Index, $dm.Length)
$destStart = [regex]'destinations:\s*\['
if (-not $destStart.IsMatch($s)) { Fail "home_screen.dart: 'destinations: [' not found." }
$s = $destStart.Replace($s, ('destinations: [' + "`n              " + $destText), 1)

# 3) floating button hidden on the Dashboard tab (index 0 instead of 4)
$fm = [regex]::Match($s, '\b(\w+)\s*==\s*4\s*\?\s*null')
if (-not $fm.Success) { Fail "home_screen.dart: the floating button condition (i == 4 ? null) was not found." }
$s = $s.Replace($fm.Value, ($fm.Groups[1].Value + ' == 0 ? null'))

# ------------------------------------------------------------------ write
[System.IO.File]::WriteAllText($ctrl, $c, $utf8)
[System.IO.File]::WriteAllText($screen, $s, $utf8)
Write-Host ""
Write-Host "Done. Dashboard is now the first tab." -ForegroundColor Green
Write-Host "Next: flutter run" -ForegroundColor Green
