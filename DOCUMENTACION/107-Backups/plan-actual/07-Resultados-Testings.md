# 07 — Resultados de Testings

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11
**Encargo:** Director mimo-v2.6 (msg 43, opción 2) — `07-Resultados-Testings.md` pendiente (recomendado por auditoría F5, checklist L336-337/L350)

## Entorno

- Motor: Godot 4.7.2 headless (`C:\Temp\godot\godot472.exe`)
- SO: Windows 11
- Comando: `godot --headless --path game/isla-ancestral --script <suite>`
- Corridas: 2026-10-11 18:33–18:37 (UTC-3), re-corridas vivas por Ling-3.1-Flash

## Suites y resultados

| # | Suite | Archivo | Checks | Fallos | Exit |
|---|-------|---------|--------|--------|------|
| 1 | Backups principal (RF1-RF15) | `scripts/backup/test_backup_m107.gd` | 28 | 0 | 0 |
| 2 | `rotate()` reporta fallos de rename (BUG-112) | `scripts/saving/test_backup_rotate_return.gd` | 4 | 0 | 0 |
| 3 | Recuperación prueba TODAS las rotaciones (BUG-110) | `scripts/saving/test_backup_rotations.gd` | 7 | 0 | 0 |
| **Total** | 3 suites | | **39** | **0** | **0** |

## Detalle por suite

### 1. `test_backup_m107.gd` — 28 checks, 0 fallos, EXIT 0

Autor: mimo-v2.5 (2026-09-19). Valida `BackupManager` contra RF1-RF15: autoload
presente, retención máx 5 copias, checksum habilitado, categorías RF1-RF8
(repositorio/saves/musica/assets/fuente/documentacion/builds + inexistente → vacío),
backup creado, integridad verificada, restauración, backup corrupto no restaura,
`verificar_categoria()`, manifest (Array, lista el backup, entry con
`integridad=true`), cantidades (int, >= 0).

Evolución del conteo documentada en el checklist: 9/0 → 12/0 (agnes-3-flash,
`listar_backups`) → 28/0 (actual).

### 2. `test_backup_rotate_return.gd` — 4 checks, 0 fallos, EXIT 0

Autor: DeepSeek-V4.1-Flash (WorkBuddy, 2026-10-06, Cola M59 / BUG-112).
`rotate()` debe reportar fallos de `DirAccess.rename_absolute` (antes descartaba
el retorno y dejaba rotación parcial en silencio). **RED por inyección:** si
`rotate()` vuelve a devolver siempre `true`, el caso C falla. Slot aislado 98.
El ERROR del log (`rotate: no se pudo rotar user://saves/slot_98.save`) es el
**caso de fallo intencional** que verifica el reporte.

### 3. `test_backup_rotations.gd` — 7 checks, 0 fallos, EXIT 0

Autor: DeepSeek-V4.1-Flash (WorkBuddy, 2026-10-06, Cola M59 / BUG-110).
La recuperación debe probar TODAS las rotaciones (r1, r2…) en orden de frescura
(antes `read_latest_backup()` leía solo r1: r2 era un backup muerto). **RED por
inyección:** si el bucle se limita a r1 (`range(1, 2)`), los casos B y C fallan.
Slot aislado 97. Los ERROR del log (`No hay backup válido para slot 97`) son
**casos de fallo intencionales**.

## Observaciones

- Los ERROR/WARNING del log son casos de fallo **intencionales** (origen inexistente,
  rotación fallida, slot sin backup): los tests verifican el manejo del fallo, no
  que no ocurra.
- **BUG-121 (agnes-3-flash, 2026-10-08):** los SCRIPT ERROR "instantiate" sobre
  null del autoload de fauna (M30) no afectan los checks de M107. Fix = null-guard
  en M30 (dueño: director).
- **Observación transitoria (no reproductible):** 3 corridas a las 18:33 mostraron
  parse error en el autoload `accesibilidad_manager.gd` (M58); desapareció a las
  18:37 sin cambios en disco (escritura concurrente de otra sesión). No afecta M107.
  Reportado al director en msg 44.
- `06-Plan-Testings.md` sigue ausente (recomendable, §14).

## Conclusión

Las 3 suites pasan con **39 checks, 0 fallos, exit 0** en corridas vivas
(2026-10-11). Los criterios de aceptación (checklist L235) quedan sustentados
por evidencia reproducible. El módulo mantiene 25 `[?]` user-dependent (disco
externo, cuenta de usuario) que solo el usuario puede validar — no es sellable
hasta esa validación.
