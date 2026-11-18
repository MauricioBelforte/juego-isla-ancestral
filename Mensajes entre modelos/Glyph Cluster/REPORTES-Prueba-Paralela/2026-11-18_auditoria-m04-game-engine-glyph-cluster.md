# Auditoría de Arquitectura — Módulo 04 (Game Engine)

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-18 17:23 (UTC)  
**Módulo auditado:** `04-Game-Engine` (documentación en `DOCUMENTACION/04-Game-Engine/plan-actual/`)  
**Alcance de inspección:** `game/isla-ancestral/project.godot` (autoloads/config core) y subsistemas de motor en `game/isla-ancestral/scripts/core/`, `game/isla-ancestral/scripts/saving/`, `game/isla-ancestral/scripts/logging/`, `game/isla-ancestral/scripts/world/` (foco en orquestación, registro, eventos, persistencia, logging y servicios base de mundo).  
**Método:** revisión estática de código y configuración (lectura de fuentes, búsqueda de referencias `/root/`, `ServiceRegistry`, `EventBus`, `preload/load`, `class_name`, orden de autoloads). No se ejecutó el proyecto ni se modificó código del juego.

## Resumen ejecutivo

- Se identificó **acoplamiento fuerte** en la orquestación de arranque/flujo (`Bootstrap`, `SceneManager`, `GameFlowManager`) con responsabilidades duplicadas y múltiples rutas para sincronizar estado.
- **No se observó un ciclo de importación/instanciación directo A→B→A** entre autoloads core inspeccionados (la mayoría usa `get_node_or_null("/root/...")` y llamadas diferidas), pero sí existe un **acoplamiento bidireccional de orquestación** entre `Bootstrap`↔`SceneManager`↔`GameFlowManager` y dependencias ocultas por orden de inicialización de autoloads.
- `SaveManager` concentra alta complejidad y dependencias cruzadas (EventBus multi-dominio, autoloads directos, clases concretas de persistencia), actuando como punto de riesgo de mantenimiento.
- El patrón Service Locator (`ServiceRegistry` + strings) y el acceso directo a `/root/*` coexisten de forma inconsistente; existe `Contratos` pero no es la fuente única efectiva en los subsistemas auditados.

## Hallazgos

### F-01 — Orquestación de arranque/flujo fragmentada y con lógica duplicada
- **Severidad:** Alto  
- **Ubicación:** `game/isla-ancestral/scripts/core/bootstrap.gd:36,49-55,60-83,90-115,122-133,175-183`; `game/isla-ancestral/scripts/core/scene_manager.gd:13-15,32-49,61-73,81-88,94-128,133-137,141-160`; `game/isla-ancestral/scripts/core/game_flow_manager.gd:27,31-46,64-73`; `game/isla-ancestral/project.godot:40,95-96`
- **Evidencia:** `Bootstrap` difiere la verificación de flujo y el autoregistro (`:49-55`), resuelve el estado `MUNDO` consultando `SceneManager` o leyendo el enum de `GameFlowManager` y puede aplicar la transición por cualquiera de las dos vías (`:90-115`). `SceneManager` también resuelve estados por nombre desde `GameFlowManager`, sincroniza flujo en carga/inicio/error/finalización y emite eventos infra (`:32-49,61-73,81-88,94-128,133-137`). `GameFlowManager` mantiene FSM y además reenvía cambios por `EventBus.infra` (`:31-46,64-73`). Existen canales paralelos: señales locales (`estado_cambiado`, `cambio_*`) y eventos de bus infra (`game_flow_changed`, `carga_*`, `boot_completado`).
- **Impacto:** alto riesgo de desincronización, comportamiento dependiente del orden/timing diferido y dificultad para razonar sobre la “fuente de verdad” del flujo; cambios en enum/estados o en políticas de carga requieren tocar múltiples archivos.
- **Acción recomendada:** centralizar la política de transición de flujo en un único orquestador con API explícita; limitar `SceneManager` a carga de escena/progreso y `Bootstrap` a disparo de una fase de arranque única; unificar el canal de notificación canónico.

### F-02 — Acoplamiento global por Service Locator, strings mágicos y registro inconsistente
- **Severidad:** Alto  
- **Ubicación:** `game/isla-ancestral/scripts/core/service_registry.gd:11,22-38,52-68,74-75`; `game/isla-ancestral/scripts/core/bootstrap.gd:16-18,23-33,64-83,136-160,175-183,216-218`; `game/isla-ancestral/scripts/core/contratos.gd:1-39`; `game/isla-ancestral/scripts/core/game_flow_manager.gd:67`; `game/isla-ancestral/scripts/core/scene_manager.gd:82,95`; `game/isla-ancestral/scripts/core/softlock_guard.gd:71,74`; `game/isla-ancestral/scripts/logging/logger.gd:84-86,96`; `game/isla-ancestral/scripts/world/world_bible.gd:39-43`; `game/isla-ancestral/scripts/saving/save_manager.gd:88,108,231,317`
- **Evidencia:** `ServiceRegistry` expone registro/consulta por contrato string y advertencias en acceso temprano (`service_registry.gd:22-38`). `Bootstrap` mantiene listas/mapas hardcodeados de servicios y dominios (`REQUIRED_SERVICES`, `DOMINIOS_ESPERADOS`, mapa contrato→nombre de autoload) y usa `get_node_or_null("/root/...")` para resolver dependencias (`bootstrap.gd:78,80,91,95,126,139,147`). Existe `Contratos` como catálogo central (`contratos.gd`), pero los subsistemas inspeccionados siguen usando literales/rutas directas. El registro es mixto: bootstrap autoregistra algunos dominios, mientras `logger` y `WorldBible` se autoregistran; otros accesos omiten el registry y van directo a `/root`.
- **Impacto:** dependencias ocultas y difícilmente trazables, riesgo de drift entre nombres de autoload/contratos/listas esperadas, y acoplamiento a la composición global del árbol de escena.
- **Acción recomendada:** establecer una única fuente de verdad para contratos y composición (manifiesto o `Contratos` obligatorio), reducir lookups directos a `/root` en código de motor y definir una estrategia uniforme de registro/fases de inicialización.

### F-03 — `SaveManager` como concentrador de acoplamiento (persistencia + política + integración de dominios)
- **Severidad:** Alto  
- **Ubicación:** `game/isla-ancestral/scripts/saving/save_manager.gd:21-50,80-120,231,317`
- **Evidencia:** el autoload centraliza cola/estado/dirty-tracking (`:21-50`), se suscribe a múltiples dominios de `EventBus` para marcar dirty y disparar/bloquear autosaves (`:84-106,111-119`), accede directamente a `/root/EventManager` para `evento_terminado` (`:108-110`) y a `/root/DataStore` (`:231,317`), además de coordinar clases concretas del subsistema (`SaveSnapshot`, `SaveLoader`, `SaveWriter`, `SaveBackup`, `SaveSchema`, proveedores). Mezcla reglas de negocio de guardado, integración con eventos de dominio y orquestación de IO.
- **Impacto:** cambios en eventos, autoloads o formato de guardado tienen alto radio de impacto; pruebas y evolución del motor se vuelven frágiles por el número de dependencias implícitas.
- **Acción recomendada:** separar adaptadores de eventos/autosave (suscripciones y políticas) del núcleo de persistencia; inyectar dependencias de entorno (`DataStore`, fuentes de eventos) detrás de interfaces/contratos y mantener `SaveManager` enfocado en coordinación transaccional de slots.

### F-04 — `SoftlockGuard` con acoplamiento rígido a implementaciones concretas y autoloads específicos
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/scripts/core/softlock_guard.gd:13-22,57-66,70-80`
- **Evidencia:** precarga concreta de invariantes y recuperación (`_IRecoverable`, `Jugador/Mision/Npc/ObjetoClave/Vehiculo/PuzzleInvariant`, `CofreRecuperacion`, `CheckpointManager`) y registra invariantes por defecto en código (`:13-22,57-66,78-80`). Para disparadores consulta directamente `/root/EventBus` (`infra.carga_iniciada`) y `/root/SaveManager` (`save_completed`) (`:70-76`).
- **Impacto:** extender o reconfigurar reglas/invariantes requiere modificar el guard; el subsistema queda atado a nombres/señales concretas de otros autoloads.
- **Acción recomendada:** introducir registro dinámico/configurable de invariantes y fuentes de disparo (vía contrato/registry o configuración de módulo) manteniendo el motor de evaluación desacoplado de tipos concretos.

### F-05 — Dependencias ocultas por orden de inicialización de autoloads
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/project.godot:22,25-27,30,34,40,44,95-96,99,106`; `game/isla-ancestral/scripts/core/bootstrap.gd:49-55,90-95`; `game/isla-ancestral/scripts/logging/logger.gd:89-100`; `game/isla-ancestral/scripts/saving/save_manager.gd:84-91`
- **Evidencia:** el orden declarado en `[autoload]` coloca `Bootstrap` antes de `GameFlowManager`/`SceneManager` y `GameLogger` antes de `CrashReporter`; el código compensa con `call_deferred`, tolerancia a nodos nulos y resoluciones tardías (`Bootstrap` difiere acceso a flujo, `Logger` conecta crash bridge diferido, `SaveManager` degrada si falta `EventBus`). Esto evidencia que la corrección depende del orden/configuración global.
- **Impacto:** regresiones sutiles al reordenar/autogenerar autoloads o al cargar subconjuntos parciales; comportamiento dependiente de timing de arranque.
- **Acción recomendada:** explicitar fases de inicialización (core listo → servicios → dominio → arranque de escena) y contratos de disponibilidad, evitando dependencias implícitas del orden textual en `project.godot`.

### F-06 — Acoplamiento bidireccional de orquestación entre `SceneManager` y `GameFlowManager` (sin ciclo de importación observado)
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/scripts/core/scene_manager.gd:32-49,61-73,94-128,133-137`; `game/isla-ancestral/scripts/core/game_flow_manager.gd:13-25,31-46,64-73`; `game/isla-ancestral/scripts/core/bootstrap.gd:90-115`
- **Evidencia:** `SceneManager` conoce el enum/estado de `GameFlowManager`, lo consulta y lo muta durante el ciclo de carga (`estado_flujo`, `sincronizar_flujo`, transición a `CARGANDO/ERROR/objetivo`). `Bootstrap` puede sincronizar a `MUNDO` vía `SceneManager` o invocar `GameFlowManager.cambiar_estado` directamente como fallback (`:108-111`). Aunque `GameFlowManager` no referencia a `SceneManager`, la política de flujo está repartida y existe un bucle de control/orquestación con conocimiento cruzado.
- **Impacto:** difícil garantizar invariantes de transición y evitar rutas que omitan la política prevista (p. ej. modos de carga, estados intermedios).
- **Acción recomendada:** definir un único propietario de transiciones y obligar a los demás componentes a pasar por su API; prohibir mutaciones directas de estado fuera del orquestador.

### F-07 — `Logger` con dependencias ocultas y múltiples responsabilidades
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/scripts/logging/logger.gd:33,71,80-100`
- **Evidencia:** precarga `CrashLogBridge` (`:33`), usa ruta fija de log (`:71`), se autoregistra en `ServiceRegistry` vía lookup a `/root` (`:84-86`) y conecta diferidamente `CrashReporter` (`:89-100`). En el mismo componente conviven configuración, formateo/sanitización, IO/rotación, eco a consola y emisión de señal para UI.
- **Impacto:** acoplamiento a infraestructura concreta y mayor costo de cambio/prueba; fallos en integración (registry/crash/config) se mezclan con la responsabilidad de logging.
- **Acción recomendada:** inyectar resolución de dependencias opcionales (registry/crash bridge/config provider) y separar pipeline de emisión (formato/sanitización) de sinks (archivo, consola, señal, crash).

### F-08 — `TerrainLocator` acoplado a estructura de escena y API interna del generador, con sondeo por frame
- **Severidad:** Medio  
- **Ubicación:** `game/isla-ancestral/scripts/core/terrain_locator.gd:14,16-24,25-41,45-52,56-73`
- **Evidencia:** busca el terreno por nombre fijo `VoxelTerrain` en la escena actual o escaneo recursivo del árbol (`:25-41`), reintenta cada `_process` mientras no sea válido (`:20-23`), y obtiene altura invocando `generator._get_island_gen().get_height(...)` (`:48-52`), lo que depende de una API interna/no pública del generador.
- **Impacto:** dependencia oculta de composición de escena y de implementación del generador; riesgo de costo innecesario en runtime y roturas ante refactors de nombres/métodos.
- **Acción recomendada:** exponer un proveedor de altura/terreno registrado explícitamente (contrato) y cambiar el reintento continuo por un mecanismo de notificación/listo (`signal` o fase de inicialización).

### F-09 — `EventBus` monolítico y coexistencia de canales de notificación en infraestructura
- **Severidad:** Bajo  
- **Ubicación:** `game/isla-ancestral/scripts/core/event_bus.gd:1-4,14-43,160-171,192-199`; `game/isla-ancestral/scripts/core/game_flow_manager.gd:27,43-44,73`; `game/isla-ancestral/scripts/core/scene_manager.gd:13-15,45-46,64-65,88`
- **Evidencia:** `EventBus` concentra múltiples dominios y eventos infra en un único autoload tipado por agregación; en paralelo, `GameFlowManager` y `SceneManager` exponen señales propias y también publican en `infra`. Los consumidores deben conocer qué canal observar.
- **Impacto:** superficie amplia de cambio y ambigüedad de contrato de eventos para el motor.
- **Acción recomendada:** documentar y aplicar una regla única (señal local vs bus) por tipo de evento, o introducir adaptadores que publiquen desde una sola fuente canónica.

### F-10 — Catálogo de arranque y composición hardcodeado en `Bootstrap`
- **Severidad:** Bajo  
- **Ubicación:** `game/isla-ancestral/scripts/core/bootstrap.gd:23-33,36,64-77,175-183`
- **Evidencia:** `DOMINIOS_ESPERADOS`, ruta de escena principal y mapa contrato→autoload están embebidos en código; la integridad se valida por comparación de strings en runtime diferido.
- **Impacto:** cualquier cambio de nombres/autoloads exige edición manual coordinada y puede desalinearse con la configuración real del proyecto.
- **Acción recomendada:** mover la composición/rutas críticas a configuración declarativa versionada y generar/validar la tabla desde una sola definición.

### F-11 — Identidad/nomenclatura ambigua de `EventBus` (`class_name EventBus_`)
- **Severidad:** Ruido  
- **Ubicación:** `game/isla-ancestral/scripts/core/event_bus.gd:1-2`; `game/isla-ancestral/project.godot:22`
- **Evidencia:** el script define `class_name EventBus_` pero se registra/consume como autoload `EventBus` (`/root/EventBus`).
- **Impacto:** posible confusión para herramientas estáticas o para desarrolladores; sin evidencia de fallo funcional en esta auditoría.
- **Acción recomendada:** alinear nombre de clase/autoload o documentar explícitamente la convención para evitar ambigüedad.

## Dependencias circulares entre autoloads core (evaluación)

- **Ciclo de dependencia directo (import/runtime) observado:** ninguno concluyente en los autoloads core inspeccionados (`ServiceRegistry`, `EventBus`, `GameFlowManager`, `SceneManager`, `Bootstrap`, `GameLogger`, `SaveManager`, `SoftlockGuard`, `TerrainLocator`, `WorldBible`). El acceso se realiza mayoritariamente por `get_node_or_null("/root/...")`, señales y diferidos.
- **Riesgo de circularidad lógica/orquestación:** presente entre `Bootstrap`, `SceneManager` y `GameFlowManager` por conocimiento mutuo de estados/enums, fallbacks cruzados y sincronización en ambos sentidos (ver F-01, F-06). Se recomienda tratarlo como deuda estructural prioritaria aunque no sea un ciclo de carga estricto.

## Dos mejoras de diseño concretas

1. **Unificar el orquestador de flujo y carga (Composition Root de runtime):** introducir un único punto de control (p. ej. `GameFlowController` o responsabilidad exclusiva en `GameFlowManager`) que exponga operaciones atómicas como `iniciar_boot()`, `ir_a_mundo()`, `solicitar_cambio_escena(ruta, estado_objetivo)`. `Bootstrap` dejaría de resolver enums y de forzar transiciones por rutas alternativas; `SceneManager` se limitaría a ejecutar carga diferida, reportar progreso/resultado y no mutaría el FSM salvo a través del orquestador. Se debe elegir un contrato canónico de notificación (señales del orquestador o `EventBus.infra`) y eliminar la duplicación para reducir condiciones de carrera y desincronización (atiende F-01, F-06, F-09).

2. **Registro declarativo y contratos obligatorios para servicios de motor:** crear un manifiesto único de composición (recurso `res://data/core_services.tres`/JSON o módulo de registro generado desde `Contratos`) que defina contrato, autoload/implementación, fase de inicialización y dependencias requeridas. `Bootstrap` cargaría ese manifiesto para registrar/validar servicios en lugar de mantener `DOMINIOS_ESPERADOS` y el mapa hardcodeado (`_autoregistrar_dominios`). Los accesos nuevos y refactors en `core/saving/logging/world` deberían migrar gradualmente de `get_node_or_null("/root/...")` y strings literales a `Contratos.*` + resolución tipada/fachada, con fases explícitas que eliminen dependencias ocultas del orden en `project.godot` (atiende F-02, F-05, F-07, F-08, F-10).

## Cierre

- Auditoría realizada sin modificar código del juego.
- Las severidades priorizan impacto arquitectónico en el motor (mantenibilidad, riesgo de regresión y claridad de dependencias) por encima de defectos funcionales no observados en esta revisión estática.
- Se recomienda usar este reporte como base para un plan de refactor incremental en M04/M07/M40, priorizando F-01, F-02 y F-03.
