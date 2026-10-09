# 10 — Plantilla de Log de Restauración (M107)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09

## Plantilla

```markdown
# Log de Restauración {YYYY-MM-DD}

**Fecha:** YYYY-MM-DD HH:MM
**Backup restaurado:** {nombre del archivo .tar.gz}
**Destino:** {carpeta de restauración}
**Herramienta:** {restore_backup.ps1 | backup_manager.restaurar()}
**Ejecutado por:** {usuario/agente}

## Resultado

- [ ] Checksums verificados (antes de restaurar)
- [ ] Restauración completada sin errores
- [ ] Repitorio Git íntegro (git status + git log)
- [ ] Assets importados en Godot sin errores
- [ ] Saves restaurados (si aplica)
- [ ] Test headless `test_backup_m107.gd` → 28/0

## Anomalías

{Describir cualquier anomalía encontrada. Si no hay, escribir "Ninguna."}

## Acción correctiva

{Si hubo anomalía, qué se hizo. Si no, "N/A."}
```

## Reglas

- Guardar en `DOCUMENTACION/107-Backups/plan-actual/logs-restauracion/` (crear carpeta si no existe).
- Un log por restauración. Nunca sobrescribir.
- Si la restauración falla, documentar la causa y no reintentar sin diagnóstico.
