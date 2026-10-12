# 12 — Solución de Problemas Comunes (Troubleshooting)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11
**Encargo:** Director mimo-v2.6 (msg 44) — ítem "Documentar solución de problemas comunes" (anteriormente `[?]`, dueño Hy3)

## Scripts del sistema de backups

| Script | Parámetros | Función |
|---|---|---|
| `scripts/backup/backup_local.ps1` | `-SourcePath`, `-DestinationPath`, `-Kind`, `-RetentionCount`, `-NoSaves` | Backup local a disco externo (zip + SHA-256 + retención) |
| `scripts/backup/verify_backups.ps1` | `-BackupDir`, `-Latest` | Verificación de integridad (SHA-256 vs `checksums.txt`) |
| `scripts/backup/restore_backup.ps1` | `-BackupFile`, `-DestinationPath`, `-RestoreSaves`, `-Force` | Restauración de un backup |
| `scripts/backup/register_task.ps1` | `-Time`, `-DestinationPath`, `-Force` | Registro en Windows Task Scheduler |
| `BackupManager` (in-engine) | — | `crear_backup`, `restaurar`, `verificar_integridad` (CRC32), `verificar_categoria`, `listar_backups` |

## Problemas y soluciones

### 1. `backup_local.ps1` falla: "disco externo no conectado"
- **Causa:** el script verifica la conexión del disco (03-Diseno.md §3, paso 2) antes de comprimir.
- **Solución:** conectar el disco externo y re-ejecutar. Verificar la letra de unidad en `-DestinationPath` (por defecto `E:\Backups\juego-isla-ancestral\`). Si la letra cambió, pasar `-DestinationPath` explícito.

### 2. `verify_backups.ps1` reporta checksum mismatch
- **Causa:** el backup está corrupto (transferencia interrumpida, disco defectuoso).
- **Solución:** no usar ese backup; restaurar desde otra rotación (`restore_backup.ps1` con otro `-BackupFile`) o re-generar el backup con `backup_local.ps1`.

### 3. `checksums.txt` faltante en el disco externo
- **Causa:** backup generado sin checksums o borrado manualmente.
- **Solución:** re-ejecutar `backup_local.ps1` (regenera `checksums.txt` junto al zip).

### 4. `restore_backup.ps1` falla al restaurar
- **Causa:** destino ocupado o archivos existentes.
- **Solución:** usar `-Force` para sobrescribir; `-RestoreSaves` para incluye saves; verificar `-DestinationPath` con espacio suficiente.

### 5. Task Scheduler no ejecuta `backup_local.ps1`
- **Causa:** tarea no registrada o sin permisos.
- **Solución:** registrar con `register_task.ps1 -Time "03:00" -DestinationPath "E:\Backups\juego-isla-ancestral" -Force`. Verificar que la cuenta de usuario tenga permisos y acceso al disco externo (04-Codigo.md §7).

### 6. `.github/workflows/backup.yml` falla en rclone / Google Drive
- **Causa:** secrets no configurados (`GDRIVE_CLIENT_ID`, `GDRIVE_CLIENT_SECRET`, `GDRIVE_TOKEN`).
- **Solución:** configurar OAuth en Google Cloud Console y agregar los secrets al repositorio (04-Codigo.md §6). **Requiere cuenta de Google del usuario** — fuera de alcance de agentes.

### 7. `BackupManager` (in-engine): "categoría inexistente"
- **Causa:** `verificar_categoria()` retorna Array vacío para categorías no registradas.
- **Solución:** usar las 7 categorías de `game/data/backup/backup_categories.json` (repositorio, saves, musica, assets, fuente, documentacion, builds).

### 8. Backup corrupto no restaura (in-engine)
- **Causa:** `restaurar()` verifica integridad (CRC32) antes de restaurar y rechaza backups corruptos.
- **Solución:** usar un backup anterior (`listar_backups()` muestra `{nombre, mtime, integridad}`).

### 9. Disco externo lleno / retención
- **Causa:** se superó la retención configurada.
- **Solución:** `backup_local.ps1` mantiene los últimos `-RetentionCount` (por defecto 10); la política de retención (30 días diarios / 12 meses semanales / 5 años mensuales) está en `08-Politica-Retencion.md` y `backup_policy.json`.

### 10. Saves no se respaldan
- **Causa:** `save_backup.gd` (integración M59) rota slots; `-NoSaves` excluye saves del backup local.
- **Solución:** verificar `user://saves/`; no usar `-NoSaves` si se requieren saves en el backup local; el `BackupManager` respalda saves en `user://backups/` por categoría.

## Nota

Los ítems de disco externo físico, Google Cloud Console, Drive API y OAuth permanecen `[?]` en el checklist: requieren hardware/cuenta de usuario y no son verificables headless (dueño: usuario).
