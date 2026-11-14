# Reporte de análisis — `EventBus` y `ServiceRegistry`

**Modelo:** Glyph Cluster  
**Fecha:** 2026-11-13  
**Alcance analizado:**  
- `game/isla-ancestral/scripts/core/event_bus.gd` (199 líneas)  
- `game/isla-ancestral/scripts/core/service_registry.gd` (75 líneas)

**Metodología:** lectura completa de ambos archivos y búsqueda de usos en `game/isla-ancestral/scripts` (`EventBus.*`, `ServiceRegistry.*`, `.emit`, `.connect`, emisiones/conexiones por señal y dominio). Las conclusiones distinguen evidencia en código de producción vs. pruebas/QA cuando aplica.

---

## 1) ¿Hay acoplamiento fuerte entre sistemas que debería ser suelto?

**Hallazgo general:** `EventBus` implementa un bus global por dominios (patrón “Signal Up, Call Down”, `event_bus.gd:3-12`) y no importa dominios de juego, lo cual favorece desacoplamiento. Sin embargo, en la integración real aparecen acoplamientos fuertes o canales paralelos que debilitan ese objetivo.

### Evidencia

1. **Doble canal de eventos de inventario (servicio local vs. bus global) con firmas distintas.**
   - `InventarioService` declara y emite sus propias señales `item_added(item_id, cantidad, container)` / `item_removed(...)` (`scripts/inventario/inventario_service.gd:16-17,53,65,361`).
   - `EventBus.inventory` declara `item_added(item_id, quantity)` / `item_removed(item_id, quantity)` / `hotbar_selected(slot_index)` (`event_bus.gd:66-72`).
   - Consumidores se suscriben al bus: `scripts/saving/save_manager.gd:96-97`, `scripts/tutorial/tutorial_manager.gd:195-196`, `scripts/progresion/progression_manager.gd:152-153`, `scripts/logros/achievement_service.gd:140-141`, `scripts/ui/hud/hud_screen.gd:119-121`, `scripts/ui/layers/inventory_layer.gd:51-54`.
   - No se observaron emisiones de producción sobre `EventBus.inventory.*`; las emisiones encontradas sobre el bus son de tests (`scripts/saving/test_autosave_m59.gd:49`, `scripts/tutorial/test_tutorial_triggers.gd:54,62`, `scripts/progresion/test_*.gd`, etc.).  
   **Impacto:** acoplamiento implícito a “qué canal” usar; riesgo de que suscriptores del bus no reciban eventos reales de inventario y de divergencia de contrato (firma con/sin `container`).

2. **Contrato de viaje desconectado/mal alineado entre `TravelService` y `EventBus.travel`.**
   - `EventBus.travel` declara `travel_started(from_island, to_island)` e `island_loaded(island)` (`event_bus.gd:116-120`).
   - `TravelService` emite su propia señal `travel_started(route_id)` (`scripts/viajes/travel_service.gd:23,270`) con aridad/firma distinta; no se hallaron emisiones de producción sobre `EventBus.travel.travel_started`.
   - `scripts/progresion/progression_manager.gd:167-168` se conecta a `bus.travel.travel_started` esperando la firma del bus; `scripts/diario/diary_service.gd:113-114` escucha `bus.travel.island_loaded`.
   - `scripts/audio/narrative_sound.gd:54-58,68` documenta explícitamente que `EventBus.travel.island_loaded` existe pero “ningún dominio lo emite” y mantiene fallback. `scripts/diario/test_diario.gd:98` emite `island_loaded` solo en test.  
   **Impacto:** acoplamiento por contrato roto/duplicado: los sistemas dependen de señales del bus que no produce el dominio real, o de señales locales con otra firma.

3. **Señales de UI duplicadas (EventBus vs. `UIManager`).**
   - `EventBus.ui` declara `hud_request`, `layer_requested`, `confirm_requested`, `ui_layers_changed`, `ui_focus_moved`, etc. (`event_bus.gd:134-150`).
   - `UIManager` define y emite sus propias señales `ui_layers_changed` / `ui_focus_moved` (`scripts/ui/core/ui_manager.gd:22,24,247,276,358,368,457,643`) y escucha `EventBus.ui.hud_request/dialog_requested` (`ui_manager.gd:51-53,476`).  
   **Impacto:** dos canales para conceptos equivalentes; acopla a los consumidores a saber qué instancia observar.

4. **Dependencia extendida a rutas de autoload (`/root/...`) en lugar de contratos del registro.**
   - El proyecto usa `get_node_or_null("/root/EventBus")`, `/root/SaveManager`, `/root/GameTime`, `/root/GameFlowManager`, etc. de forma generalizada (≈71 ocurrencias de `/root/EventBus` en `scripts/`), p. ej. `diary_service.gd:101`, `tutorial_manager.gd:183`, `save_manager.gd:90`, `scene_manager.gd:84`, `game_flow_manager.gd:67`, `bootstrap.gd:125`.
   - `ServiceRegistry` ofrece resolución por contrato (`service_registry.gd:22-38,41-68`) y `core/contratos.gd` documenta su uso (`contratos.gd:4,12-13`), pero las búsquedas muestran uso efectivo limitado en runtime (p. ej. `telemetry/telemetry_director.gd:56`, `datos/test_datos_m60_iter4.gd:694`, tests de M40) frente al patrón de localización directa de nodos.  
   **Impacto:** acoplamiento fuerte a nombres/rutas de autoload y orden de montaje del árbol, más frágil ante refactors que un contrato centralizado.

**Conclusión (1):** el diseño del bus es correcto en intención, pero coexisten canales duplicados y contratos desalineados (inventario, viaje, UI) y un uso predominante de service-locator por ruta en vez de contratos; esto mantiene acoplamientos que deberían ser sueltos.

---

## 2) ¿Hay señales declaradas que nunca se emiten o nunca se conectan?

A continuación, señales de `event_bus.gd` con evidencia de **no emisión en producción detectada** y/o **sin conexiones detectadas** en `game/isla-ancestral/scripts` (excluyendo la propia declaración). “Sin emisión en producción” indica que solo se hallaron emisiones en tests/QA o ninguna.

| Dominio | Señal (líneas) | Emisión observada | Conexión observada | Observación |
|---|---|---|---|---|
| `world` | `block_placed` (50), `block_removed` (52) | Solo tests/QA (`test_arquitectura.gd:49`, `core/qa_m40_spy.gd:49-50,76`, `particles/test_vfx_m52_iter6.gd:263`) | Sí en varios sistemas (`tutorial_manager.gd:200-202`, `saving/save_manager.gd:100-101`, etc.) | Sin productor de dominio detectado. |
| `world` | `chunk_modified` (54) | No detectada | No detectada (solo comprobación en `core/qa_m40_spy.gd:56`) | Huérfana. |
| `world` | `biome_changed` (56) | Solo QA (`core/qa_m40_spy.gd:51`) | No detectada fuera de QA | Sin uso productivo. |
| `economy` | `currency_changed` (60), `purchase_done` (62), `debt_paid` (64) | No detectada | `purchase_done`/`currency_changed` tienen listeners (`logros/achievement_service.gd:142-143`, `progresion/progression_manager.gd:154-155`, `save_manager.gd:95`) | Señales escuchadas pero sin emisor en bus detectado. |
| `inventory` | `item_added` (68), `item_removed` (70) | Solo tests en bus (`saving/test_autosave_m59.gd:49`, `progresion/test_*.gd`, `tutorial/test_tutorial_triggers.gd:54,62`) | Sí, múltiples (`save_manager.gd:96-97`, `hud_screen.gd:119-120`, `inventory_layer.gd:51-54`, `achievement_service.gd:140-141`) | Productor real emite en `InventarioService`, no en bus (ver §1). |
| `inventory` | `hotbar_selected` (72) | No detectada | Sí (`ui/hud/hud_screen.gd:121`, `ui/widgets/hotbar_widget.gd:135-136`) | Sin emisor detectado. |
| `quest` | `quest_updated` (78) | Sí (`historias/secondary_stories_service.gd:380`) | **No detectada** | Se emite pero nadie la consume. |
| `calendar` | `vessel_arrived` (104) | No detectada | No detectada | Huérfana. |
| `travel` | `travel_started` (118) | No en bus (producción emite en `viajes/travel_service.gd:270` con otra firma) | Sí en bus (`progresion/progression_manager.gd:167-168`) | Desalineación firma/canal. |
| `travel` | `island_loaded` (120) | Solo test (`diario/test_diario.gd:98`) | Sí (`diario/diary_service.gd:113-114`, `audio/narrative_sound.gd:54-55`) | Productor de dominio ausente (reconocido en `narrative_sound.gd:57`). |
| `ui` | `hud_request` (136) | No detectada | Sí (`ui/core/ui_manager.gd:51-52`) | Escuchada pero nunca emitida. |
| `ui` | `dialog_requested` (138), `dialog_finished` (140) | Solo tests (`saving/test_autosave_m59.gd:64,74`) | Sí (p. ej. `ui_manager.gd:53`, `save_manager.gd:118-119`) | Sin emisor de producción en bus detectado. |
| `ui` | `layer_requested` (142), `confirm_requested` (144) | No detectada | No detectada | Huérfanas. |
| `ui` | `ui_layers_changed` (148), `ui_focus_moved` (150) | No en bus (emitidas en `ui_manager.gd`) | No detectada en bus | Duplicadas respecto a señales locales de `UIManager`. |
| `player` | `player_died` (154), `level_up` (156), `damage_taken` (158) | No detectada | No detectada | Huérfanas. |
| `progresion` | `nivel_casa_cambio` (178), `nivel_amistad_cambio` (180) | No detectada | No detectada | `nivel_herramienta_cambio` sí se emite (`progresion/progression_manager.gd:216`). |
| `infra` | `game_flow_changed`, `carga_iniciada`, `carga_completada`, `boot_completado` (165-171) | `game_flow_changed` (`core/game_flow_manager.gd:73`), `boot_completado` (`core/bootstrap.gd:132`); `carga_iniciada` visto en test (`core/test_anti_softlock_m66.gd:109`), `scene_manager` tiene reenvío infra (`core/scene_manager.gd:79-90`) | Sí en tests M40 (`core/test_infraestructura_m40.gd`) | Cobertura de producción parcial/desigual según evento. |

**Notas:** `npc.cumpleanos/carta_recibida/gift_given/friendship_level_up`, `calendar.day_started/season_changed`, `time.fase_cambio`, `weather.*`, `vehicle.*`, `ui.notify`, `diary.*`, `fishing.*`, `quest.started/completed/prereq_met` muestran emisores y/o consumidores activos en el muestreo realizado.

**Conclusión (2):** existen señales huérfanas o semihuérfanas (sin emisor, sin consumidor, o solo en tests) y al menos un caso de emisión sin consumo (`quest.quest_updated`). También hay señales “definidas” pero operadas por canales paralelos (inventario/viaje/UI), lo que equivale funcionalmente a señales de bus no efectivas.

---

## 3) ¿Hay dependencias circulares entre servicios?

**Dentro de los archivos analizados:** no se observaron dependencias circulares.

- `event_bus.gd` (`1-46`, clases internas `47-199`) define contenedores de señales y no realiza `preload`, `load` ni referencias a `ServiceRegistry` u otros servicios concretos.
- `service_registry.gd` (`9-75`) mantiene un `Dictionary` de instancias por contrato string, emite avisos y expone utilidades; no referencia `EventBus` ni tipos de dominio.
- No hay relación directa `EventBus -> ServiceRegistry` ni `ServiceRegistry -> EventBus`.

**Matiz:** el análisis pedido se limita a estos dos scripts. A nivel de autoloads/escena pueden existir ciclos indirectos de inicialización entre otros servicios; con la evidencia de estos archivos no se detecta ciclo entre `EventBus` y `ServiceRegistry`.

**Conclusión (3):** no hay dependencias circulares entre `EventBus` y `ServiceRegistry` según el código fuente revisado.

---

## 4) ¿Hay alguna función crítica sin validación de entrada?

Sí, principalmente en `ServiceRegistry`.

1. **`register(contract: String, instance: Object) -> bool`** (`service_registry.gd:22-28`)
   - Valida duplicados de `contract` (RF3, rechaza segundo registro) pero **no valida** que `contract` sea no vacío/normalizado ni que `instance` sea no nulo.
   - **Riesgo:** registrar `""` crea una clave ambigua; registrar `null` almacena un servicio inválido que `get_service` devolverá como valor presente/no nulo en `_registry` solo hasta consulta (`_registry.get` devolvería `null` pero `has()`/`contracts()` lo considerarían registrado), generando estados inconsistentes y fallos tardíos en consumidores.

2. **`get_service(contract: String) -> Variant`** (`service_registry.gd:33-38`)
   - Maneja ausencia con warning único por contrato (RF12) y devuelve `null`; no valida formato de `contract`.
   - **Riesgo:** menor (degradación controlada), pero consultas con claves malformadas contaminan `_avisados_tempranos` y dificultan diagnóstico.

3. **`unregister(contract: String) -> void`** (`service_registry.gd:45-46`)
   - Elimina del registro pero no limpia `_avisados_tempranos`.
   - **Riesgo:** si un contrato se desregistra y vuelve a consultarse antes de re-registrarse (o se re-registra con otro ciclo), el warning de acceso temprano no volverá a emitirse; reduce observabilidad en errores de orden de arranque.

4. **`EventBus`** (`event_bus.gd`)
   - No expone API crítica con parámetros de entrada a validar (es composición declarativa de dominios/señales); la validación relevante recae en quienes emiten (tipos de argumentos de señales). No se identificaron funciones críticas propias sin validación en este archivo.

**Conclusión (4):** la función crítica con validación insuficiente más relevante es `ServiceRegistry.register` (acepta contrato vacío e instancia nula) y, en menor medida, `unregister` no resetea el estado de aviso temprano.

---

## 5) Dos mejoras concretas de diseño

### Mejora 1 — Consolidar el contrato de eventos (un solo canal, firmas únicas y auditoría de señales)
- **Problema que ataca:** doble canal y desalineación de firmas/producción (§1, §2), p. ej. `InventarioService` emitiendo señales propias (`inventario_service.gd:16-17,53,65,361`) mientras consumidores escuchan `EventBus.inventory` (`save_manager.gd:96-97`, `tutorial_manager.gd:195-196`); `TravelService` emitiendo `travel_started(route_id)` (`viajes/travel_service.gd:270`) frente a `EventBus.travel.travel_started(from_island,to_island)` (`event_bus.gd:118`) y `island_loaded` sin productor real (`narrative_sound.gd:57`).
- **Cambio propuesto:**
  1. Definir para cada dominio una **única fuente de verdad**: o los dominios emiten exclusivamente en `EventBus.<dominio>.*`, o el bus actúa como fachada que re-emite las señales del servicio (bridge explícito en `_ready` del servicio/autoload).
  2. Alinear firmas (p. ej. decidir si inventario incluye `container/quantity` y reflejarlo en un solo contrato; unificar `travel_started`).
  3. Pasar por una auditoría de señales: eliminar o marcar explícitamente como reservadas/deprecadas las huérfanas (`chunk_modified`, `vessel_arrived`, `player_died/level_up/damage_taken`, `layer_requested/confirm_requested`, `nivel_casa_cambio/nivel_amistad_cambio`, etc.) y conectar o retirar `quest.quest_updated` (`secondary_stories_service.gd:380`, sin listeners).
- **Beneficio:** reduce acoplamiento accidental, evita listeners muertos y hace verificable el contrato global.

### Mejora 2 — Endurecer `ServiceRegistry` y promover resolución por contratos
- **Problema que ataca:** registro permisivo y diagnóstico incompleto (§4) más acoplamiento por rutas `/root/*` (§1.4).
- **Cambio propuesto:**
  1. En `register` (`service_registry.gd:22-28`): rechazar con `push_error/push_warning` y `return false` si `contract.strip_edges().is_empty()` o `instance == null`; normalizar la clave (`strip_edges`).
  2. En `unregister` (`service_registry.gd:45-46`): borrar también `_avisados_tempranos.erase(contract)` para que el aviso de acceso temprano vuelva a ser útil tras ciclos de baja/alta.
  3. Añadir una comprobación opcional de arranque (p. ej. usar `validate_required` con un conjunto de contratos críticos desde bootstrap y loguear faltantes) y documentar/adoptar `Contratos.*` (`core/contratos.gd`) como vía preferida frente a `get_node_or_null("/root/...")` en servicios consumidores.
  4. (Opcional, evolución) permitir metadatos de registro (tipo esperado/interfaz) para fallar temprano si se registra una instancia incompatible.
- **Beneficio:** evita estados inválidos en el registro, mejora la trazabilidad de errores de inicialización y facilita desacoplar módulos de la topología concreta de autoloads.

---

## Conclusión final

`event_bus.gd` y `service_registry.gd` proveen una base razonable de infraestructura (bus por dominios tipado por convención y registro central con protección ante duplicados/accesos tempranos). El análisis evidencia, sin embargo, **desacoplamiento incompleto en la práctica**: señales del bus sin productor/consumidor efectivo, canales paralelos con firmas distintas (inventario, viaje, UI), y fuerte dependencia de rutas `/root/*` pese a existir un registro por contratos. No se detectaron dependencias circulares entre ambos scripts. La mejora prioritaria es **consolidar y auditar los contratos de eventos** y **endurecer la validación/uso de `ServiceRegistry`**, de modo que el bus y el registro funcionen como contratos fiables y no como catálogos parcialmente desconectados.
