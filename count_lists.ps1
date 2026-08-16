$mods = @('69-Fast-Travel','131-Creditos','104-Analytics','118-CI-CD')
$total_global = 0
foreach ($m in $mods) {
  $f = "DOCUMENTACION/$m/plan-inicial/05-Checklist.md"
  if (Test-Path $f) {
    $lines = Get-Content $f
    $items = $lines | Where-Object { $_ -match '^\s*-\s*\[[xX\? ]\s*\]\s' }
    $total = $items.Count
    $x = ($items | Where-Object { $_ -match '^\s*-\s*\[x\]\s' }).Count
    $sp = ($items | Where-Object { $_ -match '^\s*-\s*\[\s\]\s' }).Count
    $q = ($items | Where-Object { $_ -match '^\s*-\s*\[\?\]\s' }).Count
    Write-Output ("{0} total={1} x={2} pend={3} ?={4} faltan={5}" -f $m, $total, $x, $sp, $q, [Math]::Max(0, 100-$total))
    $total_global += $total
  }
}
Write-Output ("TOTAL global = $total_global (debe ser >= 400)")