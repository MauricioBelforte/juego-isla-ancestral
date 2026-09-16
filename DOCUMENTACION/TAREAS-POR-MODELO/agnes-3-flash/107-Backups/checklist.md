**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code

**Módulo:** 107-Backups (107)

# Checklist personal tareas — 107-Backups

> Fuente: 176 `[ ]` del `05-Checklist.md` (revertido a 0/176 por auditoría 2026-09-14). El "Totales"
> decía 137/137 = **sobre-cierre**. **Iter. agnes (Log 927, 2026-09-16):** verifiqué el estado real +
> agregué el método de audit. M107 **🟡 Liberado (iter. agnes)**.

## Tareas (estado tras iter. agnes)

### Cerradas / verificadas en iter. agnes (Log 927)
- [x] T-001 Verificar estado real: infra PS **4 scripts** (`scripts/backup/`) + `backup.yml` (UTF-8 OK) + in-engine `backup_manager` + `backup_policy.json`
- [x] T-002 **`listar_backups()`** (audit/manifest `[{nombre,mtime,integridad}]`) — método del ítem "verificación de integridad/registro de backups" que faltaba. Additive.
- [x] T-003 Extender `test_backup_m107.gd` (bloque `_test_audit`, 3 checks) → **12/0, 0 `SCRIPT ERROR`**
- [x] T-004 Reconciliar sobre-cierre del `Totales` (137/137 → real 176 `[ ]`) + "Notas del Agente"

### `[?]` con dueño (NO lo hago: integrações reales / secretos / hardware)
- [?] T-005 Integrações M59 (guardado) / M122 (crash) / M133 (logs) / M135 (riesgos) / M97 (Steam) → **dueño del módulo**
- [?] T-006 Google Drive: secrets `GDRIVE_*` + credenciales OAuth → **usuario** (el workflow ya tiene guard: sin secrets salta la subida, no rompe el pipeline)
- [?] T-007 Copia 3 disco externo `D:\Backups\` → **usuario** (máquina sin disco externo conectado)

## Verificación
- `godot --headless --script res://scripts/backup/test_backup_m107.gd` → **12/0**, 0 `SCRIPT ERROR`
- Nota §28.1: el "mojibake" de `backup.yml` era artefacto de PowerShell 5.1; **no** se reescribió (es UTF-8 válido).
