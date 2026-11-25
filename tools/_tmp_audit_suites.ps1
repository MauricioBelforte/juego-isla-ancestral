# Audita las suites de tests/ que el workflow NO ejecuta. Excluye tests/unit (GdUnit4,
# no son --script) y tests/helpers (helpers, no suites). Timeout por suite: una suite
# colgada no puede colgar la auditoria entera (ya paso con test_debug_menu.gd).
$ErrorActionPreference = 'Continue'
$repo = (Get-Location).Path
$yml = Get-Content -LiteralPath (Join-Path $repo '.github\workflows\quality.yml') -Raw
$inCi = @([regex]::Matches($yml, 'suite\s+--script\s+(\S+)') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
$g = 'D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$project = Join-Path $repo 'game/isla-ancestral'
Push-Location $project
$all = @(Get-ChildItem 'tests' -Recurse -Filter 'test_*.gd' | ForEach-Object { 'tests/' + ($_.FullName.Substring((Resolve-Path 'tests').Path.Length + 1) -replace '\\','/') })
$fuera = @($all | Where-Object { $inCi -notcontains $_ -and $_ -notlike 'tests/unit/*' -and $_ -notlike 'tests/helpers/*' })
'EN CI: ' + $inCi.Count + ' | tests/: ' + $all.Count + ' | A AUDITAR: ' + $fuera.Count
Push-Location $repo
$red = @(); $timeout = @()
foreach ($s in $fuera) {
  $jb = Start-Job -ArgumentList $g, $project, $s -ScriptBlock {
    param($g, $project, $s)
    Set-Location $project
    $o = & $g --headless --script $s 2>&1
    [pscustomobject]@{ code = $LASTEXITCODE; lines = @($o | ForEach-Object { [string]$_ }) }
  }
  if (-not (Wait-Job $jb -Timeout 120)) {
    Stop-Job $jb -ErrorAction SilentlyContinue; Remove-Job $jb -Force -ErrorAction SilentlyContinue
    $timeout += $s; 'TIMEOUT ' + $s; continue
  }
  $res = Receive-Job $jb; Remove-Job $jb -Force -ErrorAction SilentlyContinue
  if ($res.code -ne 0) {
    $det = @($res.lines | Select-String -Pattern 'FALLO:|\[FAIL\]|Resumen' | Select-Object -Last 2)
    $red += $s; 'RED ' + $s + ' :: ' + ($det -join ' | ')
  }
}
'=== RESULTADO: ' + $fuera.Count + ' suites | rojas: ' + $red.Count + ' | timeouts: ' + $timeout.Count + ' ==='