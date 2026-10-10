# Log 1512 - BUG-121 verificado (ya resuelto) + residual en gaviota + commit M105

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-09 02:57:00 (GMT-3)
**Tipo:** Verificacion independiente + commit autorizado (canal 107)
**Modulo:** BUG-121 (M30-Fauna) | M105-Telemetria-De-Gameplay

## 1. Encargo (canal 107 del director)

1. Commit autorizado del fix de 1 linea de M105 `04-Codigo.md` sec.1 L21 (22 -> 27). Sin push.
2. Encargo nuevo: BUG-121 (autoload de fauna, `instantiate` sobre null). Reproducir los 3 SCRIPT
   ERROR headless (M107/M110/M78), aislar el autoload de fauna, fix, verificar los 3 tests limpios
   sin tocar los tests, `--check-only` de todo .gd tocado.

## 2. Resultado en una linea

M105 commiteado en local (`1c7a6b6`, 1 linea, sin push). BUG-121 NO necesitaba fix: el registro ya
lo da por resuelto (`11-BUGS.md` L515) y el fix esta commiteado (`734281d`); lo verifique de forma
independiente (3 tests, 0 SCRIPT ERROR, EXIT 0). El sintoma reportado NO reproduce en el flujo de
CI (`--import`). HALLAZGO: `gaviota_npc.gd:110` tiene el mismo patron SIN null-guard (no cubierto
por el fix de agnes) -> reportado, no tocado.

## 3. Tarea 1 - Commit M105 (HECHO, sin push)

- Antes de commitear: `git diff --ignore-cr-at-eol` = **1 archivo, 1 insercion / 1 delecion** (solo
  mi linea). EOL CRLF puro (218/218/218), sin BOM, sin NUL. Indice compartido VACIO.
- Commit: `git add -- <ruta> && git commit -m "..." -- <ruta>` (una sola invocacion, pathspec).
- Resultado: **`1c7a6b6`** - `DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/04-Codigo.md`
  | 1 file changed, 1 insertion(+), 1 deletion(-).
- Verificado: `git show HEAD:<ruta>` L21 = "27 checks"; worktree limpio; `origin/main...HEAD` = `0 1`
  (mi commit es el unico adelantado). **SIN push** (el director centraliza).

## 4. Tarea 2 - BUG-121: estado real medido (ya resuelto, no duplico)

- **Registro** `DOCUMENTACION/11-BUGS.md` L483-517: estado **`[x] Resuelto 2026-10-08 por
  agnes-3-flash (Kilo Code, canal 76)`**; "FIX APLICADO por agnes-3-flash (canal 76): null-guard
  en los 3 NPCs". Evidencia declarada: M78 60/0, M107 28/0, M110 18/0.
- **Fix commiteado**: `734281d` ("se agregaron null-guards de fauna en tortuga/cangrejo/jabali
  (BUG-121, cargas .glb en headless)").
- **grep del guard** (presente en los 3):
  `tortuga_npc.gd:85`, `cangrejo_npc.gd:63`, `jabali_npc.gd:87` -> `if escena == null:`.
- **Verificacion INDEPENDIENTE (worktree actual, 3 tests, Godot 4.7.2 `_console.exe` headless):**

  | Suite | Checks | Fallos | SCRIPT ERROR | EXIT |
  |---|---|---|---|---|
  | `scripts/backup/test_backup_m107.gd` | 28 | 0 | 0 | 0 |
  | `scripts/debug/test_debug_m110.gd` | 18 | 0 | 0 | 0 |
  | `scripts/legal/test_legal_m78_v2.gd` | 60 | 0 | 0 | 0 |

  Coincide EXACTO con la evidencia del registro. **Los 3 tests estan limpios; no hay fix pendiente.**

## 5. Premisa medida - por que el sintoma NO reproduce localmente

- **`.import` esta GITIGNORED**: `game/isla-ancestral/.gitignore:3:*.import`. Y `.godot/` tambien.
  => En un checkout sin cache, el `.glb` no tiene `.import` ni `.scn` importado.
- **Sonda scratch** (`game/isla-ancestral/_wb_b121.tmp/probe.gd`, gitignored, BORRADA al cerrar):
  `ResourceLoader.exists=true`; `load(glb)` **NO** devuelve null (`escena_null=false`); el autoload
  `/root/fauna` existe pero tiene **0 hijos** al boot en modo `--script`.
  => Con la cache de import presente, el guard no se ejercita.
- **Sonda ROJA** (probado EN ROJO y restaurado byte-exacto): neutralice el guard en los 3 NPCs
  (`if escena == null:` -> `if false:`) en el worktree; corri M78 -> **SIGUE 0 SCRIPT ERROR**
  (60/0). Restaurado con `git checkout --`; sha256 RE-VERIFICADOS contra disco:
  `tortuga 97081f3d...`, `cangrejo 3ac9dd27...`, `jabali 57b5d8a5...`. `git status` de fauna = limpio.
  => El guard NO es load-bearing en un entorno con cache de import.
- **Checkout limpio** (`git archive HEAD game/isla-ancestral` a temporal FUERA del repo, 3045
  archivos): sin `.godot/` el proyecto **NO arranca** (742 ERROR: "Failed to instantiate an
  autoload ... does not inherit from 'Node'" = falta `global_script_class_cache.cfg`). Tras
  `--import` (exactamente lo que hace CI): el `.glb` SI se importa y M78 corre **limpio**
  (0 SCRIPT ERROR, 60/0).
- **Conclusion honesta:** el SCRIPT ERROR del reporte ocurre solo en la ventana estrecha "clases
  ya cacheadas pero este `.glb` aun sin importar". Con el flujo estandar de CI (`--import` previo)
  NO se reproduce. El guard es **defensivo e inofensivo** (solo se dispara con `load() == null`),
  pero el sintoma tal como se reporto no es reproducible hoy.

## 6. HALLAZGO RESIDUAL (no tocado - zona ajena)

- **`game/isla-ancestral/scripts/fauna/gaviota_npc.gd:110`** (`_instanciar_modelo`) tiene el patron
  IDENTICO **SIN** null-guard:
  ```
  if not ResourceLoader.exists(glb): push_warning(...); return
  var modelo: Node3D = load(glb).instantiate()   # <- sin guard entre load e instantiate
  ```
  El fix de agnes cubrio tortuga/cangrejo/jabali, **NO gaviota**.
- **gaviota SI es un NPC vivo**: referenciado en `scenes/main_island.tscn:19`
  (`res://scripts/fauna/gaviota_npc.gd`). (tortuga/cangrejo/jabali tambien, L16-18.)
- **No lo toco**: es M30-Fauna, cuyo dueno declarado en el registro es **agnes-3-flash** (regla
  "reporto, no toco"). Ofrezco el guard de 1 linea si el director lo autoriza.

## 7. Pool / estado

- **Log 1512** (cabeza del pool -> 1513). **Mensaje 108** (cabeza -> 109).
- **Colisiones AJENAS** 1290 y 1468 reportadas por `reservar_log.py --estado`; NO tocadas.
- Commit local `1c7a6b6`, **SIN push**.
- **No toque:** `quality.yml`, `CHECKLIST-GLOBAL.md`, los 3 tests, los NPCs (restaurados byte-exacto),
  M30-Fauna, ni el worktree ajeno (trampa 87). Temporales (`_wb_b121.tmp/`, checkout temporal)
  BORRADOS.

## 8. Pedidos al director

1. BUG-121: ya resuelto y verificado; confirmame que lo cerramos sin mas accion (mi verificacion
   refuerza la de agnes).
2. Residual gaviota: autorizas el null-guard de 1 linea en `gaviota_npc.gd:110` (M30/agnes) o lo
   derivo a agnes?
3. Push de `1c7a6b6`: queda a tu centralizacion.
