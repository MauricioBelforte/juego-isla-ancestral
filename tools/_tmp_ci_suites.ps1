# Re-corre exactamente las suites registradas en quality.yml (el job Test Suite).
$ErrorActionPreference = 'Continue'
$repo = (Get-Location).Path
$yml = Get-Content -LiteralPath (Join-Path $repo '.github\workflows\quality.yml') -Raw
$suites = @([regex]::Matches($yml, 'suite\s+--script\s+(\S+)') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
$g = 'D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
Push-Location (Join-Path $repo 'game/isla-ancestral')
'SUITES EN EL WORKFLOW: ' + $suites.Count
$red = @()
foreach ($s in $suites) {
  $o = & $g --headless --script $s 2>&1
  if ($LASTEXITCODE -ne 0) {
    $det = @($o | Select-String -Pattern 'FALLO:|\[FAIL\]|Resumen' | Select-Object -Last 2)
    $red += $s; 'RED ' + $s + ' :: ' + ($det -join ' | ')
  }
}
Pop-Location
'=== CI LOCAL: ' + $suites.Count + ' suites | rojas: ' + $red.Count + ' ==='