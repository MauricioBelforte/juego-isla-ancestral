**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (iter. 2 — Log 328; historial: Deepseek V4 Flash/Kilo iter. 1 Log 298; doc original 2026-08-17)

# 04-Codigo.md — Módulo 40: Infraestructura

> Rutas previstas dentro de `res://core/` (estructura del proyecto Godot 4.x, GDScript).
> Estado: **Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Scripts (GDScript, tipado)

| Archivo | Propósito | Estado |
|---|---|---|
| `res://core/event_bus.gd` | Autoload `EventBus`: bus de eventos por dominios tipados | Pendiente de implementación |
| `res://core/logger.gd` | Autoload `Logger`: contrato de logging global (detalle M103) | Pendiente de implementación |
| `res://core/game_state.gd` | Autoload `GameState`: dato puro de partida particionado (M07) | Pendiente de implementación |
| `res://core/service_registry.gd` | Autoload `ServiceRegistry`: Service Locator por contratos (M07) | Pendiente de implementación |
| `res://core/scene_manager.gd` | Autoload `SceneManager`: transiciones de escena con progreso (M63) | Pendiente de implementación |
| `res://core/game_flow_manager.gd` | Autoload `GameFlowManager`: máquina de estados de flujo | Pendiente de implementación |
| `res://core/bootstrap.gd` | Autoload `Bootstrap`: orquestador del arranque (último) | Pendiente de implementación |
| `res://core/diagnostico.gd` | Helper `Diagnostico` (`RefCounted`): scan estático de imports y sanity runtime | Pendiente de implementación |
| `res://core/contratos.gd` | Constantes `StringName` de contratos de servicios (`&"economia"`, etc.) | Pendiente de implementación |

### 1.2 Escenas raíz

| Archivo | Propósito | Estado |
|---|---|---|
| `res://core/scenes/boot.tscn` | Escena inicial: sanity visual mínimo + log de arranque | Pendiente de implementación |
| `res://core/scenes/error.tscn` | Pantalla de error de arranque (motivo i18n + reintentar) | Pendiente de implementación |
| `res://core/scenes/main_menu.tscn` | Integración con M53 (menú principal; propiedad de M53) | Pendiente de implementación |
| `res://core/scenes/world.tscn` | Integración con M08/M63 (mundo voxel) | Pendiente de implementación |

### 1.3 Configuración del proyecto

| Archivo | Propósito | Estado |
|---|---|---|
| `project.godot` (sección `[autoload]`) | Declaración de los 7 autoloads CORE con prioridad y los autoloads de dominio M38 | Pendiente de implementación |

```ini
[autoload]
EventBus="10*res://core/event_bus.gd"
Logger="20*res://core/logger.gd"
GameState="30*res://core/game_state.gd"
ServiceRegistry="40*res://core/service_registry.gd"
SceneManager="50*res://core/scene_manager.gd"
GameFlowManager="60*res://core/game_flow_manager.gd"
Bootstrap="1*res://core/bootstrap.gd"
```

### 1.4 Señales / eventos externos consumidos

| Evento (dominio.nombre) | Emisor | Uso |
|---|---|---|
| `infra.carga.completada(ruta)` | SceneManager | UI progreso y game flow |
| `economy.*` | M38 | Consumidos por UI (M53) vía EventBus; infraestructura no intercepta |
| `world.*` / `npc.*` / `calendar.*` | dominios (M07) | Publicados por EventBus; la UI se suscribe |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- event_bus.gd (autoload "EventBus", prioridad 10) ----------
extends Node

var _suscriptores: Dictionary = {}   # dominio -> {evento -> Array[Callable]}

func emitir(dominio: StringName, evento: StringName, payload: Variant = null) -> void:
    pass    # reenvío directo a los Callable suscritos; sin validación de dominio

func suscribir(dominio: StringName, evento: StringName, callable: Callable) -> bool:
    pass    # true si se registró; evita duplicados del mismo Callable

func desuscribir(dominio: StringName, evento: StringName, callable: Callable) -> bool:
    pass

func limpiar_receptor(nodo: Node) -> void:
    pass    # poda Callables cuyo objeto_basico es `nodo` (evita fugas al liberar)
```

```gdscript
# ---------- service_registry.gd (autoload "ServiceRegistry", prioridad 40) ----------
extends Node

signal servicio_registrado(contrato: StringName, servicio: Node)
signal servicio_faltante(contrato: StringName)

var _servicios: Dictionary = {}      # StringName -> Node

func registrar(contrato: StringName, servicio: Node) -> bool:
    pass    # false + warning DOM-INF-REGISTRO si el contrato ya existe

func obtener(contrato: StringName) -> Node:
    pass    # null + warning DOM-INF-FALTANTE si no registrado (nunca excepción)

func esta_registrado(contrato: StringName) -> bool:
    return _servicios.has(contrato)

func listar_contratos() -> Array[StringName]:
    pass    # copia ordenada (solo lectura)

func verificar_integridad(esperados: Array[StringName]) -> Array[String]:
    pass    # devuelve lista de contratos esperados-faltantes (RF11)
```

```gdscript
# ---------- game_state.gd (autoload "GameState", prioridad 30) ----------
extends Node

var _dominios: Dictionary = {}       # StringName -> Resource/Node (datos puros M07)

func inicializar_nueva(seed_partida: int) -> void:
    pass    # crea particiones por dominio (meta, world, player, ...) (M07 §4)

func cargar(snapshot: Dictionary) -> void:
    pass    # restaura particiones; delegación de guardado a M60/M62

func acceder(dominio: StringName) -> Object:
    pass    # null si no existe; solo lectura de datos, sin referencias a servicios

func snapshot() -> Dictionary:
    pass    # copia plana para persistencia (M60/M62)
```

```gdscript
# ---------- game_flow_manager.gd (autoload "GameFlowManager", prioridad 60) ----------
extends Node

enum Estado { BOOT, MENU, CARGANDO, MUNDO, PAUSA, TRANSICION, ERROR }

const TRANSICIONES: Dictionary = { ... }   # ver 03-Diseno §4

var _estado: Estado = Estado.BOOT

func estado_actual() -> Estado:
    return _estado

func cambiar_estado(estado: Estado) -> bool:
    pass    # valida contra TRANSICIONES; warning DOM-INF-ESTADO si ilegal

func transiciones_permitidas() -> Array[Estado]:
    pass
```

```gdscript
# ---------- scene_manager.gd (autoload "SceneManager", prioridad 50) ----------
extends Node

signal carga_iniciada(ruta: String)
signal carga_completada(ruta: String)

var _escena_actual: String = ""

func cambiar_escena(ruta: String, modo: GameFlowManager.Estado = GameFlowManager.Estado.TRANSICION) -> void:
    pass    # delega carga pesada a M63 (progreso); bloquea UI interactiva (AGENTS.md §8)

func escena_actual() -> String:
    return _escena_actual
```

```gdscript
# ---------- bootstrap.gd (autoload "Bootstrap", prioridad 1 — ÚLTIMO) ----------
extends Node

func _ready() -> void:
    pass    # 1) sanity check 2) config 3) GameState 4) integridad contratos
            # 5) diagnóstico 6) ESTADO_MENU 7) SceneManager -> main_menu
            # 8) log DOM-INF-BOOT; fallo en cualquier paso -> ESTADO_ERROR (D10)

func reintentar_arranque() -> void:
    pass    # invocado por la pantalla de error; vuelve a ESTADO_BOOT
```

```gdscript
# ---------- diagnostico.gd (helper RefCounted, NO autoload) ----------
class_name Diagnostico
extends RefCounted

static func chequear_ciclos(ruta_raiz: String) -> Array[String]:
    pass    # grafo de imports (class_name/preload/const); devuelve ciclos

static func chequear_capas(ruta_raiz: String) -> Array[String]:
    pass    # regla 1 de M07: dominio solo importa core/data/inferiores; nunca UI

static func verificar_escena_previa(escena: Node, servicios: Array[StringName]) -> Array[String]:
    pass    # RF12: detecta uso de servicios en _ready() antes de estar registrados
```

## 3. Logs Relacionados (propuestos)

| Log | Contenido |
|---|---|
| `DOM-INF-BOOT` | Orden real de instanciación de autoloads, config cargada, contratos verificados, escena inicial decidida |
| `DOM-INF-REGISTRO` | Alta/baja de contratos en ServiceRegistry; duplicados rechazados |
| `DOM-INF-FALTANTE` | `obtener()` sobre contrato no registrado o integridad fallida (RF11) |
| `DOM-INF-ESTADO` | Cambios de estado válidos e intentos ilegales rechazados |
| `DOM-INF-ERROR` | Motivo de fallo de arranque (config corrupta, sanity KO, ciclo detectado) |
| `DOM-INF-ACCESO-TEMPRANO` | Uso de servicio en `_ready()` antes de registro (RF12) |
| `DOM-INF-DIAG` | Salidas del scan estático de ciclos/capas en editor y CI |

Formato de línea de ejemplo: `[DOM-INF-BOOT] autoloads: EventBus,Logger,GameState,ServiceRegistry,SceneManager,GameFlowManager,Bootstrap | contratos_ok=4 esperados=4 escena=main_menu.tscn`

## 4. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo
**Fecha:** 2026-08-17
**Estado:** Documentación completa, DELEGABLE PARA IMPLEMENTAR

### Lo que hice
- Documenté el diseño completo del módulo 40 (Infraestructura): 7 autoloads CORE con orden de carga explícito (EventBus, Logger, GameState, ServiceRegistry, SceneManager, GameFlowManager, Bootstrap), Service Locator por contratos (M07), EventBus de dominios tipados, GameState como dato puro, escenas raíz boot → menú → mundo y máquina de estados de flujo (BOOT/MENU/CARGANDO/MUNDO/PAUSA/TRANSICION/ERROR).
- Definí el contrato de integración con M38 (auto-registro de sus 4 autoloads + verificación de integridad), M53 (consumo por contrato y eventos, `_ready` aplazado) y M63 (SceneManager delega la carga con progreso).
- Especifiqué el diagnóstico dual (estático en editor/CI + sanity de runtime) con reglas anti-circulares verificables de M07.
- Especifiqué rutas previstas (`res://core/...`), declaración de autoloads de `project.godot`, firmas GDScript tipadas, logs DOM-INF-* y el manejo de error de arranque con fallback.
- Creada la dupla plan-inicial/plan-actual con los 5 archivos obligatorios del estándar y checklist de 211 ítems completados.

### Lo que NO pude hacer (honestidad obligatoria)
- No hay código runtime: todo lo listado es diseño previsto, marcado "Pendiente de implementación".
- No se verificó en un editor Godot real el comportamiento exacto de la prioridad de autoloads de esta versión (mayor = primero); se asume el comportamiento documentado del motor y se dejó un test de arranque que verifica el orden observado (RF6/RF11).
- No se definieron los nombres definitivos de los contratos de servicios de dominios futuros (inventario, mundo voxel, etc.): solo los de M38 y los CORE; el resto se agregará al implementarse.
- La escena `main_menu.tscn` y `world.tscn` son puntos de integración: su contenido real depende de M53 y M08/M63 respectivamente.
- No se tocó `CHECKLIST-GLOBAL.md` ni ningún otro archivo fuera de `DOCUMENTACION/40-Infraestructura/` (regla estricta de la tarea); la actualización de la tabla global queda para el flujo normal del protocolo.

### Recomendaciones para el próximo agente
- Implementar primero `ServiceRegistry` + `contratos.gd` (base de todo: sin locator no hay auto-registro), luego `EventBus` y `GameFlowManager` (máquinas puras, testables en Edit Mode).
- Segundo: `GameState` como contenedor de datos puros (sin importar servicios) y `SceneManager` mínimo con cambio de escena simple.
- Tercero: `Bootstrap` con sanity check y arranque a `boot.tscn`/`error.tscn`; recién después conectar el auto-registro de M38 (confirmar los nombres reales de sus autoloads: EconomyManager, PriceManager, ShopManager, BarterSystem).
- Verificar en el editor la semántica de prioridad de autoloads de la versión de Godot en uso y ajustar las prioridades numéricas si hiciera falta manteniendo el ORDEN documentado (Bootstrap siempre último).
- Al conectar M63, confirmar el nombre real de su contrato de carga con progreso antes de fijar la firma de `SceneManager.cambiar_escena`.
- En `plan-actual/` copiar estos archivos y actualizarlos contra el código real a medida que se implemente (firma del último agente que modifique).
---

## Implementación real (2026-08-31, Deepseek V4 Flash / Kilo - Log 298)

> La plan-inicial describe el orden canónico (Bootstrap ÚLTIMO, prioridades numéricas). El proyecto real tiene un orden histórico distinto (Bootstrap en posición media). NO se reordenó (riesgo de romper dependencias vivas); la divergencia queda documentada y el test M40 valida el comportamiento real.

### Archivos runtime (autoloads)

res://scripts/core/
|-- game_flow_manager.gd   # autoload GameFlowManager
|-- scene_manager.gd       # autoload SceneManager
|-- bootstrap.gd           # extendido (autorregistro + integridad RF11)
|-- test_infraestructura.gd

### Implementado

- GameFlowManager: enum Estado (BOOT/MENU/CARGANDO/MUNDO/PAUSA/ERROR), tabla TRANSICIONES específica del prototipo, cambiar_estado() con validación, en_juego(), señal estado_cambiado.
- SceneManager: cambiar_escena(ruta) con ResourceLoader.exists + anti doble-click, change_scene_to_file diferido (§9.20/§9.25), señales, esta_cargando() (AGENTS §8).
- Bootstrap extendido: DOMINIOS_ESPERADOS (9), _autoregistrar_dominios() por contrato, verificar_integridad_dominios() (DOM-INF-FALTANTE vía has()), _verificar_game_flow() (BOOT->MUNDO).

### Divergencias vs plan-inicial (honestas)

1. Orden de autoloads no reordenado (histórico).
2. BOOT->MUNDO directo (sin menú aún; M89/M63 completarán el flujo).
3. GameState no duplicado: lo cubre SaveManager/M59.
4. Escenas raíz: mundo actual = main_island.tscn (plan-inicial preveía boot/main_menu/world - pendiente M89/M63).

---

## Implementación real iter. 2 (2026-09-01, deepseek-v4-flash / Kilo Code — Log 328)

> Retome del núcleo iter. 1 (Log 298). Enfoque: cerrar el circuito de eventos de
> infraestructura (dominio `infra` en EventBus) y exponer la API de consulta del
> flujo, con verificación headless.

### Cambios de código

| Archivo | Cambio |
|---|---|
| `scripts/core/event_bus.gd` | + dominio `infra` (InfraEvents): `game_flow_changed(anterior, nuevo)`, `carga_iniciada(ruta)`, `carga_completada(ruta)`, `boot_completado()` — aditivo, sin romper dominios existentes |
| `scripts/core/game_flow_manager.gd` | + `transiciones_permitidas()` (copia, para UI pausa/menú); `cambiar_estado()` reenvía el cambio por `EventBus.infra.game_flow_changed` (vía `get_node_or_null`, sin class_name) |
| `scripts/core/scene_manager.gd` | `cambiar_escena()` y `_do_cambio()` reenvían `carga_iniciada`/`carga_completada` por `EventBus.infra` |
| `scripts/core/test_infraestructura_m40.gd` | **NUEVO**: test headless del flujo (28 checks) |

### Cobertura del test (28/0 OK)

- Dominio infra presente y señales declaradas.
- Transiciones válidas (BOOT→MUNDO, MUNDO→PAUSA, PAUSA→MUNDO, MUNDO→MENU, MENU→CARGANDO, CARGANDO→MUNDO, ERROR→BOOT) e ilegales (PAUSA→BOOT rechazada sin mutar estado).
- `transiciones_permitidas()` en estado actual.
- Reenvío por `EventBus.infra.game_flow_changed` (2 eventos medidos con estado normalizado).
- SceneManager: rechazo de ruta inexistente, aceptación de escena válida, anti doble-click, señales infra emitidas.

Comando: `Godot --headless --path game/isla-ancestral --script res://scripts/core/test_infraestructura_m40.gd`

### Verificación

- Test M40: **28/0 OK**.
- Boot del proyecto headless: `[M40] Flujo: 0 -> 3`, `DOM-INF integridad OK: 9 dominios`, DataStore M60 sin errores.
- Regresión M60: **66/0 OK** (EventBus compartido sin romper).

### Pendientes con dueño (siguiente iteración)

- Menú real (`main_menu.tscn` — M89/M53) y flujo BOOT→MENU→CARGANDO→MUNDO completo (M63).
- Escenas `boot.tscn` / `error.tscn` con motivo i18n y reintento (D10).
- Diagnóstico estático RF10 (cicl ImportScan) — `diagnostico.gd`.
- `limpiar_receptor(nodo)` en EventBus (poda de suscriptores huérfanos).
- GameState real como datopia (lo cubre parcialmente M60/M59).
- Progreso visual de carga en transiciones (M63).

### Notas del Agente (iter. 2)

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Parcial (núcleo + circuito de eventos infra), 🟡 liberado a QA cruzado

- Los 2 `[?]` del checklist corresponden a divergencias deliberadas D8 (BOOT y CARGANDO permiten rutas extra del prototipo sin menú); se mantienen hasta que M89/M63 cierren el flujo canónico.
- El dominio `infra` es aditivo: 40 módulos existentes emiten por sus propios dominios; no se tocó ninguna señal existente.

## Implementación real iter. 3 (2026-11-01, DeepSeek-V4.1-Flash / WorkBuddy — Log 2297)

**Tarea:** ítem 9 de la COLA ACTIVA — «M40 b3: cierre (integración GameFlowManager/SceneManager)».

### Premisa medida ANTES de escribir (nada heredado)

- M40 en disco: **210 [x] / 1 [ ] / 0 [?] = 211**. El único `[ ]` (L261) es el ítem inválido
  por diseño ya declarado; no hay implementación pendiente marcada.
- `SceneManager.cambiar_escena()`: **0 llamadores de producción** (los 6 hits son de las 2 suites);
  `Bootstrap._load_main_scene()` usaba `change_scene_to_file` directo.
- Señales locales del SceneManager (`cambio_iniciado` / `cambio_completado` / `cambio_fallido`):
  **0 consumidores** en todo `game/isla-ancestral`.
- `GameFlowManager.cambiar_estado(Estado.ERROR)`: **0 llamadores de producción** (sólo suites).
- `infra.boot_completado`: declarada en `event_bus.gd:171`, **0 emisores**.
- `escena_actual()`, exigido por `03-Diseno.md` §5.5: **0 apariciones** en `scripts/core/`.
- `bootstrap.gd` llevaba el flujo a MUNDO con un **`3` literal**.

=> La «integración» era **nominal**: dos APIs correctas y ninguna en una ruta de producción.
El patrón es el mismo falso verde del `track_*` de M105 (la API existe, el consumidor no).

### Implementado

1. **`scene_manager.gd` (+89/−4).** `MODO_SIN_FLUJO = -1`; `_modo_pendiente`;
   `cambiar_escena(ruta, modo)` (durante la carga → CARGANDO, al completar → `modo`, si falla →
   ERROR); `estado_flujo(nombre)` (resuelve el enum **por nombre**, fail-closed a −1);
   `sincronizar_flujo(nuevo)` (idempotente, avisa nombrando ambos estados, nunca rompe la carga);
   `_sincronizar_error(modo)`; `escena_actual()`; `verificar()` (auditoría que no muta estado).
2. **`bootstrap.gd` (+48/−9).** El flujo se lleva a MUNDO **por nombre a través de SceneManager**
   (fallback al enum del propio GameFlowManager): se eliminó el `3` mágico. Se emite
   `infra.boot_completado` al final de la secuencia de arranque, con flag de idempotencia.
3. **`test_infraestructura_m40.gd` (iter. 3).** Bloque nuevo `integracion_flujo` (14 checks) y
   aserciones de flujo dentro del bloque `scene_manager`.

### Defecto propio encontrado y corregido en la MISMA suite

`_test_scene_manager` es una **corrutina** (`await process_frame`) y se llamaba **sin `await`**
desde `_run`: `_summary()` corría antes de que la corrutina despertara y `quit(0)` cerraba el árbol.
Medido en la corrida previa: la suite publicaba **28 checks / 0 fallos / «todos los checks
pasaron»** y los **2 últimos checks NUNCA se ejecutaban** (`carga_iniciada`, `carga_completada`);
el `[M40] Escena cargada: …` aparecía **después** del resumen. Falso verde por corrutina no
esperada, del mismo tipo que el `_summary()` diferido que hubo que introducir en M88/M125.
También se reemplazó una aserción **infalsificable** (`gfm.has_method("transiciones_permitidas")`)
por el contrato real (mutar la copia no toca `TRANSICIONES`).

### Evidencia medida (Godot 4.7.2 headless, binario real)

- Suite: **60 checks / 0 fallos / 7 bloques / EXIT 0 ×3**, **0 SCRIPT ERROR**. Piso
  `CHECKS_MINIMOS = 60` **MEDIDO** en verde (no estimado ni copiado).
- Guardián **EN ROJO ×3**, con restauración **byte-exacta por sha256** verificado:
  - **S1** `sincronizar_flujo` neutralizado (no llama al GameFlowManager) → **EXIT 1**,
    **6 fallos** nombrados: «el flujo quedó en MUNDO estado=0», «transición prohibida MUNDO->BOOT
    rechazada», «el flujo no mutó tras el rechazo», «carga fallida con modo → flujo en ERROR
    estado=0», «durante la carga el flujo es CARGANDO estado=0», «tras la carga el flujo es
    MUNDO estado=0».
  - **S2** aborto de **runtime** al inicio del bloque `integracion_flujo` → **EXIT 1**,
    `[FAIL] bloques que NO se ejecutaron: ["integracion_flujo"]` + `[FAIL] solo 37 checks
    ejecutados (minimo 60)`: la capa de nombres **no** es ciega.
  - **S3** piso subido a 999 → **EXIT 1** (`solo 60 checks ejecutados (minimo 999)`).
- Arranque real headless: `[M40] Flujo: 0 -> 3`, `[Bootstrap] GameFlowManager -> MUNDO (via
  SceneManager)`, `[Bootstrap] infra.boot_completado emitido`, **0 SCRIPT ERROR**.

### Divergencias declaradas (propuestas, NO aplicadas a las marcas)

- **D40-1** — `modo` = estado objetivo **al completar** la carga (no «modo de transición»), y con
  `MODO_SIN_FLUJO` el flujo no se toca. Es la única lectura que generaliza: cargar un menú debe
  terminar en MENU, no en MUNDO.
- **D40-2** — `03-Diseno.md` §4 declara `TRANSICION` y el enum no lo tiene: `estado_flujo("TRANSICION")`
  devuelve **−1** y la suite lo fija como contrato (fail-closed, no se inventa un estado).
- **D40-3** — una carga fallida deriva a ERROR **sólo** si el llamador pidió flujo (`modo` ≠ −1):
  una ruta mala de un llamador legado no debe mandar el juego entero a ERROR.
