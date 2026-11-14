# Reporte: dependencias circulares y acoplamiento entre autoloads `core`

**Agente:** Glyph Cluster  
**Fecha:** 2026-11-13  
**Alcance:** `game/isla-ancestral/scripts/core/*.gd`, `scripts/core/invariants/*`, `scripts/core/recovery/*` y orden de autoloads en `game/isla-ancestral/project.godot`.  
**Excluido (ya auditado según encargo):** análisis profundo interno de EventBus/ServiceRegistry como contrato aislado; se consideran solo sus interacciones con otros autoloads `core`.

## Metodología

- Inventario de autoloads desde `[autoload]` en `project.godot`.
- Revisión de `get_node_or_null("/root/...")`, `preload/load`, `connect` y acceso a servicios/dominios en `scripts/core`.
- Lectura completa de: `bootstrap.gd`, `scene_manager.gd`, `game_flow_manager.gd`, `softlock_guard.gd`, `service_registry.gd`, `event_bus.gd`, `event_bus_spy.gd`, `contratos.gd`, `sesion_master.gd`, `terrain_locator.gd`, `softlock_rules.gd`, `recovery/checkpoint_manager.gd`, `invariants/mision_invariant.gd`.

## Resumen ejecutivo

- **No se detectó un ciclo de `preload/load` entre scripts de autoloads `core`** (los `preload` de `softlock_guard.gd` apuntan a clases auxiliares locales de invariantes/recovery, no a otros autoloads).
- **Sí hay un grafo de dependencias runtime fuertemente acoplado** entre `Bootstrap`, `SceneManager`, `GameFlowManager`, `EventBus` y (en menor grado) `ServiceRegistry`/`SoftlockGuard`, basado en rutas `/root/...` y en el orden de inicialización diferida.
- **Riesgo principal:** acoplamiento implícito de arranque (deferred order + presencia de nodos) y dependencia de señales/contratos externos no garantizados en builds parciales.

## Hallazgos

### 1. Acoplamiento bidireccional implícito SceneManager ↔ GameFlowManager (mediado por `/root`, sin interfaz explícita)

**Severidad:** Alta

**Evidencia**
- `game/isla-ancestral/scripts/core/scene_manager.gd:28-30` — `cambiar_escena(..., modo)` recibe un estado objetivo del flujo (`modo`) y documenta integración con GameFlowManager.
- `game/isla-ancestral/scripts/core/scene_manager.gd:46-48` — al iniciar carga con `modo != MODO_SIN_FLUJO`, fuerza `CARGANDO` vía `sincronizar_flujo(estado_flujo("CARGANDO"))`.
- `game/isla-ancestral/scripts/core/scene_manager.gd:67-73` — al completar carga aplica el estado objetivo pendiente llamando a `sincronizar_flujo(objetivo)`.
- `game/isla-ancestral/scripts/core/scene_manager.gd:82-88` — emite eventos de carga en `EventBus.infra` (`carga_iniciada`, `carga_completada`) por `/root/EventBus`.
- `game/isla-ancestral/scripts/core/scene_manager.gd:95-96` — resuelve GameFlowManager con `get_node_or_null("/root/GameFlowManager")`.
- `game/isla-ancestral/scripts/core/scene_manager.gd:101-109` — lee el enum `Estado` del GFM por reflexión (`gfm.get("Estado")`) para evitar números mágicos.
- `game/isla-ancestral/scripts/core/scene_manager.gd:114-129` — `sincronizar_flujo` invoca `gfm.cambiar_estado(...)` y depende de `get_estado()`.
- `game/isla-ancestral/scripts/core/game_flow_manager.gd:67-73` — GFM reenvía cada cambio por `EventBus.infra.game_flow_changed`.

**Análisis**
- No hay referencia circular directa de scripts, pero existe **ciclo funcional de coordinación**: SceneManager decide transiciones de flujo y las ejecuta en GFM; GFM publica cambios en EventBus.infra; otros sistemas (p.ej. SoftlockGuard) reaccionan a señales de carga/flujo. El contrato está disperso entre tres nodos y nombres de señal/enum resueltos dinámicamente.
- SceneManager conoce detalles internos del enum de GFM (`Estado` por nombre) y su API (`cambiar_estado/get_estado`), lo que genera acoplamiento fuerte y frágil ante refactors del flujo.

**Impacto**
- Cambios en nombres de estados, firma de métodos o señales `infra` pueden romper la sincronización en runtime sin fallo de compilación.
- Dificulta testear SceneManager/GFM aisladamente (dependen de autoloads concretos en `/root`).

### 2. Orquestación de arranque sensible al orden de `call_deferred` y a la disponibilidad tardía de autoloads (Bootstrap como punto de convergencia)

**Severidad:** Alta

**Evidencia**
- `game/isla-ancestral/project.godot` — orden relevante de autoloads: `EventBus` (temprano), `ServiceRegistry`, `GameFlowManager`, `SceneManager`, `Bootstrap` (tardío respecto a GFM/SM, pero `Bootstrap._ready` agenda trabajo diferido).
- `game/isla-ancestral/scripts/core/bootstrap.gd:44-58` — `_ready` registra/valida y encola en orden: `_verificar_game_flow`, `_autoregistrar_dominios`, `verificar_integridad_dominios`, `_load_main_scene`, `_anunciar_boot_completado` (todos `.call_deferred()`).
- `game/isla-ancestral/scripts/core/bootstrap.gd:64-84` — `_autoregistrar_dominios` registra en ServiceRegistry nodos resueltos por `/root/<Nombre>` incluyendo `game_flow`→`GameFlowManager` y `scene_manager`→`SceneManager`.
- `game/isla-ancestral/scripts/core/bootstrap.gd:91-117` — `_verificar_game_flow` obtiene GFM/SM por `/root`, resuelve estado `MUNDO` vía `SceneManager.estado_flujo("MUNDO")` o leyendo enum de GFM, y aplica `sincronizar_flujo`/`cambiar_estado`.
- `game/isla-ancestral/scripts/core/bootstrap.gd:126-134` — `_anunciar_boot_completado` emite `EventBus.infra.boot_completado` si existe la señal.
- `game/isla-ancestral/scripts/core/bootstrap.gd:147-160` — registra `event_bus` y `service_registry` en el propio ServiceRegistry.

**Análisis**
- Bootstrap actúa como **hub de composición**: depende de EventBus, ServiceRegistry, GameFlowManager y SceneManager simultáneamente. Aunque usa deferred para mitigar orden, la corrección depende de que (a) esos autoloads existan y estén inicializados, (b) los métodos/propiedades esperados estén presentes, y (c) el orden relativo de las tareas diferidas siga siendo el asumido.
- `_autoregistrar_dominios` corre diferido pero **no hay garantía explícita** de que se ejecute antes de consumidores que consulten `ServiceRegistry` en su propio deferred/ready tardío (patrón común en el proyecto). El propio registro de `event_bus`/`service_registry` ocurre en `_ready` de Bootstrap (tardío en lista de autoloads), lo que puede dejar una ventana donde dominios consultan antes de estar poblados.

**Impacto**
- Riesgo de fallos intermitentes de arranque en builds parciales o si se reordena el `[autoload]`/se añaden `call_deferred` adicionales.
- Acoplamiento temporal difícil de razonar ("funciona porque el deferred se encoló en este orden").

### 3. SoftlockGuard acoplado a señales de autoloads de infraestructura y persistencia (`EventBus.infra`, `SaveManager`) en inicialización

**Severidad:** Media

**Evidencia**
- `game/isla-ancestral/scripts/core/softlock_guard.gd:70-77` — `_conectar_disparos()` conecta:
  - `/root/EventBus` → `bus.infra.carga_iniciada` (si `bus.infra` y la señal existen) para forzar chequeo en transición de escena.
  - `/root/SaveManager` → `save_completed` para forzar chequeo tras guardado.
- `game/isla-ancestral/scripts/core/softlock_guard.gd:61-68` — `_ready` instancia `CheckpointManager`/cofre, registra invariantes y llama `_conectar_disparos()`.

**Análisis**
- Dependencia cruzada core↔infra/persistencia: SoftlockGuard (core) depende de contratos de señales definidos en EventBus y expuestos por SaveManager (autoload fuera de `core`). Si EventBus.infra no expone `carga_iniciada` o SaveManager no tiene `save_completed`, el guard queda silenciosamente sin disparadores de esos eventos (best-effort), lo que es correcto para resiliencia pero constituye **acoplamiento implícito de contrato**.
- No forma ciclo de inicialización directo con `core`, pero completa el triángulo de eventos de carga: `SceneManager -> EventBus.infra.carga_iniciada -> SoftlockGuard`.

**Impacto**
- Chequeos anti-softlock pueden no ejecutarse en transiciones/guardados si el contrato de señal cambia, sin error explícito (degradación silenciosa).

### 4. Dependencias runtime desde invariantes/recovery hacia servicios externos (no cíclicas, pero ocultas)

**Severidad:** Media

**Evidencia**
- `game/isla-ancestral/scripts/core/invariants/mision_invariant.gd:68-75` — en `activar_fallback` accede a `/root/Diary` (`arbol.root.get_node_or_null("/root/Diary")`) y, si existe, registra entrada de descubrimiento.
- `game/isla-ancestral/scripts/core/recovery/checkpoint_manager.gd:64` — construye contenido con `SaveWriter.build_file_content(SaveWriter.serialize_payload(payload))` y usa `SaveWriter.parse_document(...)` sin `preload` local (dependencia de clase global/autoload/script registrado externamente).
- `game/isla-ancestral/scripts/core/softlock_guard.gd:14-22` — `preload` de invariantes y recovery bajo `scripts/core/...` (dependencias estáticas internas del subsistema, no entre autoloads).

**Análisis**
- Estas dependencias no crean ciclos entre autoloads `core`, pero **ocultan acoplamiento**: el comportamiento de recuperación/diario/checkpoint depende de servicios globales no inyectados (`Diary`, `SaveWriter`). Dificulta pruebas headless aisladas del módulo anti-softlock.

**Impacto**
- Fallos o ausencia de `Diary`/`SaveWriter` alteran efectos secundarios (registro en diario, persistencia de checkpoint) sin que el grafo de autoloads `core` lo evidencie.

### 5. `SesionMaster` define contrato de orquestación pero no está activo como autoload (deuda de convergencia, no ciclo actual)

**Severidad:** Baja

**Evidencia**
- `game/isla-ancestral/scripts/core/sesion_master.gd:1-27` — declara `class_name SesionMaster` y documenta que **no existe ningún SesionMaster activo**; el arranque real sigue siendo `main_island.tscn` + autoloads.
- `game/isla-ancestral/scripts/core/sesion_master.gd:33-47` — `inicializar()` describe capas (Infra → World Services → Managers → UI) pero no realiza wiring real.
- `game/isla-ancestral/project.godot` — no hay entrada `SesionMaster` en `[autoload]`.

**Análisis**
- No introduce dependencia circular hoy. Sin embargo, si se activa en el futuro como orquestador único, coexistirá con la lógica actual de `Bootstrap`/`SceneManager`/`GameFlowManager` a menos que se migre explícitamente, creando riesgo de doble orquestación.

**Impacto**
- Riesgo arquitectónico futuro (duplicación de fuentes de verdad del boot/flujo), no un bug de dependencia presente.

## Grafo de dependencias observado (runtime, simplificado)

- `Bootstrap` → `/root/ServiceRegistry`, `/root/EventBus`, `/root/GameFlowManager`, `/root/SceneManager`, `ResourceLoader/change_scene`.
- `SceneManager` ↔(coordinación) `GameFlowManager` vía `/root` + llamadas directas; `SceneManager` → `EventBus.infra` (`carga_iniciada/completada`).
- `GameFlowManager` → `EventBus.infra` (`game_flow_changed`).
- `SoftlockGuard` → `EventBus.infra.carga_iniciada`, `/root/SaveManager.save_completed`; internamente carga invariantes/recovery (preload local) que tocan `/root/Diary` y `SaveWriter` global.
- `ServiceRegistry`/`EventBus`: base consultada por los anteriores (sin ciclo de script detectado).

## Conclusión

En `scripts/core` no se identificaron **dependencias circulares de carga** (`preload/load`) entre autoloads, pero sí un **núcleo de acoplamiento runtime** centrado en `Bootstrap`/`SceneManager`/`GameFlowManager`/`EventBus.infra` con resolución dinámica por `/root` y orden diferido. La mitigación recomendada es introducir contratos explícitos e inyección/mediación para reducir lookups globales y acoplamiento temporal.

## Mejora de diseño 1 (concreta): puerto de flujo inyectable para `SceneManager` (desacoplar de GFM/EventBus por `/root`)

**Objetivo:** que `SceneManager` dependa de una interfaz pequeña (`IFlowPort`) en vez de conocer `/root/GameFlowManager`, el enum `Estado` y `EventBus.infra`.

**Código propuesto (nuevo archivo sugerido: `game/isla-ancestral/scripts/core/flow_port.gd`)**

```gdscript
class_name FlowPort
extends RefCounted

## Puerto mínimo para orquestar flujo/carga sin acoplar SceneManager a nodos concretos.
func estado(nombre: String) -> int:
	return -1

func sincronizar(nuevo: int) -> bool:
	return false

func emitir_carga(evento: String, ruta: String) -> void:
	pass
```

**Adaptador autoload-aware (ej. inyectado por Bootstrap o resuelto una vez):**

```gdscript
# flow_port_autoload.gd (ejemplo de uso interno)
class_name FlowPortAutoload
extends FlowPort

var _tree: SceneTree

func _init(tree: SceneTree) -> void:
	_tree = tree

func _gfm() -> Node:
	return _tree.root.get_node_or_null("GameFlowManager") if _tree else null

func _bus() -> Node:
	return _tree.root.get_node_or_null("EventBus") if _tree else null

func estado(nombre: String) -> int:
	var gfm := _gfm()
	if gfm == null:
		return -1
	var valores: Variant = gfm.get("Estado")
	return int(valores[nombre]) if valores is Dictionary and valores.has(nombre) else -1

func sincronizar(nuevo: int) -> bool:
	if nuevo < 0:
		return false
	var gfm := _gfm()
	if gfm == null or not gfm.has_method("cambiar_estado") or not gfm.has_method("get_estado"):
		return false
	if int(gfm.get_estado()) == nuevo:
		return true
	return bool(gfm.cambiar_estado(nuevo))

func emitir_carga(evento: String, ruta: String) -> void:
	var bus := _bus()
	if bus == null:
		return
	var infra: Variant = bus.get("infra")
	if infra != null and infra is Object and infra.has_signal(evento):
		infra[evento].emit(ruta)
```

**Cambio en `scene_manager.gd` (extracto):**

```gdscript
var _flow_port: FlowPort = null

func set_flow_port(port: FlowPort) -> void:
	_flow_port = port

func _port() -> FlowPort:
	if _flow_port == null:
		_flow_port = FlowPortAutoload.new(get_tree()) # fallback compatible
	return _flow_port

func _emitir_infra(evento: String, ruta: String) -> void:
	_port().emitir_carga(evento, ruta)

func estado_flujo(nombre: String) -> int:
	return _port().estado(nombre)

func sincronizar_flujo(nuevo: int) -> bool:
	return _port().sincronizar(nuevo)
```

**Beneficio:** elimina lookups repetidos a `/root`, centraliza el contrato de flujo/carga y permite tests con un `FlowPort` falso sin montar autoloads reales.

## Mejora de diseño 2 (concreta): fase de arranque explícita en `Bootstrap` con readiness checks (reducir acoplamiento temporal por `call_deferred`)

**Objetivo:** reemplazar la cadena implícita de `call_deferred` por una secuencia determinista basada en verificación de disponibilidad de dependencias críticas y reporte de estado.

**Cambio propuesto en `bootstrap.gd` (extracto):**

```gdscript
enum BootPhase { CORE, FLOW_READY, DOMAINS, SCENE, ANNOUNCED }

var _phase: int = BootPhase.CORE

func _ready() -> void:
	print("=== Bootstrap Iniciando ===")
	_register_core_services()
	_validate_services()
	_try_advance_boot.call_deferred()

func _deps_flow_ready() -> bool:
	return get_node_or_null("/root/ServiceRegistry") != null \
		and get_node_or_null("/root/EventBus") != null \
		and get_node_or_null("/root/GameFlowManager") != null \
		and get_node_or_null("/root/SceneManager") != null

func _try_advance_boot() -> void:
	match _phase:
		BootPhase.CORE:
			if not _deps_flow_ready():
				_try_advance_boot.call_deferred() # reintento acotado en implementación real
				return
			_verificar_game_flow()
			_autoregistrar_dominios()
			verificar_integridad_dominios()
			_phase = BootPhase.SCENE
			_try_advance_boot.call_deferred()
		BootPhase.SCENE:
			_load_main_scene()
			_phase = BootPhase.ANNOUNCED
			_anunciar_boot_completado()
			print("=== Bootstrap Completado ===")
```

**Beneficio:** hace explícitas las dependencias de arranque, evita asumir que "el siguiente deferred ya tiene todo listo" y facilita instrumentar/loggear en qué fase falla un build parcial.

## Observaciones adicionales (fuera de ciclo, relevantes)

- `game/isla-ancestral/scripts/core/contratos.gd:1-4` centraliza contratos como `StringName` (buena dirección); extender su uso a eventos/señales críticas de `infra` reduciría strings mágicos.
- `game/isla-ancestral/scripts/core/event_bus_spy.gd` es herramienta de observabilidad (no autoload) y no introduce ciclo; útil para validar en runtime los flujos descritos.
- No se hallaron `preload()`/`load()` desde autoloads `core` hacia otros scripts de autoloads `core`; el acoplamiento observado es principalmente **dinámico por árbol de escena (`/root`) y señales**.
