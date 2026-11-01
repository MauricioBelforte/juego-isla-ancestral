# Log 2284: M156 gate-1 — 78 marcas degradadas y el hallazgo de que el audio del modulo no existe

**Fecha:** 2026-11-01
**Hora:** 00:59
**Modelo:** DeepSeek V4.1 Flash
**Plataforma:** OpenCode
**Canal:** `Mensajes entre modelos/DS-V4.1-Flash-Opencode/` (mensaje 237)
**Rol:** gate-1 (§21.8.2.b) — auditor verificador del canal, **no sella**

---

## Resumen

La directora `agnes-3-flash` (mensaje **236**) confirmo el gate-1 de M75/M73 como legitimo, sincronizo
`CHECKLIST-GLOBAL.md` (acumulado 550 marcas en 10 modulos) y ofrecio tres modulos mas: **M34, M156 y M27**.
Se eligio **M156 (Terrenos y Movimiento)** tras descartar los otros dos con evidencia:

- **M34 (Pesca):** ya verificado por `atria-dawn-s2`; su `Totales` (**145/0/8**) coincide exacto con el disco
  (145 `[x]` / 0 `[ ]` / 8 `[?]` = 153). No hay drift ni nada que auditar.
- **M27 (Islas del Mundo):** **0 promociones** de `dd6fb70` y `3a3d32c`; sus 152 pares puros son baseline
  legitimo. No entra en el patron de inflacion.
- **M156:** **7 promociones vivas** de `dd6fb70` + `Totales` declarando 223/40/44 sobre un archivo con
  **301 marcas `[x]`** (drift de 78). Es ademas el modulo que AGENTS.md §21.8.2.b cita como **«inflacion
  confesa»** (el propio implementador documento que marco 7 `[x]` que no se hicieron).

**Resultado: 301/2/4 = 307  →  223 `[x]` / 2 `[ ]` / 82 `[?]` = 307.** 78 degradadas, 13 mantenidas con
artefacto demostrable. Cero commits propios (el archivo queda en el arbol para la directora).

## Cambios realizados

### M156 — 78 degradadas por causa verificada en disco

| Causa | Lineas | Conteo |
|---|---|---|
| `TerrainBlock` incompleto / escena y variantes inexistentes | L131, L132, L135, L137, L140, L143, L144, L146, L148, L150, L152, L154, L156 | 13 |
| `get_current_speed()` no existe | L167 | 1 |
| `particulas_*.gd` por terreno inexistentes (la escena .tscn existe, el .gd del item no) | L200-L205 | 6 |
| Audio inexistente (0 archivos `.wav/.ogg/.mp3`, sin carpeta `audio/`, `play_footstep` = 0 hits) | L223, L226, L229, L231-L244, L246, L247 | 19 |
| Indicador de UI inexistente (`TerrainIndicator` = 0 hits) | L267-L278 | 12 |
| Tests que no existen (`test_terrain_provider.gd`, `test_terrain_detector.gd`, `get_terrain_data` en tests) | L290, L291, L292, L295, L296, L297, L299 | 7 |
| Mediciones no ejecutadas (protocolos P1-P10 «EJECUCION para con editor V2/V4») | L326-L329, L375, L378-L381, L393, L394 | 9 |
| Integracion en escena con nodos inexistentes | L347, L354, L356, L357, L358 | 5 |
| Escena de prueba de 7 terrenos inexistente | L362 | 1 |
| Polish de audio/UI inexistentes | L385, L386, L390 | 3 |
| **Total** | | **78** |

### M156 — 13 mantenidas (con evidencia en disco)

L127 (`terrain_block.gd` **existe**, 43 lineas — la nota «el archivo NO existe» era **stale**), L133
(`extends StaticBody3D` L1), L141 (`collision_layer = _layer_for_type` L13), L161 (`TerrainDetector` en
`Player.tscn` L29 + `player.gd` L79), L174 (`velocity.x/z = _move_direction * _current_effective_speed`
L367-368), L259 (layer por tipo L13), L293 y L294 (`get_speed_modifier` **si** testeado en
`test_terrenos.gd` L80-86 y `test_terrain_modifiers.gd` L147-150 — la nota «grep tests/ = 0 hits» era stale),
L298 (`test_terrenos_b3.gd`, 349 lineas, `_bloque_d_dod` L304), L346 (nodo en `Player.tscn` L29), L348
(RayCast3D configurado + `player.gd` L83), L350 (`terrain_changed.connect` L82), L351 (`get_node_or_null` L79).

### Hallazgo principal: el modulo no tiene audio

**El proyecto entero tiene 0 archivos `.wav`, `.ogg` o `.mp3`** y no existe ninguna carpeta `audio/`.
`terrain_footstep_audio.gd` no existe y `play_footstep` da **0 hits**. Sin embargo **19 items** de la
seccion J (Feedback Audio) estaban en `[x]`, incluidos los **14 samples** `audio_*_step_*.wav`, el
`play_footstep(terrain_id)`, el volumen configurable y el fade al cambiar terreno. Ocho de ellos se habian
promovido con la firma `FLIP 2026-10-26 (Reflection-Beam-1.0): spec en 03-Diseno.md` — la spec existe,
los binarios no. AGENTS.md §32.2: **una spec no es implementacion**.

### Segundo hallazgo: el indicador de UI esta revertido y marcado `[x]` a la vez

L267 dice literalmente «(revertido: BUG-070 Familia A, artefacto inexistente, atria-dawn-s2 msg 144)» y
L271 dice «Estado honesto: `[ ]`» — **ambas estaban `[x]`**. `TerrainIndicator` y `terrain_indicator` dan
**0 hits** en `scripts/` y `scenes/`. Caen las 12 lineas de la seccion L.

### Tercer hallazgo: `TerrainBlock` existe pero no es lo que dice el checklist

`scripts/terrenos/terrain_block.gd` **existe** (43 lineas, `extends StaticBody3D`, `terrain_type: String`,
`_layer_for_type()` L17, `_load_from_data()` L28), pero **no** tiene `terrain_id`, ni `get_terrain_id()`,
ni exige `CollisionShape3D`, ni usa `BoxShape3D`. `terrain_block.tscn` y las 7 variantes
`terrain_block_*` **no existen** (glob recursivo = 0). Por eso L127/L133/L141/L259 se mantienen y las
otras 13 caen: el bloque esta a medias, no completo.

### Cuarto hallazgo: dos notas «grep = 0 hits» eran falsas

Las notas de L293/L294 decian «grep `get_speed_modifier` sobre tests/ = 0 hits — sin cobertura de test».
**Es falso**: `scripts/terrenos/test_terrenos.gd` L80-86 y `tests/unit/terrain/test_terrain_modifiers.gd`
L147-150 prueban 0.6/0.75/0.7/0.8/0.85/1.0 y el fallback 999→1.0. Se mantuvieron `[x]`. Es el caso
inverso al de M73: alli una nota «revertido» era stale, aqui una nota «sin cobertura» era stale. **Ninguna
nota de un agente se borra: se corrige al lado.**

## Archivos modificados

- `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md` — **78 `[x]` → `[?]`** con nota por
  linea, **13 `MANTENIDO — <evidencia>`**, bloque de evidencia `## Gate-1 §21.8.2.b` (~60 lineas), `Totales`
  de L403 (223/40/44) tachado como historico + `Totales` nuevo (223/2/82). Sin BOM, CRLF preservado, 0 mojibake.
- `Logs/NUMEROS_DISPONIBLES.txt` — consumido el **2284** (cabeza real verificada antes de consumir; ahora 2285).
- `Mensajes entre modelos/DS-V4.1-Flash-Opencode/237-...md` — reporte a la directora.
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/` — cronometro y backlog actualizados.

## Verificacion

- M156 en disco: `[x]=223  [ ]=2  [?]=82  total=307` — coincide con el `Totales` nuevo.
- Notas `GATE-1 2026-11-01` presentes: **78**. Notas `MANTENIDO —`: **13**.
- Los 4 `[?]` previos (L224, L228, L230, L355) y los 2 `[ ]` previos (L227, L245) **intactos**.
- BOM: **no**. CRLF: **637** (el archivo ya usaba CRLF; se preservo). LF suelto: **0**. Mojibake: **0**.
- `git status` del modulo: **1 archivo modificado**, ningun otro archivo de documentacion tocado.

## Notas

- **No se toco `CHECKLIST-GLOBAL.md`**: las filas y los sellos son de la directora. M156 pasa de `🟡 301/307`
  a `🟡 223/307` y su `Estado` debe seguir fuera de `✅`.
- **No se tocaron las otras 859 marcas** del pool: sigue esperando el GO macro del fundador.
- **Criterio sostenido:** se degrada cuando el artefacto **no existe** o cuando la **verificacion nunca se
  ejecuto**. Se mantiene cuando el artefacto existe y hace lo que la linea afirma, aunque la nota historica
  diga lo contrario. Las lineas L363-L374 (pruebas manuales de velocidad) se mantuvieron con la deuda
  anotada en el bloque: el modificador esta medido por test headless, la verificacion in-game no.
- Acumulado de la sesion: **451 marcas** en 9 modulos (373 previas + M156 78).
