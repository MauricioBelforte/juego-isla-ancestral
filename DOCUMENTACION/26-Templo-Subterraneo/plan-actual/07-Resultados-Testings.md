# 07 — Resultados de Testings — M26: Templo Subterráneo

**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-14
**Iteración:** 2
**Log:** `Logs/902-M26-Templo-Subterraneo-Iter2_2026-09-14.md`

## Comando ejecutado

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/templos/test_templo_m26.gd
```

## Resultado

| Corrida | Checks | Fallos | EXIT | `SCRIPT ERROR` |
|---|---|---|---|---|
| 1 | 92 | 0 | 0 | 0 |
| 2 | 92 | 0 | 0 | 0 |
| 3 | 92 | 0 | 0 | 0 |
| 4 (conteo por bloque) | 92 | 0 | 0 | 0 |

```
=== [M26] Templo Subterráneo — iteración 2 (DeepSeek-V4.1-Flash / WorkBuddy) ===
  -- bloque A completado --
  -- bloque B completado --
  -- bloque C completado --
  -- bloque D completado --
  -- bloque E completado --
  -- bloque F completado --
  -- bloque G completado --
=== Resumen M26: 92 checks, 0 fallos ===
```

Los **7 marcadores** de bloque están presentes y el test los verifica
explícitamente: un error de script aborta la función en silencio, así que un
bloque podría no ejecutarse y el test salir "verde" (falso verde). En esta
iteración **el mecanismo se ganó el sueldo**: en la primera corrida el bloque C
abortó en silencio por un error de parseo y los marcadores lo delataron.

## Checks por bloque

| Bloque | Alcance | Checks | Fallos |
|---|---|---|---|
| A | `TemploFlow` — gating básico | 14 | 0 |
| B | `TemploFlow` — anti-exploit | 11 | 0 |
| C | `TemploCheckpoint` — guardado atómico | 20 | 0 |
| D | `TempleTelemetria` — intentos/pistas/tiempo + export M24 | 14 | 0 |
| E | `TemploValidadores` — el diseño real pasa las 6 suites | 12 | 0 |
| F | `TemploValidadores` — detecta fallos inyectados | 12 | 0 |
| G | `TemploSchema` (iter. 1) — regresión | 1 | 0 |
| — | Glifos leídos del diseño | 1 | 0 |
| — | Marcadores de bloque | 7 | 0 |
| | **Total** | **92** | **0** |

## Bugs reales encontrados y corregidos durante el ciclo

### 1. `DirAccess.make_dir_recursive()` no es estático → el script no compilaba (bloque C abortado en silencio)

- **Síntoma:** `SCRIPT ERROR: Parse Error: Cannot call non-static function "make_dir_recursive()" on the class "DirAccess" directly.` y `Failed to compile depended scripts`.
- **Efecto:** `templo_checkpoint.gd` no compilaba → `CpGd.new(...)` fallaba con `Invalid call. Nonexistent function 'new' in base 'GDScript'` → el bloque C se abortaba **en silencio** (la primera corrida mostró 70 checks y el marcador `C` faltó).
- **Corrección:** `DirAccess.make_dir_recursive_absolute(dir)` (la variante estática, que sí acepta `user://`).
- **Nota:** el mismo error de base (clase abstracta) es el que rompía `backup_manager.gd` de M107 (ver abajo).

### 2. `DirAccess.open("user://…")` devuelve `null` (y `get_files_at()` devuelve `[]`)

- **Síntoma:** `guardar()` devolvía `false` con `no se pudo abrir 'user://test_m26_cp'`; 11 checks cayeron en cascada.
- **Medición (sonda, Godot 4.7.2 headless con `--path` relativo):**

  | Llamada | Resultado |
  |---|---|
  | `DirAccess.open("user://test_m26_cp")` | `<Object#null>` |
  | `DirAccess.open("user://")` | `<Object#null>` |
  | `DirAccess.open("res://")` | OK |
  | `DirAccess.get_files_at("user://…")` | `[]` |
  | `DirAccess.dir_exists_absolute("user://…")` | `true` |
  | `DirAccess.make_dir_recursive_absolute("user://…")` | `OK` |
  | `FileAccess.open("user://…/x.json", WRITE)` | OK |
  | `DirAccess.open(ProjectSettings.globalize_path("user://…"))` | **OK** |
  | `DirAccess.get_files_at(globalize_path("user://…"))` | **OK** (lista los archivos) |

  `globalize_path("user://")` = `./Godot/app_userdata/isla-ancestral/` (relativa):
  el `user://` real es `game/isla-ancestral/Godot/app_userdata/isla-ancestral/`.
- **Corrección en M26:** el checkpoint usa solo las funciones estáticas
  (`rename_absolute`, `remove_absolute`, `dir_exists_absolute`) y deriva la lista
  de archivos de los ids conocidos con `FileAccess.file_exists()`, sin listar el
  directorio.
- **Corrección en M107:** `backup_manager.gd` ahora globaliza antes de abrir
  (`DirAccess.open(_dir_os())` y `DirAccess.get_files_at(_dir_os())`).

### 3. Dos bugs propios en el test (los detectó la propia suite)

- **Reloj de la telemetría:** el caso esperaba 20 s pero el test solo avanzaba
  10 s después del primer intento. Corregido el avance (10 → 25 → 30), no la
  aserción.
- **Sello sin registrar:** el caso "rechaza glifo incorrecto" fallaba con motivo
  `sello_inexistente` porque el sello del anillo 1 no se había registrado. Se
  agregó `registrar_sello("sello_cristal_2")` antes, más dos checks extra (el
  sello queda libre tras el intento fallido y luego funciona con el glifo correcto).

## Bloqueante de proyecto encontrado y corregido (no era de M26)

**`scripts/backup/backup_manager.gd` (M107, autoload `BackupManager`) no compilaba.**

- **Causa:** `var _da := DirAccess.new()` — `DirAccess` es **abstracta** en Godot 4:
  `Parse Error: Native class "DirAccess" cannot be constructed as it is abstract`.
- **Efecto doble:**
  1. El autoload `BackupManager` no cargaba → el test de M107 fallaba
     (`cantidad backups >= 1`, BUG-035).
  2. **Toda** corrida headless del proyecto imprimía 3 líneas `SCRIPT ERROR`, lo
     que contamina cualquier verificación que filtre por `SCRIPT ERROR`.
- **Corrección:** `make_dir_recursive_absolute()` para crear el directorio;
  `_dir_os()` (globalizar) para `_limpiar_excedentes()` y `cantidad_backups()`.
- **Verificación:** `test_backup_m107.gd` → **9 checks, 0 fallos, EXIT 0 ×3, 0 `SCRIPT ERROR`**.
- **De regalo:** la **retención de backups nunca se aplicaba** (`_limpiar_excedentes()`
  salía antes por `dir == null`) — eso no lo cubría ningún test. Ahora sí funciona.

## Observaciones

- La suite valida el **diseño real** (`templo_layout_diseno.json`, 20 zonas, 24
  conexiones) y además **12 fallos inyectados**, incluido un caso anti-tautología:
  el layout de iter. 1 (4 salas lineales, 3 CP) **no** pasa la suite de
  checkpoints — el validador no "aprueba todo".
- El hallazgo de diseño del checklist: el `03-Diseno` pide **8 glifos del Sello
  (4 comunes + 4 de cámara)** pero el grafo de iter. 2 nombra **7** (uno por
  anillo). Queda `[?]` (ver `05-Checklist.md`).
- El `03-Diseno` se contradice en los checkpoints: §"Checkpoints" lista
  *porte, vestíbulo, vientos, central, sello* mientras que la tabla de zonas
  lista *vestíbulo, vientos, central, final, sello*. Se siguió la lista explícita
  (§Checkpoints) y se registró la inconsistencia.

## No cubierto (ver `06-Plan-Testings.md`)

Navegación real (M08/M61), NPC atascados (M19/M64), puzzles irresolubles (M24),
mapa de zona (M58), presupuesto por región (M63), instancing (M61/M63), deriva
real del jugador y calibración visual (§15.3).

## Conclusión

La parte verificable de M26 (gating, anti-exploit, checkpoints atómicos,
telemetría de puzzles y las suites de validación) está implementada y probada:
**92 checks, 0 fallos, EXIT 0 ×3, 0 `SCRIPT ERROR`**. El módulo **sigue 🟡**
porque su contenido visual/3D/audio depende de M08, M41/M42/M43, M45/M47/M52,
M58, M61 y M63.

**Pendiente de QA cruzado §21.8** por otro agente (verificador ≠ autor).
