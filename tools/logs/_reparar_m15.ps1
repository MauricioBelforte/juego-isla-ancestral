$ck = "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION\15-Recursos\plan-actual\05-Checklist.md"
$data = "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Logs\_reparar_m15_data.txt"

$l = [System.IO.File]::ReadAllLines($ck, [System.Text.Encoding]::UTF8)
Write-Output "archivo: $($l.Count) lineas"

# Leer el archivo de datos con UTF-8 explicito (PS 5.1 lee sin BOM como cp1252)
$raw = [System.IO.File]::ReadAllText($data, [System.Text.Encoding]::UTF8)
$lineas = $raw -split "`r?`n"

$aplicadas = 0
$problemas = 0
foreach ($lin in $lineas) {
    if ($lin.Trim() -eq "") { continue }
    $tab = $lin.IndexOf("`t")
    if ($tab -le 0) { Write-Output "SKIP (sin tab): $($lin.Substring(0, [Math]::Min(50, $lin.Length)))"; continue }
    $idx = [int]($lin.Substring(0, $tab))
    $txt = $lin.Substring($tab + 1)
    if ($idx -ge $l.Count) { Write-Output "SKIP (indice fuera de rango): $idx"; $problemas++; continue }
    $ant = $l[$idx]
    if ($ant -ne $txt) {
        $l[$idx] = $txt
        $aplicadas++
    }
}
Write-Output "lineas modificadas: $aplicadas (problemas: $problemas)"

$rx=0;$rq=0;$rp=0
foreach ($x in $l) {
    if ($x -match '^\s*-\s*\[x\]') {$rx++}
    elseif ($x -match '^\s*-\s*\[\?\]') {$rq++}
    elseif ($x -match '^\s*-\s*\[ \]') {$rp++}
}
Write-Output "TOTALES: x=$rx q=$rq pend=$rp total=$($rx+$rq+$rp)"

$tmp = "$ck.tmp"
[System.IO.File]::WriteAllLines($tmp, $l, (New-Object System.Text.UTF8Encoding($false)))
[System.IO.File]::Replace($tmp, $ck, "$ck.bak")
Remove-Item -LiteralPath "$ck.bak" -Force -ErrorAction SilentlyContinue
Write-Output "reparacion aplicada"
