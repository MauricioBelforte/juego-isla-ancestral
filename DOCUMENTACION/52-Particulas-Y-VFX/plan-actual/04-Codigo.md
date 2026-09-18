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

---

## 8. API de la iteración 6 (Log 1002)

La iter. 5 dejó 3 huecos grandes: catálogo de 8 sobre 25 efectos, ninguna regla
del plan **verificable** por código, y los loops/LOD/trigger sin implementar.
La iter. 6 los cierra con dos sistemas nuevos y un validador extendido.

### 8.1 `VfxSchema` (extendido)

Conjuntos cerrados y reglas, todas comprobables en headless:

| Regla | Qué exige | Por qué |
|---|---|---|
| RF3 | `presupuesto >= cantidad` | el presupuesto no puede ser menor que lo que el efecto emite |
| RF4 | un loop trae `fase` en `[0,1)` | determinismo: la fase es un valor declarado, nunca aleatorio |
| RF6 | sin `bus` ⇒ hace falta `dueno_evento` | o lo dispara el EventBus, o hay un dueño declarado; nadie dispara nada es un bug silencioso |
| RF7 | `luz_por_particula == false` | la luz es de M49 (RF7 del plan) |
| RF11 | `parpadeo_hz <= 10` | sin estroboscopios (accesibilidad, M58) |
| RF14 | loop ⇒ `radio > 0`; no-loop ⇒ `radio == 0` | el culling necesita radio; un no-loop con radio es un dato muerto |
| RF16 | id `vfx_<snake_case>` | naming alineado con M108 |
| RF1 | los 24 nombres del plan están cubiertos | `cobertura_plan()` devuelve los que faltan |

Los conjuntos cerrados (`TIPOS`, `CATEGORIAS`, `EMISORES`, `MATERIALES`) están
duplicados **a propósito** en el generador: uno valida al escribir, el otro al
leer. Si divergen, uno de los dos falla.

### 8.2 `VfxLoops` (RefCounted) — loops ambientales

Lógica pura, sin nodos: decide *qué zona emite, con qué cantidad y en qué fase*.
El emisor lo sigue creando el pool.

- `registrar(vfx, zona, posicion)` — **una zona = un emisor** (RF9: no uno por
  chunk). Registrar dos veces la misma zona devuelve `false` en vez de reemplazar
  en silencio; tampoco acepta un `vfx` que no sea `loop` o que no traiga radio.
- `activos(camara)` — culling por distancia al centro de la zona, ordenado por
  cercanía.
- `factor_lod(vfx, distancia)` — **RF14**: `1.0` dentro del 50% del radio,
  `0.25` fuera.
- `cantidad_efectiva(zona, camara)` — cantidad tras el LOD; `0` si está fuera de
  radio o si baja del mínimo útil (no vale la pena emitir 2 partículas).
- `fase_en_t(vfx, t, periodo)` — **función pura**: `fposmod(fase + t/periodo, 1)`.
  Dos corridas con el mismo `t` dan lo mismo (RF4).
- `resumen(camara)` — foto para telemetría/log de M103.

### 8.3 `VfxTrigger` (RefCounted) — punto único evento → VFX

⚠️ **Hallazgo real de esta iteración:** `vfx_director.gd` se conectaba a
`EventBus.evento_generico`, una señal que **no existe** en el repo. El
`has_signal()` devolvía false y el director quedaba mudo: **ningún VFX se
disparaba por un evento real de juego**. El `EventBus` del proyecto no es plano:
son sub-objetos con namespace (`world.block_placed`, `quest.prereq_met`,
`weather.clima_cambio`, …).

`VfxTrigger` hace explícito el contrato:

- `construir(catalogo)` — deriva el mapa `bus → [ids]` del catálogo: agregar un
  efecto con `bus` lo conecta **sin tocar código**.
- `conectar(raiz, cb)` — resuelve cada bus namespaced contra el nodo del bus y
  devuelve `{conectados, faltantes}`. `faltantes` **nombra** lo que no pudo
  resolver: un bus mal escrito es un hallazgo, no un detalle.
- `disparar(bus, contexto, catalogo)` — puro: decide qué ids corresponden, y
  filtra por `condicion` (`"clave:valor"` contra el contexto).
- `cobertura()` / `eventos_pendientes()` — los 10 efectos sin `bus` dependen de
  otro módulo (M49/M32/M13/M16/M51/M86) y se reportan con su dueño.

Los **13** buses del catálogo están verificados contra `event_bus.gd` por el
bloque F de la suite. Queda **pendiente** migrar `vfx_director.gd` a
`VfxTrigger` (no se hizo en el mismo ciclo que el catálogo, para no mezclar dos
cambios de modelo).

### 8.4 `tools/vfx/gen_vfx_catalog.py` — generador validante

El catálogo es un **dataset**: su fuente de verdad es la tabla `E` del generador.
Regenerarlo es determinista (mismo `E` → mismos bytes) y `--check` lo verifica,
así que editar el JSON a mano se detecta en CI. Valida **antes** de escribir:
ids únicos, naming, conjuntos cerrados, rangos, presupuesto, RF7/RF11/RF14/RF6 y
la cobertura de los 24 nombres.

### 8.5 Flujo de un loop ambiental (humo)

1. **Catálogo** — `vfx_humo`: `loop=true`, `radio=40`, `fase=0.0`, `cantidad=40`,
   `emisor=global`, `presupuesto=80`, `dueno_evento=M49` (el evento es de M49).
2. **Registro** — el sistema de zonas llama
   `loops.registrar(vfx_humo, "zona_playa", posicion_del_centro)`. Una zona, un
   emisor.
3. **Culling** — cada frame, `loops.activos(camara)` devuelve las zonas dentro de
   radio, ordenadas por cercanía.
4. **LOD** — `cantidad_efectiva("zona_playa", camara)`: `40` dentro del 50% del
   radio, `10` (25%) entre el 50% y el 100%, `0` fuera. Con menos del mínimo
   útil no se emite.
5. **Fase** — `fase_en_t(vfx_humo, t, periodo)` da la posición en el ciclo. Es
   pura: no hay `randf()`, así que la corrida es reproducible.
6. **Emisión** — el pool presta un emisor (T-027), lo configura con
   `VfxFactory.redisparar()` (semilla DESPUÉS de `restart()`) y lo libera.
7. **Límites** — si el pool no tiene presupuesto, descarta y el director escribe
   `VFX-SKIP` en `GameLogger` (RF3: el descarte es visible).
8. **Telemetría** — `loops.resumen(camara)` da zonas activas y partículas
   totales para el frame budget.

### 8.6 Lo que sigue sin implementarse

- `vfx_manager.gd`, `vfx_atmospheric.gd`, `ui/ui_vfx.gd`.
- Presupuesto por preset (M90) — el `presupuesto` por efecto ya existe.
- Migrar `vfx_director.gd` a `VfxTrigger` (el `evento_generico` es código muerto).
- Los 10 efectos con `dueno_evento` externo (el evento lo emite otro módulo).
- **Aprobación visual**: amplitudes, colores y densidades son calibración
  estética y requieren revisión humana (este host no tiene visión fiable).
- **QA cruzado (§21.8)**: lo hace otro modelo, no el autor.

### 8.7 Notas del agente (iter. 6)

- El checklist pedía "los 25 efectos del plan maestro"; el plan enumera **24**
  (`plan-inicial/04-Codigo.md:149`). Se cubren los 24 y la discrepancia se
  **reporta**, no se inventa un 25º efecto para cuadrar el número.
- Dos suites previas quedaron **rojas** al cambiar el catálogo: asertaban
  "8 eventos" / "8 VFX". Son aserciones obsoletas de la iter. 5, no regresiones
  de código; se actualizaron a los valores medidos (30 eventos, 31 entradas).
- El guardián anti-falso-verde de la suite nueva **se probó por inyección**: con
  un `return` temprano dentro de `_run`, la corrida salía **exit 2**, nombraba
  los bloques faltantes (`["C","D","E","F"]`) y decía `INVALIDO`.
- Esa prueba destapó un defecto del propio guardián: con `_summary()` sólo al
  final de `_run`, un aborto temprano dejaba el proceso **colgado** (nunca se
  llamaba a `quit()`, sin exit code, muerto por timeout a los 300 s). Ahora
  `_summary()` se encola también desde `_init()` y es idempotente.
