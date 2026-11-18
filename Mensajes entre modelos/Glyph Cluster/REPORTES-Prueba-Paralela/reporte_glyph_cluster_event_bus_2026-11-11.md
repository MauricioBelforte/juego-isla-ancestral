# Reporte de arquitectura: `EventBus` y `ServiceRegistry`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-11  
**Alcance:** análisis estático de `game/isla-ancestral/scripts/core/event_bus.gd` y `game/isla-ancestral/scripts/core/service_registry.gd`, con referencias cruzadas en `game/isla-ancestral/scripts/**`, `game/isla-ancestral/project.godot` y artefactos de soporte relevantes.

> Nota de método: las conclusiones sobre emisiones/conexiones se basan en búsquedas textuales (`Select-String`) sobre scripts del proyecto y en lectura directa de los archivos objetivo. Las ocurrencias dentro de `game/isla-ancestral/addons/` (p. ej. gdUnit4) o en tests/pruebas se citan solo como evidencia cuando aplica; no se consideran uso de gameplay salvo indicación explícita.

---

## 1. Archivos analizados

| Archivo | Líneas | Rol observado |
|---|---:|---|
| `game/isla-ancestral/scripts/core/event_bus.gd` | 199 | Autoload global (bus de eventos por dominios). Declara sub-objetos de eventos (`WorldEvents`, `EconomyEvents`, etc.) y expone señales tipadas; no contiene lógica de emisión propia salvo documentación de uso. |
| `game/isla-ancestral/scripts/core/service_registry.gd` | 75 | Autoload global (registro de servicios por contrato string). API: `register`, `get_service`, `has`, `unregister`, `contracts`, `list_registered`, `validate_required`, `duplicados_rechazados`. |
| `game/isla-ancestral/project.godot` | 22, 26, 40 | Registra autoloads: `EventBus`, `ServiceRegistry`, `Bootstrap` (entre otros). |
| `game/isla-ancestral/scripts/core/bootstrap.gd` | 38, 55, 118-133, 146-173 | Orquesta arranque: obtiene `/root/EventBus` y `/root/ServiceRegistry`, registra servicios core y emite diferido `infra.boot_completado`. |

**Citas clave (archivos objetivo):**

- `event_bus.gd:1-13` — documentación del patrón: “Signal Up, Call Down”, EventBus no importa dominios, uso vía `EventBus.<dominio>.<señal>`.
- `event_bus.gd:15-44` — instanciación de dominios: `world`, `economy`, `inventory`, `quest`, `npc`, `calendar`, `time`, `weather`, `travel`, `vehicle`, `ui`, `player`, `infra`, `diary`, `progresion`, `fishing`.
- `event_bus.gd:48-199` — definición de clases internas de eventos y señales por dominio.
- `service_registry.gd:11-15` — estado interno: `_registry`, `_avisados_tempranos`, `_duplicados_rechazados`.
- `service_registry.gd:22-28` — `register` rechaza duplicados (devuelve `false`, warning, no sobrescribe).
- `service_registry.gd:33-38` — `get_service` devuelve `null` si no existe y avisa una vez por contrato (`DOM-INF-ACCESO-TEMPRANO`).
- `service_registry.gd:63-68` — `validate_required` acumula contratos faltantes.
- `service_registry.gd:74-75` — `_ready` imprime conteo de servicios registrados.

---

## 2. (1) ¿Hay acoplamiento fuerte entre sistemas que debería ser suelto?

### 2.1 Evaluación general

- **`event_bus.gd` (núcleo): bajo acoplamiento estructural.** No realiza `preload/load`, no importa scripts de dominio y solo define contratos de señales en clases internas (`event_bus.gd:48-199`). Esto es coherente con un bus global desacoplado.
- **`service_registry.gd` (núcleo): bajo acoplamiento estructural.** Almacena `Object` en un `Dictionary` por clave `String` sin conocer tipos concretos de dominio (`service_registry.gd:11,22-47`). El acoplamiento es por *contrato nominal* (string), que es la intención habitual de un service locator/registry.
- **Acoplamiento en el uso (runtime) es mayor, pero esperado para autoloads:** múltiples sistemas acceden por ruta global (`get_node_or_null("/root/EventBus")`, `get_node_or_null("/root/ServiceRegistry")`) en lugar de inyección. Ejemplos: `bootstrap.gd:126,147`, `scripts/core/softlock_guard.gd:71`, `scripts/dialogos/dialogue_manager.gd:43`, `scripts/analytics/analytics_director.gd:53`, `scripts/audio/*`, etc. Esto crea dependencia del árbol de escena/autoloads, no dependencia directa entre módulos de negocio.

### 2.2 Puntos de acoplamiento mejorables

1. **`bootstrap.gd` conoce detalles internos del bus y del registro (orquestación acoplada al contrato concreto):**
   - Emite directamente `infra.boot_completado` accediendo a `bus.infra` y verificando `has_signal` (`bootstrap.gd:126-133`).
   - Registra servicios core y consulta `list_registered()` para log/diagnóstico (`bootstrap.gd:153-173`).
   - *Impacto:* aceptable para bootstrap, pero concentra conocimiento de wiring; cambios en nombres de dominio/señal o en API del registry requieren tocar bootstrap.
2. **Duplicación de contrato de eventos UI entre `EventBus.ui` y `UIManager`:**
   - `event_bus.gd:134-151` declara `hud_request`, `dialog_requested`, `dialog_finished`, `layer_requested`, `confirm_requested`, `ui_layers_changed`, `ui_focus_moved`.
   - `scripts/ui/core/ui_manager.gd` define y emite sus propias señales homónimas (`ui_layers_changed`, `ui_focus_moved`) y gestiona foco/capas internamente; solo conecta parcialmente a señales del bus (`hud_request`, `dialog_requested`) cuando existen (`ui_manager.gd:51-55,64,247,276,358,368,457,476,480,643`).
   - *Impacto:* dos “fuentes de verdad” para eventos UI; riesgo de que productores/consumidores se conecten al canal equivocado y de que señales del bus queden sin uso real.
3. **`service_registry.gd` usa `Variant`/`Object` sin tipado de interfaz:**
   - `register(contract: String, instance: Object)` y `get_service -> Variant` (`service_registry.gd:22,33`) no expresan capacidades esperadas del servicio.
   - *Impacto:* acoplamiento implícito por convención (quién consume debe conocer API del servicio); errores se detectan tarde en runtime.

**Conclusión (1):** no se observa acoplamiento fuerte *entre dominios de negocio a través de los dos archivos core*; el acoplamiento principal es **al mecanismo global (autoload/service locator)** y hay **duplicación/confusión de canal en UI** que conviene reducir.

---

## 3. (2) ¿Hay señales declaradas que nunca se emiten o nunca se conectan?

### 3.1 Hallazgos con evidencia (uso nulo o muy limitado en scripts de juego)

> Criterio: “sin uso” = no se encontraron llamadas `.emit(...)` ni `.connect(...)` sobre la señal del bus en `game/isla-ancestral/scripts/**` (excluyendo coincidencias puramente textuales no aplicables) según las búsquedas realizadas. Las señales usadas solo en tests/spies se marcan aparte.

| Dominio.Señal | Declaración | Evidencia de emisión | Evidencia de conexión/consumo | Observación |
|---|---|---|---|---|
| `world.chunk_modified` | `event_bus.gd:54` | No hallada en scripts de juego | No hallada; solo verificación de contador 0 en `scripts/core/qa_m40_spy.gd:56` | **Sin uso runtime aparente.** |
| `world.biome_changed` | `event_bus.gd:56` | `scripts/core/qa_m40_spy.gd:51` (test/spy) | No hallada en scripts de juego | Uso limitado a QA/spy. |
| `economy.purchase_done` | `event_bus.gd:62` | No hallada (`*.emit` sobre `economy.purchase_done`) | `scripts/logros/achievement_service.gd:142-143`, `scripts/progresion/progression_manager.gd:154-155` conectan condicionalmente; otros comentarios lo mencionan (`diario`, `telemetry`) | **Consumidores existen, emisor de bus no localizado** en scripts de juego por búsqueda. |
| `economy.debt_paid` | `event_bus.gd:64` | No hallada | No hallada | **Sin uso aparente.** |
| `calendar.vessel_arrived` | `event_bus.gd:104` | No hallada | No hallada | **Sin uso aparente.** |
| `travel.travel_started` | `event_bus.gd:118` | No hallada en bus | `scripts/progresion/progression_manager.gd:167-168` conecta condicionalmente a `bus.travel.travel_started`; `scripts/viajes/travel_service.gd:23,270` define/emite **su propia señal** `travel_started` (no `EventBus.travel`) | **Desalineación probable:** el bus declara la señal pero el productor real emite en `TravelService`. |
| `travel.island_loaded` | `event_bus.gd:120` | No hallada en scripts de juego (búsqueda) | `scripts/audio/narrative_sound.gd:54-55,68`, `scripts/diario/diary_service.gd:113-114` conectan; `diario/test_diario.gd:98` emite en test | **Consumidores existen; emisor runtime de bus no localizado** por búsqueda (nota en `narrative_sound.gd:57` indica que nadie lo emite). |
| `ui.hud_request` | `event_bus.gd:136` | No hallada | `scripts/ui/core/ui_manager.gd:51-52,476` conecta `_on_hud_request` si existe | Declarada y conectada, **sin emisor localizado**. |
| `ui.dialog_requested` | `event_bus.gd:138` | `scripts/saving/test_autosave_m59.gd:64` (test) | `scripts/saving/save_manager.gd:118`, `scripts/ui/layers/dialog_layer.gd:55-56,256`, `scripts/ui/core/ui_manager.gd:53-54,480` | **Uso real en listeners; emisiones runtime de producción no localizadas** (tests sí). |
| `ui.dialog_finished` | `event_bus.gd:140` | `scripts/saving/test_autosave_m59.gd:74` (test) | `scripts/saving/save_manager.gd:119`, `scripts/ui/layers/dialog_layer.gd:57-58,260` | Ídem. |
| `ui.layer_requested` | `event_bus.gd:142` | No hallada | No hallada | **Sin uso aparente en bus.** |
| `ui.confirm_requested` | `event_bus.gd:144` | No hallada | No hallada | **Sin uso aparente en bus.** |
| `ui.ui_layers_changed` | `event_bus.gd:148` | No hallada en bus | No hallada en bus (UIManager usa señal propia) | **Duplicada/no usada en bus.** |
| `ui.ui_focus_moved` | `event_bus.gd:150` | No hallada en bus | No hallada en bus (UIManager usa señal propia) | **Duplicada/no usada en bus.** |
| `player.player_died` | `event_bus.gd:154` | No hallada | No hallada | **Sin uso aparente.** |
| `player.level_up` | `event_bus.gd:156` | No hallada | No hallada | **Sin uso aparente.** |
| `player.damage_taken` | `event_bus.gd:158` | No hallada | No hallada | **Sin uso aparente.** |
| `infra.boot_completado` | `event_bus.gd:171` | `scripts/core/bootstrap.gd:132` (diferido) | No hallada en scripts de juego; comentario en bootstrap indica “0 consumidores” (`bootstrap.gd:120`) | **Emitida pero sin consumidores actuales** (contrato preparado). |

### 3.2 Señales con uso activo (muestra representativa)

Para contraste, sí se observó uso activo (emit/connect) en señales como: `world.block_placed`/`block_removed` (save/tutorial/tests/VFX), `inventory.item_added`/`item_removed`/`hotbar_selected` (HUD/save/tutorial/tests), `quest.prereq_met`/`quest_started`/`quest_completed` (story/historias/diario/progresión/tests), `npc.*` en varios dominios (amistad/diálogo/diario/save/logros), `calendar.day_started`/`season_changed` (time/diario/save/VFX), `time.fase_cambio`, `weather.clima_cambio`/`intensidad_cambio`, `vehicle.*`, `ui.notify`, `infra.game_flow_changed`/`carga_iniciada`/`carga_completada`, `progresion.*`, `diary.*`, `fishing.*`.

**Conclusión (2):** existen señales **declaradas sin uso runtime claro** (`chunk_modified`, `debt_paid`, `vessel_arrived`, `layer_requested`, `confirm_requested`, señales `ui_layers_changed/ui_focus_moved` del bus, dominio `player` completo), señales **con consumidores pero sin emisor de bus localizado** (`purchase_done`, `island_loaded`, posiblemente `travel_started` del bus vs `TravelService`) y al menos una **emitida sin consumidores** (`infra.boot_completado`, hoy). Esto sugiere deuda de contrato y riesgo de integraciones incompletas.

---

## 4. (3) ¿Hay dependencias circulares entre servicios?

### 4.1 En los dos archivos objetivo

- `event_bus.gd`: no referencia `ServiceRegistry` ni otros servicios; no hay ciclo.
- `service_registry.gd`: no referencia `EventBus`; no instancia ni llama servicios, solo almacena y devuelve referencias (`service_registry.gd:22-68`).

### 4.2 En el wiring observado

- `bootstrap.gd` depende de ambos autoloads (`/root/EventBus`, `/root/ServiceRegistry`) y registra instancias (`bootstrap.gd:146-173`), lo cual es una dependencia unidireccional de arranque.
- `verificar_arquitectura.gd` declara pares permitidos como `["ServiceRegistry","EventBus"]` y `["Bootstrap","EventBus"/"ServiceRegistry"]` (documentación/verificación), sin implicar ciclo de ejecución entre los core.
- No se halló que `ServiceRegistry.get_service(...)` sea usado para recuperar `EventBus` en un patrón que cierre un ciclo con estos dos componentes; el acceso típico al bus es directo por `/root/EventBus`.

**Conclusión (3):** **no se identifican dependencias circulares entre `EventBus` y `ServiceRegistry`** ni ciclos evidentes introducidos por estos dos archivos. Pueden existir ciclos de mayor nivel entre servicios registrados, pero quedan fuera del alcance de este análisis y no se evidencian en el código inspeccionado.

---

## 5. (4) ¿Hay alguna función crítica sin validación de entrada?

### 5.1 `ServiceRegistry` — validaciones insuficientes en API crítica

| Función | Ubicación | Problema |
|---|---|---|
| `register(contract, instance)` | `service_registry.gd:22-28` | No valida `contract` vacío/whitespace ni `instance == null`. Permite registrar claves inválidas o servicios nulos, lo que puede propagar fallos silenciosos a consumidores. |
| `get_service(contract)` | `service_registry.gd:33-38` | No valida contrato vacío; consulta y puede emitir warning de “acceso temprano” para claves sin sentido. |
| `has(contract)` / `unregister(contract)` | `service_registry.gd:41-46` | Sin validación de entrada (aceptan cualquier `String`, incluso vacía). |
| `validate_required(required)` | `service_registry.gd:63-68` | Asume iterable de elementos convertibles a `String`; no valida tipo de `required` ni entradas nulas/vacías. |

**Mitigaciones existentes:** rechazo de duplicados y warning de acceso temprano (una vez por contrato) son buenos controles, pero no cubren entradas inválidas.

### 5.2 `EventBus`

- No expone funciones públicas de dominio más allá de `_ready` implícito inexistente y las señales (no hay métodos `emit_*` propios en `event_bus.gd`). La “validación” de payload recae en firmas tipadas de señales GDScript y en los emisores/consumidores. No se detecta una función crítica propia del bus sin validar parámetros.

**Conclusión (4):** **sí, en `service_registry.gd`** las funciones de registro/consulta/validación carecen de validaciones de entrada básicas (contrato vacío/nulo semántico, instancia nula, forma de `required`). En `event_bus.gd` no hay funciones críticas equivalentes que requieran validación adicional más allá del contrato de señales.

---

## 6. (5) Dos mejoras concretas de diseño

### Mejora 1 — Endurecer `ServiceRegistry` con guardas de contrato y contrato de tipo

**Problema:** registro/lookup aceptan entradas inválidas y exponen `Variant` sin garantías, facilitando fallos tardíos.  
**Cambio concreto (diseño):**
- En `register`: rechazar `contract.strip_edges().is_empty()` e `instance == null` con `push_error`/`push_warning` y retorno `false`; normalizar contrato (p. ej. `strip_edges`) para evitar duplicados lógicos (`"economy"` vs `" economy "`).
- En `get_service/has/unregister`: tratar contrato vacío como no válido (retorno `null/false` sin contaminar `_avisados_tempranos` con claves basura) o normalizar de forma consistente.
- En `validate_required`: aceptar solo `Array`/tipos iterables esperados y filtrar entradas vacías/nulas.
- (Opcional, mayor impacto) introducir `register_typed(contract, instance, expected_interface_hint)` o un mapa de validadores por contrato para detectar registros incompatibles en arranque/debug.

**Beneficio:** reduce estados corruptos del registro, mejora diagnósticos tempranos y alinea con el manejo de error ya existente (`duplicados_rechazados`, `DOM-INF-ACCESO-TEMPRANO`).

### Mejora 2 — Higiene de contratos del `EventBus`: inventario de señales vivas + unificación del canal UI

**Problema:** hay señales sin emisor/consumidor claro, posibles desalineaciones (`TravelService.travel_started` vs `EventBus.travel.travel_started`) y duplicación UI (`EventBus.ui` vs señales propias de `UIManager`). Esto dificulta razonar sobre el flujo real y favorece integraciones rotas.  
**Cambio concreto (diseño):**
- Mantener un **inventario explícito** (p. ej. en `event_bus.gd` o doc técnica) con estado por señal: `activo | reservado | deprecado`, y dueño emisor/consumidor esperado.
- Definir una regla única para UI: o bien **todo evento cross-módulo UI pasa por `EventBus.ui`** y `UIManager` solo re-emite/adapta, o bien **`UIManager` es la única fuente** y las señales homónimas del bus se marcan deprecadas/eliminan cuando sea seguro.
- Alinear productor/contrato en casos detectados: hacer que `TravelService` emita también en `EventBus.travel.travel_started`/`island_loaded` según corresponda (o mover consumidores al canal real) y documentar `infra.boot_completado` como evento de lifecycle con al menos un consumidor previsto o hook de extensión.

**Beneficio:** elimina ambigüedad de integración, reduce señales muertas, y hace el bus verificable (auditable) sin romper el patrón “Signal Up, Call Down”.

---

## 7. Conclusión final

- **Arquitectura base:** `EventBus` y `ServiceRegistry` cumplen una separación razonable como infraestructura global (autoloads, sin imports de dominio en los archivos core). El acoplamiento predominante es al mecanismo de acceso global, no entre dominios de negocio.
- **Riesgos detectados:** (a) **deuda de contrato en señales** (señales sin uso runtime, sin emisor localizado, o duplicadas entre bus y UIManager), (b) **falta de validación de entrada** en `ServiceRegistry` para casos inválidos/nulos, (c) **posibles desalineaciones productor-consumidor** (`travel_started`/`island_loaded`, `purchase_done`) que merecen verificación funcional.
- **Dependencias circulares:** no se evidencian entre `EventBus` y `ServiceRegistry`.
- **Prioridad sugerida:** 1) endurecer validaciones del `ServiceRegistry` (bajo riesgo, alto retorno en robustez), 2) saneamiento guiado del catálogo de señales del bus y del canal UI (requiere coordinación con módulos consumidores/emisores y actualización de tests).

**Evidencia de contexto de proyecto:** autoloads en `game/isla-ancestral/project.godot:22,26,40`; emisión de `infra.boot_completado` en `game/isla-ancestral/scripts/core/bootstrap.gd:118-133`; consumidores/definiciones paralelas en `game/isla-ancestral/scripts/ui/core/ui_manager.gd` y `game/isla-ancestral/scripts/viajes/travel_service.gd`.
