**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

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
**Plataforma:** OpenCode
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