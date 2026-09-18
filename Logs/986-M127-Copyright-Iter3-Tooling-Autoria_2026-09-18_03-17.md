# Log 986: M127 Copyright del Juego — iter. 3: tooling de autoría (7 herramientas + CI + 3 registros)

**Fecha:** 2026-09-18
**Hora:** 03:17
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** 986 (liberada al cerrar)
**Módulo:** M127-Copyright-Del-Juego

## Resumen

Iteración 3 de M127. Se cierran **12 ítems** del `05-Checklist.md` (los que dependían de tooling
verificable) implementando **7 herramientas nuevas** en `tools/legal/`, cada una con su **suite
propia**. Se cablean en CI pasando de 4 suites a **11 suites + 6 puertas duras**. Se crean los dos
documentos de testings que el módulo **no tenía** (`06` y `07`) y se corrige `04-Codigo.md`.

**Resultado: 39/101 → 51/101.** Totales reales medidos: **51 [x] · 25 [?] · 25 [ ]**.

El estado del módulo **no sube a ✅**: el **QA cruzado §21.8 sigue pendiente** (verificador ≠ autor).

## Punto de partida

Al empezar, M127 estaba en **39 [x] · 25 [?] · 37 [ ]** (iter. 2, Log 923). Los 37 `[ ]` reales eran,
en su mayoría, **capacidades de tooling** (cabeceras automáticas, sellado, escáner de huérfanos,
validador de metadata, auditor de dependencias, evidencia de autoría, registro formal). Esa es
exactamente mi zona de encaje (§5.B3): *tooling/CLI, IO de archivos, tests headless, datos
estructurados, validación*. Los 25 `[?]` son de dueño externo (usuario/legal + M118/M06/M41/M45/
M22/M147/M131/M103/M107/M89/M46) y **no se tocan**.

## Las 7 herramientas nuevas

Todas en `tools/legal/`, UTF-8 sin BOM, LF, con cabecera de copyright insertada por la herramienta
#1 (que se aplicó a sí misma — es idempotente).

| Herramienta | Bytes | Ítem | Qué prueba |
|---|---|---|---|
| `insert_copyright_headers.py` | 11778 | L105 | Inserta/actualiza la cabecera de copyright en `.gd`/`.cs`/`.py`. Idempotente, **preserva el EOL por archivo**, salta la línea de coding. `--list/--check/--apply` |
| `timestamp_seal.py` | 11449 | L106 | SHA-256 por archivo + `hash_arbol` + **cadena** `hash_previo`/`hash_cadena`. `--crear/--verificar/--cadena/--listar` |
| `scan_orphan_code.py` | 7383 | L136 | `SIN_HISTORIAL` + `SIN_CABECERA` + `AUTOR_PLACEHOLDER` con alcance declarado |
| `validate_asset_metadata.py` | 23104 | L112 | Valida la metadata de copyright **EMBEBIDA** en el formato nativo: glTF `asset.copyright`, PNG `tEXt`/`iTXt`, Vorbis `COPYRIGHT=`, WAV `LIST/INFO` `ICOP`, EXIF `0x8298`. Sanity de magic numbers |
| `audit_dependencies.py` | 17388 | L141 + L164 | Addon declarado en `licencias.json` + licencia en disco + presencia en `NOTICE.md` + manifiestos excluidos del build + assets de terceros con licencia + placeholders |
| `dump_authorship_evidence.py` | 10224 | L140 | Vuelca commits + diffstat + autores a un `.txt` y lo firma con un `.sha256` hermano. `--verificar` detecta un byte alterado |
| `registros_db.py` | 9485 | L139 | Base de datos de números de registro/certificados/fechas. Distingue **registro formal** de la **protección automática** de `copyright.json` |

## Suites y totales

Medido ejecutando cada suite (nunca copiado de una corrida anterior):

| Suite | Checks |
|---|---|
| `test_insert_copyright_headers.py` | 32 |
| `test_timestamp_seal.py` | 30 |
| `test_scan_orphan_code.py` | 19 |
| `test_validate_asset_metadata.py` | 71 |
| `test_audit_dependencies.py` | 40 |
| `test_dump_authorship_evidence.py` | 35 |
| `test_registros_db.py` | 44 |
| **Nuevas (7)** | **271** |
| `test_generate_authors.py` | 10 |
| `test_generate_copyright.py` | 13 |
| `test_generate_register.py` | 18 |
| `test_signoff_check.py` | 12 |
| **Preexistentes (4)** | **53** |
| **TOTAL `tools/legal`** | **324 checks, 0 fallos** |

Cero regresiones en las 4 suites preexistentes.

## CI: puertas duras con techo de deuda

`quality.yml` (job `legal-tools`) pasó de 4 suites a **11 suites** y se añadió un paso nuevo
`Verify legal gates (M127 iter. 3)` con **6 puertas**:

```
insert_copyright_headers.py --check
timestamp_seal.py --cadena
scan_orphan_code.py --check
validate_asset_metadata.py --check
audit_dependencies.py --check
registros_db.py --check
```

**Por qué "techo de deuda" y no una lista de excepciones.** Una puerta que falla siempre es
inútil (nadie la mira). Pero silenciar un hallazgo conocido es peor: *una excepción invisible es un
agujero negro*. La solución: la deuda conocida se declara **explícitamente** en el `*_scope.json`
de cada herramienta con `tipo`, `patron`, `max`, `motivo` y `dueño`. `--check` falla **solo ante
hallazgos NUEVOS**; `--estricto` cuenta todo. Así la puerta está verde hoy y **muerde mañana**: si
aparece un asset nuevo sin copyright, o se rompe una cabecera, `--check` sale 1.

## Documentación

- **`06-Plan-Testings.md` — CREADO.** El módulo no tenía plan de testings. §2 lista las 11 suites con
  su conteo por suite; §3 describe las tres capas anti-falso-verde.
- **`07-Resultados-Testings.md` — CREADO.** §1 tabla de las 11 suites (**TOTAL 324 checks, 0 fallos,
  exit 0**); §2 GDScript 13/0 ×3; §3 las 6 puertas de CI; §4 evidencia medida; §5 los 9 bugs de
  herramienta que las suites cazaron; §6 criterios de cierre (337 checks).
- **`04-Codigo.md` — ACTUALIZADO.** Decía "06/07 NO EXISTE" (cierto entonces). Se corrigió, se añadió
  la nota de 11 suites/324 checks y se agregó **§7** con las 7 herramientas, el razonamiento del techo
  de deuda, los hallazgos reales, los bugs de herramienta y **las 3 decisiones que no me corresponden**.

## Los 3 registros

- **`CHECKLIST-GLOBAL.md`** fila 127: `39/101` → **`51/101`**, fecha `2026-09-15` → `2026-09-18`,
  estado `🟡 Con dudas` → `🟡 Con dudas (iter. 3 ✅)`, con la nota de la iter. 3 y la iter. 2 preservada.
- **`Mensajes entre modelos/ESTADO-PARALELO.md`**: sección nueva `2026-09-18 03:17`.
- **`DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`** fila A13: `39/101` →
  `51/101`, pendientes propias `0 / 37` → `0 / 25`.

Los 3 se escribieron con un script que **asserta que cada ancla aparece exactamente 1 vez** antes de
reemplazar (si no, aborta sin escribir). Verificado después: sin BOM, sin `U+FFFD`, EOL preservado.

`scripts/verificar_checklist.py` confirma la corrección: **las alertas globales bajaron de 77 a 76**
(la de M127 desapareció). Las otras 76 son de módulos ajenos y **no se tocan**.

## Hallazgos reales — reportados, NO parcheados

Ninguno es mío, ninguno tiene prueba suficiente para tocarlo, y borrarlos o adivinar sería peor que
reportarlos.

1. **`addons/gdUnit4` sin declarar.** El otro addon (`zylann.voxel`) sí está en `licencias.json` y en
   `NOTICE.md`; gdUnit4 no. Hallazgo de `audit_dependencies.py`.
2. **BUG-042 confirmado independientemente por magic bytes.** Los 3 `.ttf` de `assets/fonts/`
   (`FredokaOne-Regular`, `Nunito-Bold`, `Nunito-Regular`, 304 KB cada uno) tienen magic
   **`0a0a0a0a`** y su contenido son **páginas HTML 404** de `github.githubassets.com`. Un `.ttf`
   válido empieza en `00010000`. Dueño: **M46/M88**.
3. **418 `.glb` sin `asset.copyright`.** Todos bajo `assets/3d/**`. Salen del I/O de Blender con
   `asset.generator` pero **sin** la atribución. Dueño: **pipeline de exportación (M166/M09)**.
   Declarado como techo de deuda (`max: 418`), no borrado ni silenciado.

## Bugs de herramienta que las suites cazaron

9 defectos reales en mi propio código, encontrados por los tests (no por inspección):

- `detectar_contenido()` no hacía `lstrip()` → reportaba los `.ttf` HTML reales como "texto plano".
- La tabla de magic numbers hacía OR entre firmas multi-firma → un `RIFF/WAVE` con extensión `.webp` pasaba.
- El parser de Vorbis dejaba el terminador NUL dentro del valor.
- `--json` imprimía el resumen en stdout → `json.load()` moría con `Extra data`.
- `fnmatch` **no** tiene semántica globstar (`*` cruza `/`) → `*/assets/*.ttf` no matcheaba
  `assets/x.ttf`. Se escribió `coincide_patron()` con `**/` → `(?:.*/)?` y `*` → `[^/]*`.
- El primer globstar arreglado (`**/assets/3d/*.glb`) rompió la puerta real: los `.glb` viven en
  `assets/3d/alta/` → cambiado a `**/assets/3d/**/*.glb`.
- `NameError: FORMAT` (typo de `FORMATO`) y `NameError: re` (import faltante).
- El primer sello cubría versiones **intermedias** de las herramientas → evidencia engañosa. Se
  regeneró para que cubra las versiones finales.

## Verificación

- **GDScript** `test_copyright_m127.gd`: **13/0 ×3**, 0 `SCRIPT ERROR`, guardián anti-falso-verde
  probado por inyección.
- **Python** `tools/legal`: **324 checks, 0 fallos** (medido, no copiado).
- **Sello vigente:** `legal/sellos/sello-20260918T060538Z.json` — 135 archivos, 390704 bytes,
  `hash_arbol=1ab16873…`, `hash_cadena=0786f5d5…`, creado sobre `git_commit=402cfbb5`.
- **Evidencia de autoría generada de verdad** en `legal/evidencia/`:
  `autoria-game-isla-ancestral-scripts-legal_20260918T061855Z.txt` (5 commits, 2461 B) y
  `autoria-repo_20260918T061928Z.txt` (188 commits, 39397 B). Ambas huellas `--verificar` → **intactas**.
- **Trampa 66:** `legal/sellos/` y `legal/evidencia/` verificados **no ignorados** por git (medido por
  *exit code* de `git check-ignore -q`, no por su salida).
- **Puertas de CI:** 5 de 6 verdes en el árbol previo al commit. `scan_orphan_code.py --check` sale 1
  con **14 `SIN_HISTORIAL`** = mis 14 archivos nuevos **aún sin commitear**. Es la puerta funcionando
  bien: en cuanto se commitean, tienen historial y pasa. Se re-ejecuta **después del commit** para
  probarlo.

## Medición — una trampa evitada en este mismo log

Al medir los exit codes de las 6 puertas con `python ... | tail -6`, el `$?` capturaba el estado de
`tail`, **no** el de Python: las 6 salían "exit=0", incluida la que en realidad sale 1. Es el patrón
de falso verde que el proyecto ya tiene catalogado. Se re-midió sin tubería
(`python ... > out 2>&1; rc=$?`) y ahí apareció la verdad. **Los exit codes se miden sobre el proceso,
nunca sobre la tubería.**

## Archivos creados / modificados

**Creados (7 herramientas + 7 suites + 4 scope/datos):**
`tools/legal/{insert_copyright_headers,timestamp_seal,scan_orphan_code,validate_asset_metadata,audit_dependencies,dump_authorship_evidence,registros_db}.py`,
`tools/legal/test_{insert_copyright_headers,timestamp_seal,scan_orphan_code,validate_asset_metadata,audit_dependencies,dump_authorship_evidence,registros_db}.py`,
`tools/legal/{headers_scope,seal_scope,asset_metadata_scope,audit_dependencies_scope}.json`,
`game/isla-ancestral/data/legal/registros.json`,
`legal/sellos/sello-20260918T060538Z.json`,
`legal/evidencia/autoria-*.{txt,sha256}`,
`DOCUMENTACION/127-Copyright-Del-Juego/plan-actual/{06-Plan-Testings,07-Resultados-Testings}.md`.

**Modificados:** `tools/legal/{generate_authors,generate_copyright_docs,generate_copyright_register,signoff_check}.py`
y sus 4 suites (cabecera de copyright), `game/isla-ancestral/scripts/legal/{copyright_validator,test_copyright_m127}.gd`,
`.github/workflows/quality.yml`, `DOCUMENTACION/127-…/plan-actual/{04-Codigo,05-Checklist}.md`,
`CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`,
`DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`, `Logs/986-…` (este log).

## Decisiones que NO me corresponden (anotadas en `04-Codigo.md` §7)

1. Si los 418 `.glb` deben llevar `asset.copyright` en el exportador o resolverse por inventario externo.
2. Si `gdUnit4` se declara en `licencias.json` o se excluye del build.
3. Si los 3 `.ttf` HTML 404 (BUG-042) se reemplazan por fuentes reales o se quitan.

## Próximos pasos

- ⏳ **QA cruzado §21.8 de M127 pendiente** (verificador ≠ autor) → por eso el módulo queda 🟡.
- **M52 iter. 6** (siguiente en mi backlog): catálogo de efectos, bucles/LOD, `vfx_trigger`, efectos
  atmosféricos. La calibración visual queda fuera de mi alcance.
- **M60** (última tarea propia): reutilización de dict/buffer en los bucles de guardado.

## Trampas aplicadas

- **70 (worktree compartido):** commit **selectivo por lista explícita de rutas**; el árbol tenía 12+
  entradas ajenas (agnes, atria, Hy3). Nunca `git add -A`.
- **66:** verificación de ignorados por *exit code*, no por salida.
- **49:** los conteos se midieron ejecutando las suites, no se copiaron.
- **25/28/69:** sin BOM, EOL preservado por archivo, `U+FFFD = 0` en los 3 registros.
- **64:** este log se commitea en el mismo ciclo en que se escribe (un log sin trackear en `Logs/`
  es un punto único de fallo).
