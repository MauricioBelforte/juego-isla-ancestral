$dirs = @('69-Fast-Travel','131-Creditos','104-Analytics','118-CI-CD')
foreach ($d in $dirs) {
    $src = "DOCUMENTACION/$d/plan-inicial"
    $dst = "DOCUMENTACION/$d/plan-actual"
    if (!(Test-Path $dst)) { New-Item -ItemType Directory -Path $dst -Force | Out-Null }
    Copy-Item -Path "$src/*" -Destination $dst -Force
    Write-Output "Synced: $d"
}