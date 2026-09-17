# Propuestas de Fix — Auditoría acompañante agnes-2.5-flash (hy3)

**Fecha:** 2026-09-14 · **Rol:** supervisor/QA (§21.4 verify-only). Estas propuestas NO se aplican solas:
quien tenga el módulo reasignado (o el dueño) las aplica. Son diffs listos.

> ⚠️ **Estado corregido respecto al primer informe:** la auditoría 2026-09-14 (stepfun/SWE) YA
> revirtió los marcadores `[x]→[ ]` de los módulos que había flagueado (M72/M78/M83/M84/M107/M110/
> M126/M128/M150/M155) **y también M54**. Hoy esos módulos dicen `[ ]`. El código de los que probé
> (M72/M78/M84/M126/M128/M150) SIGUE PASANDO tests headless → funcionales, solo faltan re-marcar `[x]`
> lo verificado. Los únicos defectos de CÓDIGO reales que quedan son BUG-035/036/037; el BUG-038 es de
> documentación (BOM).

## BUG-035 — M107 Backups: `cantidad_backups() >= 1` falla (devuelve 0)

**Síntoma:** test `scripts/backup/test_backup_m107.gd` → `=== Resumen M107: 9 checks, 1 fallos ===`,
falla el check `cantidad backups >= 1` (línea 56). `crear_backup()` crea el archivo (el check "backup
creado" pasa) pero `cantidad_backups()` cuenta 0.

**Causa raíz** (`scripts/backup/backup_manager.gd`):
- Línea 46 crea el directorio con `DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR_BACKUP))`
  (ruta **globalizada/absoluta**), pero `crear_backup` (línea 47-48) y `cantidad_backups` (línea 91)
  usan `DIR_BACKUP` = `"user://backups/"` **directo**.
- Bajo `--path game/isla-ancestral`, `user://` resuelve a `game/isla-ancestral/Godot/backups/` (ver
  memoria del proyecto: `globalize_path("user://")` da ruta relativa y `user://` real es `Godot/`). El
  `make_dir_recursive_absolute(globalize_path(...))` crea el dir en un lugar distinto al que luego
  lee `cantidad_backups` → devuelve 0.

**Propuesta de fix (unificar a `user://`):**
```diff
  func crear_backup(ruta_origen: String, nombre: String) -> String:
  	if not FileAccess.file_exists(ruta_origen):
  		push_warning("[M107] Origen no existe: %s" % ruta_origen)
  		return ""
- 	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR_BACKUP))
+ 	DirAccess.make_dir_recursive(DIR_BACKUP)
  	var ruta_backup := "%s%s" % [DIR_BACKUP, nombre]
```
`DirAccess.make_dir_recursive` resuelve `user://` igual que `copy_absolute`/`DirAccess.open`, dejando
creación y lectura en la misma carpeta. (Mantener `copy_absolute` y `DirAccess.open(DIR_BACKUP)` tal cual.)

**Verificación:** re-correr `godot --headless --path game/isla-ancestral --script res://scripts/backup/test_backup_m107.gd`
→ debe dar `TEST M107 OK — 0 fallos`. Hy3 puede hacerlo si se reasigna M107.

---

## BUG-036 — M83 Licencias: test no compila (Godot 4.7 API drift)

**Síntoma:** `godot --headless ... --script res://scripts/legal/test_licenses_m83.gd` →
`SCRIPT ERROR: Parse Error: Cannot find member "hash" in base "PackedByteArray"` /
`Function "hash()" not found in base PackedByteArray` → "Failed to load script".

**Causa raíz** (`scripts/legal/license_validator.gd`, línea 145):
```gdscript
var actual_hash := String(data.hash())
```
`data` es `PackedByteArray` (de `file_access.get_buffer()`). En Godot 4.7 `PackedByteArray.hash()`
fue eliminado; la función global `hash()` acepta un Variant (incl. `PackedByteArray`) y devuelve `int`.

**Propuesta de fix:**
```diff
- 	var actual_hash := String(data.hash())
+ 	var actual_hash := String(hash(data))
```
Aplica también si hay otros `.hash()` sobre `PackedByteArray` en el módulo (solo este en `license_validator.gd`).

**Verificación:** re-correr el test de M83 → `TEST M83 OK` (debe dar 9 checks, 0 fallos).

---

## BUG-037 — M110 DebugMenu: test no compila (inferencia de tipos Godot 4.7)

**Síntoma:** `godot --headless ... --script res://scripts/debug/test_debug_menu_headless.gd` →
14× `SCRIPT ERROR: Parse Error: Cannot infer the type of "r1".."r9" variable because the value
doesn't have a set type` → exit 1.

**Causa raíz** (`scripts/debug/test_debug_menu_headless.gd`): `_menu` se declara `var _menu: Node = null`
(línea 13, tipado `Node`), así que `_menu.teleport_player(...)` etc. devuelven `Variant`. Las asignaciones
`var rN := <Variant>` no pueden inferir tipo → error de compilación.

**Propuesta de fix (usar `=` en lugar de `:=` para las variables que vienen de `_menu`):**
```diff
- 	var r1 := _menu.teleport_player(Vector3(256.0, 30.0, 256.0))
+ 	var r1 = _menu.teleport_player(Vector3(256.0, 30.0, 256.0))
- 	var r2 := _menu.set_game_time(12)
+ 	var r2 = _menu.set_game_time(12)
   ... (ídem r3, r5, r6, r7, r8, r9, r10 y las variantes _tp_center/_time_6/_weather_soleado)
- 	var lines := _menu.console_get_lines()
+ 	var lines = _menu.console_get_lines()
- 	var met := _menu.metricas_sistema()
+ 	var met = _menu.metricas_sistema()
```
Atajo seguro: en ese archivo, reemplazar TODOS los `:=` por `=` (las asignaciones de tipos concretos
como `var total_txt := 0` siguen funcionando como Variant inicializado). No cambia la lógica.

**Verificación:** re-correr el test de M110 → debe listar checks y `quit(0)`.

---

## BUG-038 — BOM en checklists de M54 y M84 (viola §28 UTF-8 sin BOM)

**Síntoma:** `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md` y
`DOCUMENTACION/84-Musica-Y-Audio-Legal/plan-actual/05-Checklist.md` empiezan con bytes `EF BB BF`.
La regla §28 (y el propio backlog de agnes) exige UTF-8 SIN BOM. Irónico: agnes lo prohibió en su backlog.

**Propuesta de fix (quitar BOM, preservando el contenido UTF-8):**
```bash
# con el python gestionado del proyecto
python - <<'PY'
for f in ["DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md",
          "DOCUMENTACION/84-Musica-Y-Audio-Legal/plan-actual/05-Checklist.md"]:
    b = open(f, "rb").read()
    if b[:3] == b"\xef\xbb\xbf":
        open(f, "wb").write(b[3:])
        print("BOM removido:", f)
PY
```
(O el `scripts/fix_encoding.py` del proyecto, si aplica a `DOCUMENTACION/`.)

**Verificación:** `file <archivo>` debe decir `UTF-8 Unicode text` (sin "with BOM").

---

## Recomendación de marcadores (no es bug, es coordinación)
Los módulos revertidos por la auditoría que YA pasan tests headless (M72, M78, M84, M126, M128, M150)
deberían re-marcarse `[x]` en las partes verificadas, para no perder trazabilidad de lo que está
efectivamente hecho. M83/M110/M107 dejar `[ ]` hasta aplicar BUG-036/037/035; M155 dejar `[ ]`
(hay código parcial: `scripts/player/equipment_manager.gd`, `ropa_data.gd`, pero faltan los 76 ítems
del header).

## Resumen de cobertura (64 módulos de agnes, re-escaneo 2026-09-14 20:2x)
- 11 módulos revertidos a `[ ]` por la auditoría (proceso correcto; código mayormente funcional).
- 5 módulos aún 100% cerrados y pasan: M80, M81, M82, M85, M86.
- Fase/milestone (M137–M143): documentación/proceso, sin código esperado — no son sobre-cierre.
- Defectos de código reales: M107 (fail), M83 (no compila), M110 (no compila).
- Defecto de doc: BOM en M54 y M84.
- La columna "SIN CODIGO" del escaneo automático tuvo false-negatives (keywords débiles); no se usa
  como evidencia de sobre-cierre — la autoridad es el test headless, que se corrió.

**Firma:** hy3 (WorkBuddy), 2026-09-14
