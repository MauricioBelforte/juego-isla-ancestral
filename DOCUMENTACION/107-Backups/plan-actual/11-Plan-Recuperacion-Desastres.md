# 11 — Plan de Recuperación de Desastres (M107)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09

> Extiende `03-Diseno.md` §10 con pasos reales y herramientas del proyecto.

## Escenario 1: Pérdida de Máquina Local

**Severidad:** Media · **Tiempo:** 2-4 h

### Pasos
1. Adquirir/reinstalar sistema operativo.
2. Instalar: Git, Godot 4.7.2+, PowerShell 5.1+, Python 3+.
3. `git clone https://github.com/MauricioBelforte/juego-isla-ancestral.git`
4. `git lfs pull` (assets grandes).
5. Restaurar saves de prueba desde `D:\Backups\juego-isla-ancestral\` (si disco externo disponible) o Google Drive.
6. Verificar: `godot --headless --path game/isla-ancestral --check-only` → 0 errores.
7. Ejecutar `test_backup_m107.gd` → 28/0.

### Verificación
- [ ] Repositorio clonado
- [ ] Assets LFS restaurados
- [ ] Proyecto compila (0 errores Godot)
- [ ] Proyecto ejecuta
- [ ] Saves recuperados

## Escenario 2: Corrupción de Repositorio Git

**Severidad:** Alta · **Tiempo:** 4-8 h

### Pasos
1. Identificar punto de corrupción (`git fsck`, `git status`).
2. Restaurar desde `backup_local.ps1` más reciente en `D:\Backups\juego-isla-ancestral\`:
   ```powershell
   .\restore_backup.ps1 -BackupFile "D:\Backups\juego-isla-ancestral\backup_YYYY-MM-DD_HH-MM-SS.tar.gz" -DestinationPath "D:\Restore\juego-isla-ancestral"
   ```
3. Verificar integridad: `verify_backups.ps1 -BackupDir "D:\Backups\juego-isla-ancestral"`.
4. Crear repositorio limpio: `git init` + restaurar historial desde backup.
5. Verificar branches y tags.
6. `git remote add origin <url>` + `git push --mirror origin`.

### Verificación
- [ ] Backup recuperado
- [ ] Checksums OK
- [ ] Historial completo
- [ ] Branches + tags existen
- [ ] Push a GitHub exitoso

## Escenario 3: Pérdida de GitHub (Catastrófico)

**Severidad:** Crítica · **Tiempo:** 8-24 h

### Pasos
1. Evaluar: ¿GitHub caído (temporal) o cuenta comprometida (permanente)?
2. **Temporal:** esperar recuperación, verificar integridad.
3. **Permanente:**
   a. Restaurar código desde Google Drive: `rclone copy gdrive:isla-ancestral-backups/diario/ D:\Restore\`.
   b. Restaurar assets desde disco externo: `D:\Backups\juego-isla-ancestral\assets_originales\`.
   c. Crear repositorio nuevo en GitHub/GitLab.
   d. `git init` + restaurar historial + `git push --mirror`.
   e. Configurar Git LFS en nuevo remoto.
   f. Actualizar URLs en todos los clones locales.
   g. Verificar acceso de colaboradores.
   h. Reconfigurar CI/CD (GitHub Actions → nuevo remoto).

### Verificación
- [ ] Código recuperado
- [ ] Historial completo
- [ ] Assets recuperados
- [ ] Colaboradores con acceso
- [ ] CI/CD reconfigurado
- [ ] Git LFS funcional

## Escenario 4: Pérdida de Assets Originales

**Severidad:** Alta · **Tiempo:** 4-12 h

### Pasos
1. Identificar assets perdidos (comparar `assets/3d/{media,baja}` contra `backup_categories.json` categoría `assets`).
2. Restaurar desde Git LFS: `git lfs pull`.
3. Si LFS no cubre: restaurar desde Google Drive `assets/` o disco externo `assets_originales/`.
4. Verificar con `asset_validator.gd` headless:
   ```
   godot --headless --path game/isla-ancestral --script res://tools/asset_validator.gd
   ```
   → 0 errores.
5. Reimportar en Godot: `godot --headless --path game/isla-ancestral --import`.
6. Ejecutar `test_asset_validator_m108.gd` → 0 fallos.
7. Si hay corrupción irreparable: reconstruir desde fuentes DAW (Google Drive `musica/proyectos_daw/`).

### Verificación
- [ ] Assets recuperados
- [ ] Godot importa correctamente
- [ ] `asset_validator.gd` → 0 errores
- [ ] Builds funcionan
- [ ] Sin corrupción residual

## Herramientas de verificación

| Herramienta | Uso |
|---|---|
| `verify_backups.ps1` | Checksums SHA-256 antes de cualquier restauración |
| `asset_validator.gd` | Validación de assets post-restauración (198 GLB) |
| `test_backup_m107.gd` | Suite 28/0 headless |
| `backup_manager.verificar_integridad()` | CRC32 in-engine |

## Contacto / Escalación

- **M107 (Backups):** dueño del módulo.
- **M133 (Gestión):** coordinación inter-módulo.
- **M135 (Riesgos):** registro formal del incidente.
