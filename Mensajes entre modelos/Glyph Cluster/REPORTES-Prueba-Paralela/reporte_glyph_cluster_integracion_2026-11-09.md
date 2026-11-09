# Reporte de integración entre módulos — `game/isla-ancestral/scripts/`

**Modelo:** Glyph Cluster  
**Fecha:** 2026-11-09  
**Alcance:** análisis estático de `game/isla-ancestral/scripts/**/*.gd` (1261 archivos `.gd`) y `game/isla-ancestral/project.godot`.

## Metodología (evidencia usada)

- Inventario de scripts: `glob game/isla-ancestral/scripts/**/*.gd` → **1261** archivos.
- Autoloads registrados: `project.godot` `[autoload]` → **116** singletons (líneas 19–136).
- Referencias a autoloads por nombre: búsqueda regex sobre todos los `.gd` → **4446** líneas con referencias.
- Dependencias explícitas: `preload/load` → **2058** líneas; `extends/class_name` → **1886** líneas.
- Señales: declaraciones `signal` (no EventBus) → muestra amplia; `connect()` → **621**; `emit()` → **694**.
- Grafo de dependencias por `preload` (rutas `res://scripts/*`) + `extends` resuelto por `class_name` dentro de `scripts/`: **0 componentes fuertemente conectados (SCC > 1)** detectados (sin ciclos directos en ese grafo).
- EventBus: referencias textuales `EventBus` en `scripts/` → **~21 líneas** (uso muy localizado); patrón `EventBus.dominio.señal.connect/emit` observado solo en documentación/ejemplos y en pocos sitios (`scripts/core/event_bus.gd:11-12`, `scripts/audio/narrative_sound.gd:53,55,68`, `scripts/friendship/friendship_service.gd:9` como comentario, tests `test_smoke_core_hy3.gd`, `test_infraestructura_m40.gd`, `test_farm_clima.gd`, `test_anti_softlock_m66.gd`).

> Nota: el análisis es estático (regex/grafo). Conexiones dinámicas por cadenas, grupos, o `call_deferred` no siempre son detectables; las conclusiones marcan lo observable.

## 1) Dependencias cruzadas (circulares) entre módulos

**Resultado:** **No se detectaron dependencias circulares directas** en el grafo estático `preload/load(res://scripts/*) + extends` (resolución por `class_name`) — 0 SCCs.

**Archivos/líneas de referencia del mecanismo de dependencia:**
- `game/isla-ancestral/scripts/core/event_bus.gd:1-14` — declara el bus como hub desacoplado (“EventBus NO importa ningún dominio…”; ejemplo `EventBus.world.block_placed.emit/connect`).
- `game/isla-ancestral/scripts/core/service_registry.gd:1-75` — registro por contrato (`register/get_service/has/unregister`, líneas 15–41), intención de DI.
- `game/isla-ancestral/scripts/core/bootstrap.gd:222-223` — `get_service()` delega al `ServiceRegistry`.

**Riesgo residual (no ciclo, pero acoplamiento indirecto):** la comunicación cruza mayoritariamente por **nombres globales de autoload** (4446 refs) en vez de contratos o señales del bus. Esto no forma ciclos de `preload`, pero crea **dependencias de orden/ciclo de inicialización** implícitas entre autoloads (típico “god-graph” de singletons). Ejemplos de lookups directos:
- `game/isla-ancestral/scripts/dialogos/dialogue_manager.gd:145,349` — `get_node_or_null("/root/WorldState")`.
- `game/isla-ancestral/scripts/inventario/inventario_service.gd:43-45` — `get_node_or_null("/root/SaveManager")` y registro como proveedor.

**Conclusión (1):** sin ciclos de scripts detectables; sí existe una **red densa de dependencias globales** vía autoloads que puede producir acoplamiento temporal y fragilidad ante cambios de orden/carga.

## 2) Módulos que importan/referencian a muchos otros (acoplamiento fuerte)

**Métrica:** “grado de acoplamiento” aproximado = destinos únicos por archivo (preloads `res://scripts/*` + `extends` resuelto a clase del proyecto + autoloads referenciados).

| # | Archivo | Destinos únicos (aprox.) | preloads | refs autoload (líneas) | Nota |
|---|---|---:|---:|---:|---|
| 1 | `scripts/editor/_colector_sintaxis.gd` | 1076 | 1132 | 50 | **Herramienta/editor** (outlier esperado); no runtime de juego. |
| 2 | `scripts/debug/debug_menu.gd` | 18 | 2 | 56 | Menú debug toca clima, economía, eventos, inventario, logging, NPC, mapa, terreno, etc. (líneas ~1+; refs a 15+ autoloads/módulos). |
| 3 | `scripts/ui/ui_root.gd` | 17 | 12 | 10 | Orquesta capas UI y carga muchas layers (`:23-60` preloads/loads de `scripts/ui/layers/*`, crafting, shop, inventario, equipo, diario, loading, créditos, settings). |
| 4 | `scripts/transporte/transport_manager.gd` | 15 | 0 | 25 | Alto acoplamiento por autoloads (clima, diálogo, economía, eventos, amistad, historia, inventario, logging, guardado, tiempo, viajes). |
| 5 | `scripts/ia_npc/npc_agent.gd` | 14 | 9 | 11 | Carga estados IA + refs a clima/eventos/managers/NPC/tiempo (`extends`/preloads de `ia_npc/states/*`). |
| 6 | `scripts/core/bootstrap.gd` | 14 | 0 | 34 | Inicialización conoce muchos servicios (balance, crafting, diálogo, economía, eventos, granja, pesca, inventario, tiendas, tiempo, etc.). |
| 7 | `scripts/main_island.gd` | 13 | 9 | 18 | Escena raíz integra terreno, crafting, encantamiento, granja, fast travel, hotbar, recursos, UI, mundo. |
| 8 | `scripts/core/softlock_guard.gd` | 13 | 10 | 3 | Carga invariantes/recovery (`core/invariants/*`, `core/recovery/*`) + eventos/guardado. |

**Autoloads más referenciados desde otros scripts (inbound, indicador de acoplamiento aferente):**
- `Inventario` (`scripts/inventario/inventario_service.gd`, 444 líneas) — **108** inbound refs.
- `eventos` (`scripts/eventos/event_manager.gd`, 901 líneas) — **105**.
- `SaveManager` (`scripts/saving/save_manager.gd`, 373) — **92**.
- `EventBus` (`scripts/core/event_bus.gd`, 199) — **86** refs nominales, pero **uso efectivo de señales del bus es bajo** (ver punto 3).
- `GameTime` (263) — **68**; `ServiceRegistry` (75) — **58**; `Localization` (377) — **49**; `EconomyManager` (227) — **42**.

**Conclusión (2):** hay acoplamiento fuerte en **orquestadores** (`ui_root`, `bootstrap`, `main_island`, `debug_menu`) y en **autoloads “hub”** (`Inventario`, `eventos`, `SaveManager`, `GameTime`). El patrón dominante es dependencia directa a singletons globales.

## 3) Señales entre sistemas que no están conectadas (o cableado incompleto)

**3.1 EventBus: infraestructura presente, adopción parcial / posibles gaps**

- **Declaración centralizada:** `scripts/core/event_bus.gd:1-120+` define dominios (`world`, `economy`, `inventory`, `quest`, `npc`, `calendar`, `time`, `weather`, `travel`, `vehicle`, `ui`, `player`, `infra`, `diary`, `progresion`, `fishing`) con señales tipadas (p. ej. `WorldEvents.block_placed` `:50`, `TravelEvents.island_loaded` `:120`, `InfraEvents.game_flow_changed/carga_iniciada/carga_completada/boot_completado` `:165-171`, etc.).
- **Uso observado del patrón `EventBus.*.*.connect/emit`:** muy escaso fuera de tests y pocos módulos. Ejemplos reales:
  - `scripts/audio/narrative_sound.gd:53` conecta `eb.quest.prereq_met`.
  - `scripts/audio/narrative_sound.gd:55` conecta `eb.travel.island_loaded` **pero el propio archivo advierte** `:57,68` que *“EventBus.travel.island_loaded existe en el bus pero ningun dominio lo emite aún (lo hará M28)”* y usa fallback `TravelService.travel_arrived` (`:62`).
  - `scripts/farm/farm_service.gd:53,55` accede a `EventBus.weather` / conecta `clima_cambio` (con guardia defensiva).
  - Tests: `scripts/core/test_infraestructura_m40.gd:145-163,205` (reenvío `infra.game_flow_changed`), `scripts/core/test_smoke_core_hy3.gd:48-54`, `scripts/farm/test_farm_clima.gd:55`, `scripts/core/test_anti_softlock_m66.gd:105`.

**Gap concreto identificado (señal declarada, emisión de dominio no confirmada por código de dominio):**
- `EventBus.travel.island_loaded` — declarada `event_bus.gd:120`; **consumida con fallback** en `narrative_sound.gd:55-68` y documentada como no emitida por el dominio de viajes en ese punto. Requiere verificación funcional al integrar M28/viajes: si ningún emisor publica, el listener del bus no disparará (hoy mitigado por `TravelService.travel_arrived`).

**3.2 Señales locales no mediadas por EventBus (patrón mixto)**

Muchos sistemas declaran/usan señales propias y se conectan directamente a instancias (621 `connect`, 694 `emit` en general). Esto es válido en Godot, pero combinado con 116 autoloads incrementa el acoplamiento punto-a-punto. Ejemplos de señales locales:
- `scripts/inventario/inventario_service.gd:20-27` — `item_added/item_removed/slot_changed/inventario_actualizado/inventario_lleno/item_usado`.
- `scripts/animacion/animation_service.gd:11-19` — `estado_cambiado/animation_started/animation_finished/animation_missing`.
- `scripts/camera/camera_rig.gd:13,16` — `mode_changed/zoom_changed`; `camera_spring.gd:11,14`.
- `scripts/accesibilidad/accesibilidad_manager.gd:13-23` — múltiples señales de perfil/control/subtítulos.

**Limitación:** no es posible afirmar “señal X nunca conectada” de forma total sin ejecutar el juego/escenas; el hallazgo sólido es el **gap documentado** de `travel.island_loaded` y la **baja adopción del EventBus** frente al tamaño del proyecto.

**Conclusión (3):** existe **cableado incompleto/riesgoso** en el bus (`travel.island_loaded` sin emisor de dominio confirmado; narrativa usa fallback). La arquitectura de señales es **mixta** (EventBus + señales locales + llamadas directas a autoloads), lo que dificulta rastrear integraciones.

## 4) Autoloads que actúan como “dios” (demasiadas responsabilidades / superficie global)

**Evidencia cuantitativa (inbound refs, LOC del autoload, refs salientes a otros autoloads, preloads):**

| Autoload | Script | Inbound | LOC | Salientes | Preloads | Riesgo |
|---|---|---:|---:|---:|---:|---|
| `Inventario` | `scripts/inventario/inventario_service.gd` | 108 | 444 | 7 | 3 | **Hub de estado + persistencia** (acumula, remueve, cuenta, serializa; se registra en `SaveManager` `:43-45`). |
| `eventos` | `scripts/eventos/event_manager.gd` | 105 | 901 | 24 | 0 | **Singleton masivo** (901 LOC) y altamente referenciado; posible solapamiento conceptual con `EventBus`. |
| `SaveManager` | `scripts/saving/save_manager.gd` | 92 | 373 | 14 | 0 | Punto central de persistencia; muchos módulos dependen de él. |
| `EventBus` | `scripts/core/event_bus.gd` | 86 | 199 | — | — | Bus global (diseño válido), pero subutilizado y convive con `eventos`. |
| `GameTime` | `scripts/time/game_clock.gd` | 68 | 263 | 12 | 0 | Dependencia temporal transversal. |
| `Construccion` | `scripts/construccion/build_manager.gd` | 24 | 803 | 2 | 0 | **801+ LOC** en un autoload: alta concentración de lógica. |
| `VillagerManager` | `scripts/npc/villager_manager.gd` | 23 | 777 | 17 | 0 | Gestión NPC amplia. |
| `UIManager` | `scripts/ui/core/ui_manager.gd` | 30 | 645 | 19 | 0 | Orquestación UI global. |
| `DataStore` | `scripts/datos/data_store.gd` | 22 | 650 | 10 | 0 | Almacenamiento global (verificar solapamiento con `SaveManager`/estado). |
| `ServiceRegistry` | `scripts/core/service_registry.gd` | 58 | 75 | 0 | 0 | Registro DI (positivo), pero coexiste con acceso directo por nombre de autoload. |

**Observaciones:**
- **116 autoloads** (`project.godot:19-136`) es una superficie global muy alta: favorece acceso desde cualquier lugar y dificulta razonar sobre dependencias.
- **Dualidad `eventos` vs `EventBus`:** ambos existen como autoloads (`project.godot:22,126`) con roles de “eventos”; `eventos` tiene 105 inbound y 901 LOC, mientras `EventBus` define dominios tipados pero muestra poco uso real. Esto sugiere **responsabilidades solapadas** o migración incompleta.

**Conclusión (4):** `Inventario`, `eventos`, `SaveManager`, y en menor medida `Construccion`/`VillagerManager`/`UIManager`/`DataStore` presentan rasgos de **puntos de alta centralidad** (“god-like” por acoplamiento o tamaño). `ServiceRegistry`/`EventBus` apuntan a desacoplar, pero no reemplazan el acceso global dominante.

## 5) Sugerencias (2 acciones para reducir acoplamiento)

### Acción A — Consolidar la mensajería y completar el cableado del EventBus (migración incremental)
- **Objetivo:** reducir dependencias directas entre dominios y eliminar la ambigüedad `eventos` vs `EventBus`.
- **Pasos concretos:**
  1. Definir criterio único: eventos **cross-módulo** → `EventBus.<dominio>.*`; señales **locales al nodo/servicio** → señal propia.
  2. Cerrar el gap conocido: hacer que el dominio de viajes emita `EventBus.travel.island_loaded` (o alinear nombre/contrato) y simplificar `scripts/audio/narrative_sound.gd:53-68` para depender de una sola fuente.
  3. Auditar `scripts/eventos/event_manager.gd` (901 LOC, 105 inbound): extraer subdominios o enrutar eventos inter-sistema hacia `EventBus`, manteniendo API compatible con adaptadores temporales.
  4. Agregar una verificación estática/CI (script headless) que liste señales de `EventBus` sin emisores/consumidores en `scripts/` (excluyendo tests) para evitar regresiones.
- **Impacto esperado:** menor acoplamiento aferente/eferente a singletons de dominio; integraciones trazables en un punto.

### Acción B — Reducir superficie de autoloads: inyección por contratos (`ServiceRegistry`) y fachadas acotadas
- **Objetivo:** bajar las 116 dependencias globales y el patrón “cualquiera llama a cualquier autoload”.
- **Pasos concretos:**
  1. Para consumidores de alto fan-out (`debug_menu`, `ui_root`, `transport_manager`, `main_island`), reemplazar referencias directas por `ServiceRegistry.get_service("contrato")` / interfaces mínimas (el registro ya existe: `service_registry.gd:33-63`, `bootstrap.gd:222-223`).
  2. Partir autoloads grandes por responsabilidad: p. ej. `event_manager.gd` (901 LOC) y `build_manager.gd` (803 LOC) en sub-servicios registrados; `Inventario` exponer una **fachada de consultas/mutaciones** y mover persistencia a integración explícita con `SaveManager` (evitar que dominios conozcan detalles internos).
  3. Regla de nuevo código: **prohibido** `get_node("/root/X")`/referencia directa a autoload fuera de `bootstrap`/composición de escena, salvo contratos justificados; revisar en PR con `rg "/root/|ServiceRegistry"` (ya hay 4446 refs a autoloads: tratar como deuda técnica con presupuesto de reducción por iteración).
- **Impacto esperado:** dependencias explícitas, testabilidad headless (inyectar dobles), y menor riesgo de ciclos de inicialización.

## Conclusión final

El subsistema `scripts/` **no muestra ciclos de dependencias directas** en el grafo estático `preload/extends` (0 SCCs), y cuenta con primitivas de desacoplamiento (`EventBus` por dominios, `ServiceRegistry`, `Bootstrap`). Sin embargo, la integración real está dominada por **alto acoplamiento global**: **116 autoloads**, **4446 referencias** a singletons por nombre, hubs muy referenciados (`Inventario` 108, `eventos` 105, `SaveManager` 92) y **adopción parcial del EventBus** (uso efectivo escaso; gap concreto: `travel.island_loaded` declarado sin emisor de dominio confirmado, con fallback en `narrative_sound.gd:55-68`). Prioridad recomendada: **(A)** unificar/migrar mensajería cross-módulo al `EventBus` y cerrar gaps de cableado; **(B)** reducir la superficie de autoloads mediante contratos/fachadas y refactor de managers grandes (`eventos`, `Construccion`, `Inventario`) para bajar la centralidad.