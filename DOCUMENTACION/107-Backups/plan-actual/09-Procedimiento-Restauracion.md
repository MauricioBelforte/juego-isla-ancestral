# 09 — Procedimiento de Restauración (M107)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09

## Herramientas

| Herramienta | Ruta | Uso |
|---|---|---|
| `restore_backup.ps1` | `scripts/backup/restore_backup.ps1` (148 l) | Restaurar .tar.gz local + saves |
| `backup_manager.gd` | `game/isla-ancestral/scripts/backup/backup_manager.gd` | `restaurar()` / `restaurar_categoria()` in-engine |
| `verify_backups.ps1` | `scripts/backup/verify_backups.ps1` (104 l) | Verificar integridad ANTES de restaurar |

## Procedimiento

### 1. Verificar integridad (siempre primero)

```powershell
.\verify_backups.ps1 -BackupDir "D:\Backups\juego-isla-ancestral"
```

- Salida: `OK` / `CORRUPTO` / `FALTANTE` por archivo.
- Si hay corruptos → NO restaurar. Buscar backup anterior.

### 2. Restaurar backup local (Windows)

```powershell
.\restore_backup.ps1 -BackupFile "D:\Backups\juego-isla-ancestral\backup_2026-10-09_03-00-00.tar.gz" -DestinationPath "D:\Restore\juego-isla-ancestral"
```

- **Nunca restaurar sobre la raíz del proyecto en uso.**
- Para restaurar saves del juego: agregar `-RestoreSaves` (sobrescribe `%APPDATA%\Godot\app_userdata\<proyecto>`).
- `-Force` permite sobrescribir saves existentes.

### 3. Restaurar in-engine (Godot)

```gdscript
# backup_manager.gd
var ok := backup_manager.restaurar("user://backups/backup_2026-10-09.tar.gz", "user://restore/")
# o por categoría:
var ok2 := backup_manager.restaurar_categoria("saves", "user://restore/saves/")
```

- `restaurar()` descomprime y verifica checksum SHA-256.
- `restaurar_categoria()` restaura solo una categoría de `backup_categories.json`.

### 4. Verificar post-restauración

1. `git status` + `git log --oneline -5` → repositorio íntegro.
2. Abrir proyecto en Godot → assets importan sin errores.
3. Ejecutar `test_backup_m107.gd` headless → 28/0.
4. Comprobar saves en `%APPDATA%\Godot\app_userdata\` (si aplica).

## Frecuencia de prueba

- **Mensual** (primer día de cada mes): restaurar un backup aleatorio de los últimos 30 días.
- Documentar resultado en la plantilla de log (ver `10-Plantilla-Log-Restauracion.md`).

## Criterio de éxito

- Restauración 100% exitosa.
- Todos los archivos verifican con checksums.
- Proyecto compila y ejecuta sin errores en Godot Console.
