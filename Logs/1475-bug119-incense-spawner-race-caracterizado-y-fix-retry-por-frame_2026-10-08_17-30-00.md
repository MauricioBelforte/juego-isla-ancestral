# Log 1475: BUG-119 — race del IncenseSpawner caracterizado y fix defensivo aplicado (retry por frame)

**Fecha:** 2026-10-08
**Hora:** 17:30
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Cierre del frente asignado en msg 72 (atria-dawn): el race de `IncenseSpawner` con
la generación del terreno voxel quedó caracterizado con medición (no inferencia),
reproducido el RED exacto y aplicado el fix defensivo autorizado (msg 57) SOLO en
`scripts/enchantment/incense_spawner.gd`. El fix v1 con `call_deferred` recursivo
revienta el proceso con SIGSEGV (descubierto y medido) y fue reemplazado por un
reintento vía `_process` (patrón M50). Ningún archivo de terreno M163/M167 fue
tocado. Regresión completa = baseline.

## Cambios Realizados

### Caracterización del race

- **Arranque normal** (`--headless --path game/isla-ancestral --quit-after 300`):
  `[Bootstrap] Escena principal ya activa: se omite recarga` → montaje único →
  `[M163] IncenseSpawner: 6 puntos en montaña (0 fallas de altura, centro (2320.0, 2300.0))`.
  Falso positivo del cierre anterior confirmado con medición.
- **Arranque `--script`** (probe `tests/_probe_bug119_boot.gd`, el escenario del
  0/24 del director): `change_scene_to_file` diferido (bootstrap.gd:168) →
  `_crear_incense_spawner` (main_island.gd:429) corre en el mismo frame del montaje,
  ANTES de que `TerrainLocator` resuelva el `VoxelTerrain` en su `_process` →
  `get_height` = -1 en los 24 intentos → RED exacto:
  `[M163] IncenseSpawner: 0 puntos creados (24 fallas de altura en centro (2320.0, 2300.0))`.
- **Hallazgo colateral (delegado, no tocado):** `_crear_shaman` (main_island.gd)
  cae a su fallback hardcodeado y=35 ante `get_height < 0`: Run B → chamán en y=35
  vs y=17 real. Mismo race en otro spawner, OCULTO en arranque normal. Requiere
  aviso previo (main_island.gd) — reportado al director en msg 73.

### Fix (solo `scripts/enchantment/incense_spawner.gd`)

- Intento sincrónico original intacto en `_ready`; si `_puntos.is_empty()` →
  `_reintentando = true` + `set_process(true)`.
- `_process`: 1 probe por frame (patrón M50 `vegetation_spawner`); llama a
  `_spawneear(CANT_PUNTOS, false)` solo cuando `_altura(centro) >= 0`; timeout
  8000 ms con `push_warning` honesto; `set_process(false)` al terminar (coste 0
  en el camino sincrónico y en la suite con mock).
- **⚠️ Lección dura (documentada en 11-BUGS):** la v1 del fix — `call_deferred`
  recursivo desde `_reintentar_spawn`, tal cual el fix autorizado en msg 57 —
  **crashea el proceso con signal 11 (SIGSEGV)** en `_reintentar_spawn:78`.
  Causa: en Godot 4 un `call_deferred` emitido durante el flush del MessageQueue
  puede procesarse en el MISMO flush → recursión infinita → overflow de pila
  nativa. Regla: nunca re-encolar `call_deferred` desde la propia función
  diferida; usar `_process` con timeout o `await get_tree().process_frame`.

### Verificación post-fix (matriz completa)

| Prueba | Resultado |
|---|---|
| Run B (`--script` + probe) post-fix | warning honesto del intento inicial + `[M163] IncenseSpawner: 6 puntos en montaña (24 fallas de altura, ...)`; sin crash |
| Run A (arranque normal) post-fix | 6 puntos / 0 fallas; sin retries; sin warning de agotado |
| `test_incienso.gd` standalone | 67 checks / 0 fallos (mock locator síncrono intacto) |
| Runner regresión (`tests/run_tests.gd`) | 25 descubiertas / 0 excluidas / 19 OK / 718 tests / 3 fallos preexistentes = baseline (1ª corrida murió a mitad de fase GdUnit sin RESULTADO → flake; repetida OK) |
| Gate templos (`test_regresion_templos.gd`) | 76 checks / 0 fallos |

### Limpieza

- Borrada la sonda `game/isla-ancestral/tests/_probe_bug119_boot.gd` (monouso).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/enchantment/incense_spawner.gd` — MODIFICADO (fix retry)
- `DOCUMENTACION/11-BUGS.md` — BUG-119 actualizado (Estado + bloque Fix APLICADO; ESCRITO, NO stagear — saneo del director)
- `DOCUMENTACION/163-Sistema-De-Encantamientos/plan-actual/05-Checklist.md` — nota BUG-119 actualizada
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` — frente cerrado
- `Mensajes entre modelos/ESTADO-PARALELO.md` — bloque de cierre (ESCRITO, NO stagear)
- `Mensajes entre modelos/mimo-v2.6-flash-free/73-2026-10-08_17-28-06-mimo-a-mimo-bug119-incense-spawner-fix-defensivo-aplicado.md` — informe al director
- `Logs/NUMEROS_DISPONIBLES.txt` — 1475 consumido (el 1474 lo tomó agnes-3-flash en paralelo; renumeración aplicada)
- BORRADO: `game/isla-ancestral/tests/_probe_bug119_boot.gd`
- Logs TEMP de corridas: `TEMP/bug119/{runB_postfix2,runA_postfix,test_incienso_postfix,runner_bug119_fix2,gate_bug119_fix}.txt`

## Nota de identidad

Firma: mimo-v2.6-flash-free / opencode (carpeta de canal propia = identidad, §10.2).
Sin push (solo el director pushea). Commits locales con add+commit encadenados
(4ª carrera de índice ya sufrida en el frente B, commit 2e668bc de agnes).
