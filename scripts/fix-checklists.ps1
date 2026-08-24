# Script de Correccion de Checklists
# Revierte [x] falsos a [ ] en todas las checklists

$documentacionPath = "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\DOCUMENTACION"

Write-Host "=== CORRECCION DE CHECKLISTS ===" -ForegroundColor Yellow

$filesFixed = 0
$totalReverted = 0

Get-ChildItem -Path $documentacionPath -Recurse -Filter "05-Checklist.md" | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw
    
    $xCount = ([regex]::Matches($content, '\[x\]')).Count
    
    if ($xCount -gt 0) {
        $newContent = $content -replace '\[x\]', '[ ]'
        Set-Content -Path $file -Value $newContent -NoNewline
        
        $filesFixed++
        $totalReverted += $xCount
        
        Write-Host "  Corregido: $($_.Directory.Name) ($xCount items revertidos)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Yellow
Write-Host "Archivos corregidos: $filesFixed" -ForegroundColor Green
Write-Host "Total items revertidos: $totalReverted" -ForegroundColor Green
Write-Host "Todos los items ahora estan en estado [ ] (pendiente)" -ForegroundColor Cyan