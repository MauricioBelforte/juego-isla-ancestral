$ErrorActionPreference = 'Continue'
$repo = (Get-Location).Path
$ymlPath = Join-Path $repo '.github\workflows\quality.yml'
$yml = Get-Content -LiteralPath $ymlPath -Raw
$inCi = @([regex]::Matches($yml, 'suite\s+--script\s+(\S+)') | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
$g = 'D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
Push-Location 'game/isla-ancestral'
$all = @(Get-ChildItem 'tests' -Recurse -Filter 'test_*.gd' | ForEach-Object { 'tests/' + ($_.FullName.Substring((Resolve-Path 'tests').Path.Length + 1) -replace '\\','/') })
$fuera = @($all | Where-Object { $inCi -notcontains $_ })
'EN CI: ' + $inCi.Count + '  |  tests/: ' + $all.Count + '  |  FUERA DE CI: ' + $fuera.Count
$fails = @()
foreach ($s in $fuera) {
  $o = & $g --headless --script $s 2>&1
  if ($LASTEXITCODE -ne 0) {
    $det = @($o | Select-String -Pattern 'FALLO:|\[FAIL\]|Resumen' | Select-Object -Last 2)
    $fails += $s
    'RED ' + $s + ' :: ' + ($det -join ' | ')
  }
}
Pop-Location
'=== RESULTADO: ' + $fuera.Count + ' suites, ' + $fails.Count + ' rojas ==='