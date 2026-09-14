# Log 882: M52 Partículas-Y-VFX — iteración 5 (parte no visual: pool, determinismo, límites, VFX-SKIP)

**Fecha:** 2026-09-13
**Hora:** 20:0x
**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Módulo:** 52 — Partículas y VFX
**Reserva:** `Logs/reservas/882-DeepSeek-V4.1-Flash-M52.txt`
**Encaje:** A8 del backlog propio — "solo la parte no-visual: pooling (M62),
precalentamiento, determinismo por semilla, límites de rendimiento".

## 0. Contexto

Continuación del bucle por módulo sobre el backlog propio
(`TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`, entrada A8, ciclo 11).
M52 estaba "🟡 Con dudas 21/130" y **liberado** desde el 2026-09-02. Se retoma la
parte que encaja con el perfil del agente: lógica pura + nodos, verificable en
headless — sin arte, escena ni calibración visual.

## 1. Hallazgo principal — bug real preexistente (falso verde)

`VfxFactory.crear()` asignaba **`GPUParticles3D.mesh`**, propiedad **eliminada en
Godot 4.3** (hoy `draw_pass_1`). Un error de script **aborta la función en
silencio**: `crear()` devolvía `null`, `VfxDirector.disparar()` lo trataba como
fallo y **no se instanciaba ningún VFX**… mientras los 3 tests del módulo
(`catalog` 4/0, `factory` 8/0, `director` 4/0) daban **verde**, porque solo
ejercitaban **funciones puras** (`parametros()`, `validar_catalogo()`,
`disparar()` con catálogo vacío).

Es el patrón de **falso verde** ya documentado en el proyecto: un bloque que no se
ejecuta nunca imprime "0 fallos". La lección: si un módulo "tiene tests verdes" pero
el artefacto no se ve, hay que probar la **ruta de runtime**, no la pura.

| Antes | Después |
|---|---|
| `gp.mesh = _quad()` → aborta en silencio, devuelve `null` | `gp.draw_pass_1 = _quad()` |
| 3 tests verdes, 0 VFX instanciados | 105 checks verdes, nodos reales creados |

## 2. Segundo hallazgo — determinismo de la semilla

`GPUParticles3D.restart()` **re-aleatoriza `seed`**. Medido:

```
seed fijada antes de restart()  ->  2694543342
seed leída después de restart() ->  2659173778   (distinta)
```

Por tanto la semilla debe asignarse **después** de `restart()`. Se corrigió en
`VfxFactory.redisparar()` y se cubre con un check del bloque D
(`semilla determinista en el reuso`).

## 3. Lo implementado

### 3.1 `vfx_pool.gd` (NUEVO) — `VfxPool extends RefCounted`

- **T-027** préstamo/liberación: `prestar(vfx, pos, container) -> Node`,
  `liberar(nodo) -> bool`, `liberar_todos() -> int`.
- Reuso **por `id`**: un emisor libre del mismo id evita reconfigurar
  material/`amount` (barato y determinista). Verificado: `creados` no sube al reusar.
- **T-029** precalentamiento: `precalentar(vfx, n=8)`, `precalentar_catalogo()`.
  Los precalentados **no emiten**.
- **Límites**: `max_emisores` (def. 32) y `max_particulas` (def. 1200). Al
  desbordar **recicla el activo más antiguo** (política determinista por orden de
  préstamo) y lo cuenta como descarte. Si el VFX solo ya supera el tope → descarte.
- **T-093** determinismo: `semilla_de(id, indice)` = **FNV-1a 32 bits** sobre
  `"id:indice"` (estable entre corridas y plataformas, no depende de `hash()` del
  motor) + `validar_semillas(secuencia)`.
- Métricas: `activos/libres/creados/descartes/reciclados/emisiones/particulas_activas/motivos/stats/nodos/vaciar`.

### 3.2 `vfx_director.gd` (REESCRITO sobre el pool)

`_init(pool = null)` (inyectable), `precalentar(n)`, `disparar(evento_id, pos)` por
el pool, `actualizar(delta)` **devuelve al pool** los emisores agotados (sin esto el
pool se llenaría de "activos" para siempre), `finalizar()` libera los nodos.

### 3.3 `vfx_factory.gd` (modificado)

`mesh` → `draw_pass_1`; nuevos `nuevo_emisor()` (configura sin añadir al árbol, para
el pool) y `redisparar()` (reuso determinista); `String(` → `str(`.

### 3.4 Log `VFX-SKIP` — implementado de verdad

El checklist tenía `[x] Definir log VFX-SKIP cuando se excede`… y **no existía
ningún `VFX-SKIP` en el código** (grep: 0 coincidencias). Se implementó:

```
VfxPool  --signal emision_descartada(id, motivo)-->  VfxDirector._on_descarte()
                                                     -> GameLogger.warning("VFX-SKIP …", WORLD)
```

Motivos estables: `id vacío`, `presupuesto de partículas`, `sin cupo de emisores`.
El nodo del logger se busca por ruta (`/root/GameLogger`) porque un autoload **no es
identificador global** en `--script`; en tests headless solo se contabiliza.

### 3.5 `test_vfx_pool_m52.gd` (NUEVO) — 6 bloques, 89 checks

| Bloque | Tema | Checks |
|--------|------|--------|
| A | Runtime de la factory (`nuevo_emisor`, `crear`, color) — **antes roto** | 14 |
| B | Determinismo (`semilla_de`, `validar_semillas`) | 9 |
| C | Pool: préstamo, liberación, reuso, motivos | 20 |
| D | Límites: emisores y partículas con reciclado | 12 |
| E | Director: dispatch real, vida de one-shot, `finalizar` | 14 |
| F | Log `VFX-SKIP`: señal, motivos y wiring del director | 14 |
| — | Marcadores `_fin` (anti-falso-verde) | 6 |

### 3.6 CI

Los 4 tests de M52 quedaron cableados en el job `test-suite` de
`.github/workflows/quality.yml` (YAML validado con PyYAML: 6 jobs).

## 4. Auditoría de sobre-cierre

El checklist declaraba `[x]` en 5 ítems de RF1 (catálogo) **sin entrada real** en
`vfx_catalog.json` (que tiene 8 de los 25 efectos del plan maestro):

| Ítem | Estado previo | Realidad medida |
|---|---|---|
| Resonancia y activación de runas | `[x]` | Sin entrada en el catálogo |
| Obtención de Sello | `[x]` | Sin entrada en el catálogo |
| Resolución de puzzle | `[x]` | Sin entrada en el catálogo |
| Construcción, cosecha y pesca | `[x]` | Cosecha y pesca sí; construcción no |
| Cambio estacional | `[x]` | Solo primavera (`vfx_polen`) |
| Log `VFX-SKIP` | `[x]` | No existía → **implementado** (queda `[x]` legítimo) |

Los 5 primeros pasaron a `[?]` con la razón al lado. Además, `04-Codigo.md`
describía rutas **Unity** (`Assets/_Project/VFX/...`) inexistentes y declaraba el
módulo "Pendiente de implementación" → reescrito con los archivos Godot reales.

## 5. Resultados (headless, Godot 4.7.2)

```
=== Resumen M52: 89 checks, 0 fallos ===        (×3, determinista)
test_vfx_catalog_headless.gd : 4 checks, 0 fallos
test_vfx_factory_headless.gd : 8 checks, 0 fallos
test_vfx_director_headless.gd: 4 checks, 0 fallos
TOTAL M52                    : 105 checks, 0 fallos
SCRIPT ERROR                 : 0
```

Los `.uid` de `vfx_pool.gd` y `test_vfx_pool_m52.gd` se regeneraron
(`--headless --path … --editor --quit`) y la suite se re-verificó tras el scan.

## 6. Checklist

`05-Checklist.md` (CRLF uniforme, sin BOM):

- Original: **139** ítems → `[x]` 78 · `[?]` 8 · `[ ]` 52 · `[!]` 1
- Sección nueva de la iter. 5: **10** ítems (todos `[x]`)
- **Total: 149 ítems → `[x]` 88 · `[?]` 8 · `[ ]` 52 · `[!]` 1**

Añadido un bloque **Convención** al principio (no existía) que fija el significado
canónico de `[x]`/`[ ]`/`[?]` según AGENTS.md §1260.

## 7. Archivos

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/particles/vfx_pool.gd` | **nuevo** |
| `game/isla-ancestral/scripts/particles/vfx_pool.gd.uid` | **nuevo** |
| `game/isla-ancestral/scripts/particles/vfx_factory.gd` | `draw_pass_1`, `nuevo_emisor`, `redisparar`, `str()` |
| `game/isla-ancestral/scripts/particles/vfx_director.gd` | reescrito sobre el pool + `VFX-SKIP` |
| `game/isla-ancestral/scripts/particles/test_vfx_pool_m52.gd` (+`.uid`) | **nuevo** |
| `.github/workflows/quality.yml` | 4 tests de M52 en `test-suite` |
| `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/04-Codigo.md` | reescrito |
| `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/05-Checklist.md` | convención + estados + sección iter. 5 |
| `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/06-Plan-Testings.md` | **nuevo** |
| `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/07-Resultados-Testings.md` | **nuevo** |
| `CHECKLIST-GLOBAL.md` | fila 52 → `🟡 Liberado · 78/139` |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | fila M52 |
| `TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` | A8 + ciclo 11 + cola → M26 |
| `TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/52-Particulas-Y-VFX/checklist.md` | 24 estados sincronizados in-place |

## 8. Pendientes declarados (no míos / no visuales)

- **Calibración visual** (amplitudes, colores, densidades): sin visión fiable en
  este host → requiere revisión humana.
- Catálogo: **8/25** efectos del plan maestro.
- No implementados: loops registrados con culling, LOD por distancia (25%),
  presupuesto por preset (M90), `vfx_trigger.gd` (VFX+SFX+feedback),
  `vfx_atmospheric.gd`, partículas 2D de UI (M53), `vfx_quality`/Reduce Motion (M58),
  validador de **escena** (presupuesto/naming/luz por partícula).
- **QA cruzado (§21.8) pendiente** — debe hacerlo otro modelo.

## 9. Cola

**Siguiente: M26 Templo-Subterráneo (A12)** — solo lo verificable: guardado atómico
por checkpoint, suites de softlock/exploit, telemetría de puzzles.
