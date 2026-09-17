**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy (iter. 5)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13

# 04-Codigo.md — Módulo 52: Partículas y VFX

> **Iteración 5 (Log 882).** El archivo anterior describía rutas inexistentes
> (`Assets/_Project/VFX/...`, estructura de Unity) y declaraba el módulo como
> "Pendiente de implementación" cuando ya existían 3 scripts Godot reales.
> Esta versión lista **lo que existe de verdad** en `game/isla-ancestral/` y
> separa el diseño todavía no implementado.

## 1. Archivos reales (Godot 4.7.2)

### 1.1 Scripts — `game/isla-ancestral/scripts/particles/`

| Archivo | Qué es | Estado |
|---|---|---|
| `vfx_factory.gd` | `VfxFactory`: carga el catálogo, normaliza parámetros (`parametros()`), crea emisores (`nuevo_emisor()`, `crear()`) y los re-dispara de forma determinista (`redisparar()`) | ✅ Implementado (iter. 5) |
| `vfx_pool.gd` | `VfxPool`: pool de emisores por `id` con préstamo/liberación, precalentamiento, límites de emisores y partículas, política de reciclado y semillas deterministas | ✅ Implementado (iter. 5) |
| `vfx_director.gd` | `VfxDirector` (Node): conecta eventos del juego con el catálogo **a través del pool**, gestiona la vida de los one-shot y escribe el log `VFX-SKIP` | ✅ Implementado (iter. 5) |
| `vfx_schema.gd` | `VfxSchema`: validación del catálogo (id único, nombre, tipo permitido, cantidad 5-300, emisión 0.1-3, color `#RRGGBB`) | ✅ Implementado (iter. 3) |
| `preview_particles.gd` | Escena de preview de polen (demo visual) | ✅ Implementado (2026-08-24) |
| `test_vfx_pool_m52.gd` | Test de la iter. 5: runtime de la factory + pool + límites + determinismo + `VFX-SKIP` (6 bloques, 89 checks) | ✅ Implementado (iter. 5) |
| `test_vfx_catalog_headless.gd` | Test del esquema del catálogo (4 checks) | ✅ Implementado |
| `test_vfx_factory_headless.gd` | Test de `parametros()` y defaults (8 checks) | ✅ Implementado |
| `test_vfx_director_headless.gd` | Test de dispatch del director (4 checks) | ✅ Implementado |

### 1.2 Datos y escenas

| Archivo | Contenido | Estado |
|---|---|---|
| `game/isla-ancestral/data/vfx/vfx_catalog.json` | Catálogo data-driven: **8 VFX** (polvo, splash, hojas, flotante, gotas, corazones, chispas, confeti) con `id`, `nombre`, `tipo`, `evento`, `cantidad`, `color`, `emision` | ✅ 8/25 del plan maestro |
| `game/isla-ancestral/scenes/preview_particles.tscn` | Escena de demo visual (cielo, luz, cámara, emisor, label FPS) | ✅ |

## 2. API de la iteración 5

### 2.1 `VfxPool` (RefCounted)

```gdscript
const MAX_EMISORES_DEF := 32
const MAX_PARTICULAS_DEF := 1200
const MOTIVO_SIN_ID := "id vacío"
const MOTIVO_PARTICULAS := "presupuesto de partículas"
const MOTIVO_EMISORES := "sin cupo de emisores"

signal emision_descartada(id: String, motivo: String)

func _init(max_emisores := MAX_EMISORES_DEF, max_particulas := MAX_PARTICULAS_DEF)

static func semilla_de(id: String, indice: int) -> int        # FNV-1a 32 bits
static func validar_semillas(semillas: Array) -> String       # "" = válida

func precalentar(vfx: Dictionary, n := 8) -> int              # T-029
func precalentar_catalogo(catalogo: Array, n_por_vfx := 1) -> int

func prestar(vfx: Dictionary, pos := Vector3.ZERO, container: Node = null) -> Node  # T-027
func liberar(nodo: Node) -> bool
func liberar_todos() -> int

func activos() -> int · libres() -> int · creados() -> int · descartes() -> int
func reciclados() -> int · emisiones() -> int · particulas_activas() -> int
func motivos() -> Dictionary · stats() -> Dictionary · nodos() -> Array · vaciar()
```

**Política de límites (determinista).** `prestar()` primero hace hueco
(`_hacer_hueco`): recicla los activos más antiguos hasta que quepan las
partículas del VFX pedido. Si el VFX solo ya supera `max_particulas`, descarta
(`MOTIVO_PARTICULAS`). Después reusa un emisor libre **del mismo id** (evita
reconfigurar material/`amount`), o crea uno si hay cupo; si el cupo está
agotado por otros ids, descarta (`MOTIVO_EMISORES`) en vez de robar un emisor
ajeno.

**Semilla (T-093).** `semilla_de(id, indice)` es FNV-1a de 32 bits sobre
`"id:indice"`: estable entre corridas y plataformas (no depende de `hash()`
del motor ni del azar). El director usa el contador de emisiones como índice.

### 2.2 `VfxFactory`

```gdscript
static func cargar_catalogo() -> Array
static func parametros(vfx: Dictionary) -> Dictionary
static func nuevo_emisor(vfx: Dictionary) -> GPUParticles3D        # sin padre
static func crear(container: Node, vfx, position := Vector3.ZERO) -> Node
static func redisparar(gp, vfx, position, semilla: int) -> void
```

⚠️ **Dos trampas medidas (Log 882):**
1. `GPUParticles3D.mesh` **se eliminó en Godot 4.3** → la propiedad es
   `draw_pass_1`. Asignar `mesh` abortaba la función en silencio, `crear()`
   devolvía `null` y **no se instanciaba ningún VFX** aunque los 3 tests puros
   daban verde.
2. `GPUParticles3D.restart()` **re-aleatoriza `seed`** (medido:
   `2694543342 → 2659173778`). La semilla debe asignarse **después** de
   `restart()`, no antes.

### 2.3 `VfxDirector` (Node)

```gdscript
func _init(pool = null)                       # inyectable (tests)
func precalentar(n_por_evento := 1) -> int
func disparar(evento_id: String, pos: Vector3) -> bool
func actualizar(delta: float) -> int          # devuelve los agotados al pool
func set_container(node: Node) -> void · get_pool()
func eventos_registrados() -> int · ultimo_disparo() -> String
func disparos() -> int · fallos() -> int · skips() -> int · stats() -> Dictionary
func finalizar()                              # queue_free de todos los nodos del pool
```

## 3. Señales y eventos (diseño)

| Evento | Emisor | Consumidor |
|---|---|---|
| `emision_descartada(id, motivo)` | `VfxPool` | `VfxDirector` → log `VFX-SKIP` (GameLogger) |
| `VFX_EMITIDO(efecto_id, pos)` | *pendiente* | Logging M103, analítica M104 |
| `CLIMA_CAMBIADO` / `ESTACION_CAMBIADA` | M32/M29 | VfxAtmospheric (*pendiente*) |
| Triggers de animación (M48) | AnimationPlayer | VfxTrigger (*pendiente*) |

## 4. Logs del módulo

| Log | Estado | Implementado por |
|---|---|---|
| `VFX-SKIP` | ✅ | `VfxDirector._on_descarte()` → `GameLogger.warning()` (categoría `WORLD`) |
| `VFX-PLAY` | ❌ pendiente | — |
| `VFX-LOOP` | ❌ pendiente (no hay loops registrados) | — |
| `VFX-ATMO` | ❌ pendiente (no hay atmosféricos) | — |
| `VFX-REJECT` | ❌ pendiente (no hay validador de escena) | — |

## 5. Diseño NO implementado (pendiente, no confundir con lo real)

Estos archivos aparecían en la versión anterior del documento con rutas de
Unity (`Assets/_Project/...`). **No existen.** Su diseño sigue en pie como
diseño, no como código:

| Archivo previsto | Propósito | Estado |
|---|---|---|
| `vfx_manager.gd` (autoload) | Manager con presupuesto por preset (M90) y `vfx_quality` (M58) | ❌ No existe (el pool + director cubren parte) |
| `vfx_trigger.gd` | Punto único VFX + SFX (M43) + feedback (M44) | ❌ No existe |
| `vfx_atmospheric.gd` | Lluvia/nieve/polvo por clima y estación (M32/M29) | ❌ No existe |
| `ui/ui_vfx.gd` | Partículas 2D de UI con Reduce Motion (M58) | ❌ No existe |
| `budget/vfx_budget.json` | Emisores y partículas por escena | ❌ No existe |
| `validate_vfx.gd` (escena) | Validador: presupuesto de escena, naming, luz por partícula | ❌ No existe (`vfx_schema.gd` valida el catálogo, no la escena) |

## 6. Dependencias de implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (≥ 4.4.1) | M04 | `GPUParticles3D`/2D |
| Sprites/materiales | M45/M47 | Texturas de partículas, emisivos |
| Triggers de juego | M13/M17/M22/M24/M33/M34/M71 | Eventos que emiten VFX |
| Animación | M48 | Triggers en timelines |
| Audio/feedback | M43/M44 | Coordinación en un solo trigger |
| Clima/estaciones | M32/M29 | Atmosféricos |
| Iluminación | M49 | Luz de fuego/lava (nunca por partícula) |
| UI | M53/M58 | VFX 2D y Reduce Motion |
| Presupuestos | M61/M62 | Límites y pool |
| Import/CI | M108/M118 | Validación automática (4 tests en `quality.yml`) |

## 7. Notas del agente

**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Fecha:** 2026-09-13
**Iteración:** 5 — parte **no visual** (pooling, precalentamiento,
determinismo, límites, log `VFX-SKIP`).

### Lo que hice
- Arreglé un **bug real preexistente**: `VfxFactory.crear()` asignaba
  `GPUParticles3D.mesh` (eliminado en Godot 4.3) → abortaba en silencio y
  devolvía `null`, así que **el sistema no instanciaba nada** con los tests en
  verde. Ahora usa `draw_pass_1`.
- Implementé `vfx_pool.gd` (T-027, T-029, T-093, límites) y reescribí
  `vfx_director.gd` para consumirlo.
- Arreglé el determinismo de `seed` (`restart()` la re-aleatoriza → se asigna
  después).
- Añadí el log **`VFX-SKIP`** real (señal del pool + escritura en `GameLogger`),
  cerrando un ítem que estaba declarado `[x]` sin existir.
- Escribí el test de **ruta de runtime** (89 checks) y lo integré al CI.

### Lo que NO pude hacer
- No puedo dar aprobación **visual**: este host no tiene visión fiable y el
  MCP de Blender/captura no está disponible. La calibración estética
  (amplitudes, colores, densidades) queda para revisión humana.
- No implementé `vfx_manager.gd`, `vfx_trigger.gd`, `vfx_atmospheric.gd`, los
  loops con culling, el LOD por distancia ni el presupuesto por preset (M90).
- El catálogo tiene **8 de los 25** efectos del plan maestro.

### Recomendaciones para el próximo agente
- Completar el catálogo a los 25 efectos (B/RF1) antes de calibrar.
- Implementar `vfx_trigger.gd` (punto único VFX+SFX+feedback) y conectar
  `EventBus` real en lugar de solo el catálogo.
- Añadir loops registrados con culling por distancia (RF2/RF14).
- QA cruzado (§21.8) por otro modelo.
