# Log 2445: Arreglo de los 4 jobs de CI en rojo (línea base profunda)

**Fecha:** 2026-11-25
**Hora:** 10:16
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Resumen

El director (mensaje 264 del canal heredado) dejó cuatro jobs de CI en rojo con la consigna
"CI verde primero". Esta tanda los diagnostica y arregla los cuatro, con la regla de no subir
ningún techo de deuda ni silenciar gates.

| Job | Antes | Ahora |
|---|---|---|
| GDScript Lint/Format | 3 `SCRIPT ERROR: Identifier not found` | 0 errores sobre 1366 scripts |
| Test Suite (M112) | 3 de 100 suites en rojo | 101 suites ejecutadas, 0 fallidas (§4) |
| Architecture Guard | `AUDIT_EXIT=1`, arista `A1\|DataStore,SaveManager` no permitida | exit 0 |
| Legal Tooling | 31/32 + 84 `.glb` sin copyright + 1 gate | 32/32 y todos los gates en 0 |

## Cambios realizados

### 1. GDScript Lint/Format (job `godot-lint`)

Causa: `godot --headless --check-only --script` compila los `.gd` **sin registrar los autoloads
como singletons**. Dos archivos de M169 los referenciaban por identificador global, así que el
gate abortaba con `Identifier not found` (patrón ya documentado en `GUIA-GODOT/06`, familia
BUG-128/T-108). Cuatro de los seis archivos de `scripts/crucero/` ya usaban el patrón defensivo.

- `scripts/crucero/crucero_manager.gd`: `vender_pasaje()` (líneas 129/132) y
  `conectar_transporte()` (311-314) resuelven `TransportManager` con
  `get_node_or_null("/root/TransportManager")` y guardan `null`; `fecha_compra` (145) hace lo
  mismo con `TimeCalendar`.
- `scripts/crucero/crucero_eventos.gd`: línea 86, `TimeCalendar` por nodo.
- Sin cambio de comportamiento en runtime: con los autoloads cargados la referencia resuelve al
  mismo nodo; sin ellos, degrada con guarda en vez de romper.

Evidencia: `_colector_sintaxis.gd` regenerado (1366 preloads, 0 excluidos) y
`SCRIPT ERROR detectados: 0`.

### 2. Architecture Guard (M62 / BUG-069)

El auditor marcaba `A1|DataStore,SaveManager` como hallazgo nuevo. El ciclo es funcional y
bidireccional (DataStore registra el provider de buildings; SaveManager estampa
`meta.profile_id` y valida pertenencia), y ambos lados ya usan `get_node_or_null`. Se declaró la
arista en `PERMITIDOS` con su justificación (medido en disco) y la nota de que el cierre real es
un mediador, no borrar la arista. `python scripts/auditar_arquitectura_m62.py --check` → exit 0.

### 3. Legal Tooling (M127)

Tres defectos distintos, todos reales:

1. **84 `.glb` sin `asset.copyright`** (techo declarado 418, disco 502): los modelos exportados
   después del 2026-10-10 (M25/M33/M35/M36/M40) no llevan el campo. Se agregó
   `tools/legal/inject_glb_copyright.py` (autotest propio: idempotente, no pisa
   `asset.generator`, el chunk BIN sobrevive byte a byte) y se inyectó `asset.copyright` +
   `extras.licencia` en esos 84. Resultado: `0 hallazgo(s) nuevo(s)`, techo 418/418.
   **No se subió el techo.** La deuda de fondo (418 restantes) sigue abierta y su dueño es el
   pipeline de exportación (M166/M09).
2. **EOL mixto** en `tools/legal/generate_item_attribution.py` (6 CRLF) y
   `tools/legal/test_generate_item_attribution.py` (1 CRLF): normalizados a LF (convención del
   repo, ver `.gitattributes`).
3. **Cabecera canónica ausente** en esos mismos dos archivos (les faltaba la línea
   `# Este archivo es parte de "Isla Ancestral"...`): `insert_copyright_headers.py --apply`.

Evidencia: `test_insert_copyright_headers.py` 32/32, `test_generate_item_attribution.py` OK,
`test_validate_asset_metadata.py` OK, y los 8 comandos del step legal en exit 0 (incluidos
`scan_orphan_code.py --check` tras agregar el tool nuevo al índice de git).

### 4. Test Suite (M112)

De 100 suites que ejecuta el step `Run validation tests`, fallaban 3. Las tres eran aserciones
clavadas a un estado viejo del proyecto, no fallos de producto:

- `scripts/localization/test_localization.gd`: `locales_disponibles().size() == 2` cuando el
  autoload declara 3 (`es/en/pt`) desde la iter. 3 de M87. Ahora se compara contra los catálogos
  que **existen en disco** (`data/localizacion/strings_<locale>.json`), no contra un literal
  (misma familia que BUG-032). 23 checks, 0 fallos.
- `scripts/localization/test_localizacion_iter2.gd`: misma aserción; mismo arreglo. 21/0.
- `scripts/backup/test_backup_m107.gd` + `scripts/backup/backup_manager.gd`: la policy renombró
  la clave a `retencion.max_copias_por_categoria` (H22, GO fundador 275) pero el manager seguía
  leyendo `max_copias` → **la policy quedaba decorativa** y todo caía en el default 5 (que
  coincidía por casualidad: el test verde validaba un default, no la config). Ahora
  `_max_copias()` lee la clave nueva (con fallback al nombre viejo), la limpieza por categoría
  usa la misma función, y el test comprueba el valor efectivo **y** que la clave está cableada.
  29 checks, 0 fallos.

## Archivos modificados/creados

- `game/isla-ancestral/scripts/crucero/crucero_manager.gd`
- `game/isla-ancestral/scripts/crucero/crucero_eventos.gd`
- `scripts/auditar_arquitectura_m62.py` (arista permitida + justificación)
- `tools/legal/inject_glb_copyright.py` **(nuevo)**
- `tools/legal/generate_item_attribution.py`, `tools/legal/test_generate_item_attribution.py`
- `game/isla-ancestral/assets/3d/media/*.glb` (84 modelos, chunk JSON con `asset.copyright`)
- `game/isla-ancestral/scripts/localization/test_localization.gd`
- `game/isla-ancestral/scripts/localization/test_localizacion_iter2.gd`
- `game/isla-ancestral/scripts/backup/backup_manager.gd`
- `game/isla-ancestral/scripts/backup/test_backup_m107.gd`
- `DOCUMENTACION/169-Crucero/plan-actual/05-Checklist.md` (nota del arreglo)
- `DOCUMENTACION/127-Copyright-Del-Juego/plan-actual/05-Checklist.md` (nota del arreglo)

## Riesgos y pendientes que deja esta tanda

- La inyección de metadata toca 84 binarios: si el pipeline de exportación se arregla, conviene
  regenerarlos en vez de mantener el parche. El trinquete queda en 418/418, así que un `.glb`
  nuevo sin copyright vuelve a romper CI (que es lo que se busca).
- `PERMITIDOS` de M62: revisar si la arista `A1|ThemeService,UIManager` sigue vigente (el
  auditor avisa que ya no la observa). No se tocó para no aflojar el gate sin medir.
- Los tests de localización ya no fijan el número de idiomas: si mañana se agrega un catálogo
  sin declararlo en el autoload, la aserción nueva lo detecta (cataloga contra disco).