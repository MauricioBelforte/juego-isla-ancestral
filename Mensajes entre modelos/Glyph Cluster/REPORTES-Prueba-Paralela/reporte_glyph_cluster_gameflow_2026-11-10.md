# Reporte: GameFlowManager, transiciones de escena y estado de juego

- **Modelo:** Glyph Cluster (kilo/stealth/glyph-cluster)
- **Plataforma:** Kilo Code
- **Fecha:** 2026-11-11 23:47 (UTC)
- **Alcance:** `game/isla-ancestral/scripts/core/` y referencias directas en `game/isla-ancestral/project.godot` y pruebas del core.

## Archivos analizados

| Archivo | Rol observado |
|---|---|
| `game/isla-ancestral/scripts/core/game_flow_manager.gd` (73 líneas) | Máquina de estados lógica del flujo de juego (autoload `GameFlowManager`). |
| `game/isla-ancestral/scripts/core/scene_manager.gd` (160 líneas) | Cambio de escenas raíz con bloqueo de concurrencia e integración opcional con flujo. |
| `game/isla-ancestral/scripts/core/event_bus.gd` (199 líneas) | Bus global de señales por dominios; incluye `infra.game_flow_changed` y eventos de carga. |
| `game/isla-ancestral/scripts/core/event_bus_spy.gd` (106 líneas) | Espía de señales del EventBus para debug (no participa en flujo/escenas). |
| `game/isla-ancestral/scripts/core/bootstrap.gd` (223 líneas) | Registro/validación de servicios, sincronización inicial de flujo y carga de escena principal. |
| `game/isla-ancestral/scripts/core/service_registry.gd` (75 líneas) | Registro central de servicios por contrato string. |
| `game/isla-ancestral/scripts/core/contratos.gd` (93 líneas) | Constantes `StringName` de contratos para ServiceRegistry. |
| `game/isla-ancestral/project.godot` (autoloads) | Orden/registro de autoloads: `EventBus` (L22), `ServiceRegistry` (L26), `Bootstrap` (L40), `GameFlowManager` (L95), `SceneManager` (L96). |

Evidencia de uso cruzado: `rg` sobre `game/isla-ancestral` muestra referencias a `GameFlowManager`, `EventBus.infra.game_flow_changed`, `cambiar_estado`, `SceneManager` y sincronización en `scripts/core/test_infraestructura_m40.gd`, `scripts/core/test_infraestructura.gd`, `scripts/ui/ui_root.gd`, `scripts/ui/test_m89_menus.gd`, entre otros.

## 1) ¿Cómo se gestionan las transiciones entre escenas principales?

### 1.1 Orquestación de cambio de escena (`SceneManager`)
- **Archivo:** `game/isla-ancestral/scripts/core/scene_manager.gd`
- **Señales:** `cambio_iniciado(ruta)`, `cambio_completado(ruta)`, `cambio_fallido(ruta, motivo)` (L13-L15).
- **API principal:** `cambiar_escena(ruta: String, modo: int = MODO_SIN_FLUJO) -> bool` (L32).
  - **Concurrencia / anti doble-click:** si `_cargando` es `true` rechaza y avisa (L33-L35). `esta_cargando()` expone el flag (L76-L77).
  - **Validación de recurso:** ruta vacía o inexistente (`ResourceLoader.exists`) provoca `cambio_fallido(..., "escena_inexistente")`, sincroniza ERROR solo si `modo != MODO_SIN_FLUJO` y retorna `false` (L36-L40, L133-L137).
  - **Integración opcional con flujo:** guarda `_modo_pendiente` y, si hay modo, lleva el flujo a `CARGANDO` antes de iniciar (`estado_flujo("CARGANDO")` + `sincronizar_flujo`) (L42-L44).
  - **Notificación:** emite `cambio_iniciado` y reenvía por `EventBus.infra.carga_iniciada` (L45-L46, L81-L88).
  - **Cambio diferido:** usa `call_deferred("_do_cambio", ruta)` para evitar cambiar escena durante `_ready/_input` (L47-L48, comentario pitfall L7-L8).
- **Ejecución diferida:** `_do_cambio(ruta)` (L51-L73).
  - Obtiene `get_tree()`; si es `null` limpia `_cargando/_modo_pendiente` y aborta (L52-L56).
  - Ejecuta `tree.change_scene_to_file(ruta)` (L57). En error: limpia cargando, emite `cambio_fallido("error_%d")`, deriva a ERROR si el modo lo pedía (L58-L63).
  - En éxito: emite `cambio_completado`, reenvía `carga_completada` por EventBus, limpia pendiente y sincroniza el flujo al estado objetivo si se orquestó (L64-L73).
- **Diagnóstico:** `escena_actual()` devuelve `scene_file_path` de `current_scene` o `""` (L141-L145); `verificar()` expone estado de flujo, flags y escena actual sin mutar (L147-L160).

### 1.2 Carga de la escena principal en arranque (`Bootstrap`)
- **Archivo:** `game/isla-ancestral/scripts/core/bootstrap.gd`
- En `_ready()` registra/valida servicios y difiere verificación de flujo, autorregistro, integridad, carga de escena y anuncio de boot (L43-L57).
- `_load_main_scene()` (deferido, L187-L211):
  - Respeta escena personalizada por CLI: si `current_scene` ya existe y no es `MAIN_SCENE_PATH`, no redirige (L191-L195).
  - Verifica existencia de `MAIN_SCENE_PATH` (`res://scenes/main_island.tscn`, L36) y registra error si falta (L200-L202).
  - Evita recarga si el engine ya dejó activa la escena principal (L207-L209).
  - Llama `get_tree().change_scene_to_file(MAIN_SCENE_PATH)` (L211). **No pasa por `SceneManager` ni por su API de modo/flujo.**

### 1.3 Máquina de estados de flujo (no carga escenas)
- **Archivo:** `game/isla-ancestral/scripts/core/game_flow_manager.gd`
- Define `enum Estado { BOOT, MENU, CARGANDO, MUNDO, PAUSA, ERROR }` y tabla `TRANSICIONES` (L13-L25). Nota explícita: `BOOT->MUNDO` directo es ruta de prototipo (L16-L17).
- `cambiar_estado(nuevo)` valida transición, actualiza estado, emite señal local `estado_cambiado` y reenvía por EventBus; rechaza transiciones inválidas con `push_warning` y `false` (L34-L46). Expone `get_estado()`, `es_estado()`, `en_juego()`, `transiciones_permitidas()` (L48-L62).
- **No realiza** `change_scene_to_file`; solo gobierna estado lógico.

### 1.4 Orden de autoloads (contexto de inicialización)
- `project.godot` L22/L26/L40/L95/L96: `EventBus`, `ServiceRegistry`, `Bootstrap`, `GameFlowManager`, `SceneManager`. `Bootstrap` corre antes que GFM/SM y por eso sus interacciones con ellos se hacen `call_deferred` y con `get_node_or_null` (p.ej. L49-L54, L91-L115).

## 2) ¿Hay dependencias circulares entre GameFlowManager y otros autoloads?

**Conclusión: no se observan dependencias circulares (ni de carga/compilación ni de referencia directa entre nodos).**

| Relación | Evidencia | Tipo |
|---|---|---|
| `GameFlowManager` → `EventBus` | `get_node_or_null("/root/EventBus")` en `_emitir_por_event_bus` (game_flow_manager.gd L66-L73). Sin `preload`, sin `class_name` de bus, sin referencia a SM/Bootstrap/ServiceRegistry. | Runtime dinámico, unidireccional (emisión). |
| `GameFlowManager` → otros | No hay referencias a `SceneManager`, `Bootstrap`, `ServiceRegistry` en el archivo. | Ninguna. |
| `SceneManager` → `GameFlowManager` | `_game_flow()` usa `get_node_or_null("/root/GameFlowManager")`; `estado_flujo` lee enum por nombre; `sincronizar_flujo` invoca `cambiar_estado/get_estado` (scene_manager.gd L94-L128). Sin acoplamiento en tiempo de compilación. | Runtime dinámico, unidireccional. |
| `SceneManager` → `EventBus` | `_emitir_infra` usa `get_node_or_null("/root/EventBus")` (scene_manager.gd L81-L88). | Runtime dinámico. |
| `Bootstrap` → `GameFlowManager`/`SceneManager`/`EventBus`/`ServiceRegistry` | Accesos diferidos con `get_node_or_null` y llamadas por método (bootstrap.gd L78-L115, L126-L133, L138-L155, L164-L183). Registra dominios por nombres de nodo string (L64-L82). | Runtime diferido, sin ciclo. |
| `EventBus`/`ServiceRegistry`/`Contratos` → flujo/escenas | `EventBus` declara `InfraEvents.game_flow_changed` y comenta a GFM (event_bus.gd L160-L165) pero no referencia nodos/managers; ServiceRegistry/Contratos no referencian GFM/SM. | Ninguna dependencia inversa. |

Patrón común: resolución por `/root/...` + comprobaciones de `null`/`has_method`/`has_signal`, lo que evita ciclos de importación y tolera builds parciales, a costa de acoplamiento implícito por nombres de autoload/contratos.

## 3) ¿Hay validación de estado antes de transicionar escenas?

**Sí hay validaciones parciales, pero no una precondición fuerte de coherencia flujo↔escena que impida cargar cuando el estado lógico no lo permite.**

### Validaciones presentes
- **En `SceneManager.cambiar_escena`:** rechaza si ya hay carga en curso (`_cargando`) y si la ruta es vacía o el recurso no existe (scene_manager.gd L33-L40).
- **En `SceneManager._do_cambio`:** detecta fallo de `change_scene_to_file` y reporta/sincroniza error según corresponda (L57-L63). El árbol nulo se maneja abortando y limpiando flags (L52-L56).
- **En `GameFlowManager.cambiar_estado`:** valida contra la tabla `TRANSICIONES` y rechaza transiciones ilegales (`push_warning`, `false`) sin mutar estado (game_flow_manager.gd L37-L40). Esto actúa como guardia de la máquina de estados.
- **En `Bootstrap._load_main_scene`:** respeta escena CLI, verifica existencia y evita doble carga de la escena principal (bootstrap.gd L191-L209).

### Huecos / comportamiento observado
- **No hay pre-validación de transición de flujo antes de iniciar la carga de escena.** `SceneManager` intenta sincronizar a `CARGANDO` y luego al `modo` objetivo mediante `sincronizar_flujo()` (scene_manager.gd L44, L72-L73), pero `sincronizar_flujo()` es *best-effort*: si el GFM rechaza la transición devuelve `false` y emite warning, **sin abortar ni revertir el cambio de escena** (scene_manager.gd L111-L128). Por tanto, una escena puede quedar cargada con un estado de flujo inconsistente si la transición es inválida.
- **`cambiar_escena` no comprueba** que el estado actual permita ir a `CARGANDO` ni que `modo` sea alcanzable desde el flujo previsto; delega esa verificación al resultado tardío de `cambiar_estado`.
- **Bootstrap** carga la escena principal por `change_scene_to_file` directo (bootstrap.gd L211) y sincroniza el flujo por separado/ruta diferida (L90-L115), sin una validación unificada previa escena+flujo.

Las pruebas (`test_infraestructura_m40.gd`, `test_infraestructura.gd`) cubren transiciones válidas/ilegales del GFM y aspectos de integración, lo que confirma que la validación existe a nivel de estado pero no como barrera previa obligatoria de la operación de carga.

## 4) ¿Hay problemas de referencia circular entre GameFlowManager y EventBus?

**Conclusión: no se observan referencias circulares entre `GameFlowManager` y `EventBus`.**

- **Dirección `GameFlowManager` → `EventBus` (solo emisión, en runtime):**
  - `game_flow_manager.gd` L64-L73 (`_emitir_por_event_bus`): resuelve el bus con `get_node_or_null("/root/EventBus")`, obtiene el dominio `infra`, comprueba `has_signal("game_flow_changed")` y emite `infra.game_flow_changed(anterior, nuevo)`. No guarda referencia persistente al bus, no importa su script y no depende de tipos en compilación.
- **`EventBus` no referencia a `GameFlowManager`:**
  - `event_bus.gd` L38-L39 instancia `InfraEvents`; L160-L165 define `InfraEvents.game_flow_changed` y documenta que el cambio lo origina `GameFlowManager`, pero **no** accede a `/root/GameFlowManager`, no carga su script ni invoca sus métodos. Es un contenedor pasivo de señales/dominios.
- **Consumo indirecto esperado (sin ciclo):** otros sistemas pueden escuchar `EventBus.infra.game_flow_changed` (pruebas: `test_infraestructura_m40.gd` L145-L171, L205-L212 conectan a la señal), lo cual es comunicación desacoplada por señal, no una dependencia circular entre GFM y EventBus.
- **`EventBusSpy`:** se acopla al bus recibido por parámetro para observar señales (event_bus_spy.gd L35-L68) y no interviene ni referencia a GFM.

Riesgo residual observado (no circularidad): el reenvío depende de la presencia del autoload `EventBus`, del dominio `infra` y de la señal `game_flow_changed`; si faltan, GFM simplemente no reenvía (L68-L72). Esto es tolerante pero silencioso desde la perspectiva de consumidores que esperen el evento vía bus.

## 5) Sugerencias de mejora

### Mejora 1 — Prevalidar coherencia de flujo antes de ejecutar el cambio de escena
- **Problema:** `SceneManager` sincroniza el flujo de forma *best-effort* (scene_manager.gd L44, L72-L73, L111-L128). Si `GameFlowManager.cambiar_estado` rechaza una transición, la carga de escena puede completarse igualmente, dejando desalineados estado lógico y escena activa.
- **Propuesta:**
  1. En `cambiar_escena`, antes de `call_deferred("_do_cambio")`, verificar que el estado actual del GFM permite transitar a `CARGANDO` y que el `modo` objetivo es alcanzable según la secuencia esperada (p.ej. consultar `transiciones_permitidas()`/`get_estado()` del GFM o simular la validez de la ruta de estados).
  2. Si la prevalidación falla, emitir `cambio_fallido(ruta, "transicion_flujo_invalida")` con detalle (estado actual → esperado), **no** marcar `_cargando` ni diferir la carga, y retornar `false`.
  3. Mantener `sincronizar_flujo` como defensa en profundidad, pero registrar como error (no solo warning) cualquier rechazo durante una carga ya validada, para detectar divergencias reales.
- **Beneficio:** evita estados inconsistentes escena/flujo, facilita diagnóstico y refuerza la máquina de estados como fuente de verdad.
- **Referencias:** scene_manager.gd L32-L49, L67-L73, L111-L128; game_flow_manager.gd L18-L25, L34-L46, L60-L62.

### Mejora 2 — Unificar la orquestación de transición inicial y de carga principal
- **Problema:** la ruta de arranque duplica lógica entre `Bootstrap` y `SceneManager`. `Bootstrap` carga la escena principal con `change_scene_to_file` directo (bootstrap.gd L187-L211) y resuelve/sincroniza el estado `MUNDO` por nombre con lógica propia y fallback (bootstrap.gd L90-L115), mientras `SceneManager` ya encapsula cambio diferido, señales, eventos de infra y resolución de estados por nombre (`estado_flujo/sincronizar_flujo`, scene_manager.gd L32-L49, L97-L128).
- **Propuesta:**
  1. Hacer que `Bootstrap._load_main_scene` delegue en `SceneManager.cambiar_escena(MAIN_SCENE_PATH, SceneManager.estado_flujo("MUNDO"))` (o en una API explícita tipo `cargar_escena_inicial(...)`) cuando proceda, respetando los casos especiales actuales (escena CLI y escena ya activa por el engine).
  2. Extraer la secuencia "resolver estado objetivo por nombre → sincronizar flujo" a un único punto (preferentemente `SceneManager` o helper interno del core) para eliminar la resolución duplicada del enum `Estado` que hoy existe en Bootstrap (L95-L109) y en SceneManager (L97-L109).
  3. Alinear el contrato de boot: si Bootstrap sigue necesitando garantizar `MUNDO`, que lo haga a través de la misma API de orquestación, reduciendo riesgo de divergencia (p.ej. cambios futuros en el enum o en transiciones válidas).
- **Beneficio:** una sola ruta canónica de transición escena+flujo, menor duplicación, comportamiento más predecible y pruebas más simples.
- **Referencias:** bootstrap.gd L49-L57, L90-L115, L187-L211; scene_manager.gd L21-L49, L67-L73, L90-L128.

## Conclusión final

El núcleo analizado implementa una separación clara de responsabilidades: `GameFlowManager` gobierna el estado lógico con una tabla explícita de transiciones y reenvío a `EventBus.infra`, mientras `SceneManager` gestiona el cambio de escena raíz de forma diferida, con control de concurrencia y notificación por señales/EventBus. `Bootstrap` inicializa/valida servicios y coordina el arranque de forma diferida respetando el orden de autoloads.

**No se detectan dependencias circulares** entre `GameFlowManager` y otros autoloads ni **referencias circulares** entre `GameFlowManager` y `EventBus`: las interacciones son dinámicas en runtime (`get_node_or_null`, señales) y mayormente unidireccionales. Las validaciones de existencia/concurrencia y de legalidad de transiciones de estado existen, pero la sincronización flujo↔escena es en gran medida *best-effort* y no impide cargar una escena ante una transición de flujo inválida o fallida. Las dos mejoras propuestas apuntan a endurecer esa coherencia y a unificar la orquestación de arranque/carga para reducir duplicación y riesgo de desincronización.
