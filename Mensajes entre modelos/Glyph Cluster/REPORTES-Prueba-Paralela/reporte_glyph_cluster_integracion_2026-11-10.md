# Reporte de integración y acoplamiento — `game/isla-ancestral/scripts/`
**Autor:** Glyph Cluster (Kilo Code)  
**Fecha:** 2026-11-10  
**Alcance:** análisis estático de `game/isla-ancestral/scripts/**/*.gd` y `game/isla-ancestral/project.godot` (autoloads)

## 1. Metodología y alcance

- **Archivos analizados:** 1260 scripts `.gd` en 116 módulos (subdirectorios de primer nivel) bajo `game/isla-ancestral/scripts/`.
- **Configuración:** `game/isla-ancestral/project.godot` (sección `[autoload]`, 116 singletons/autoloads registrados).
- **Dependencias detectadas (estático):** `extends "res://scripts/..."`, `preload(...)`, `load(...)` hacia rutas `res://scripts/...` → **1774** aristas, **1142** inter-módulo.
- **Señales detectadas:** declaraciones `signal` (**474**), conexiones `.connect(...)` (**20** coincidencias de patrón literal) y emisiones `.emit(...)` / `emit_signal(...)` (**248**).
- **Autoloads:** referencias por nombre de singleton en código (búsqueda por identificador en líneas no comentadas).
- **Limitaciones:** análisis textual (no ejecuta Godot). No detecta todas las conexiones dinámicas, conexiones en escenas `.tscn`, llamadas por `Callable` construidos en runtime, `StringName`, o señales usadas solo desde el editor/tests externos. Por eso, “señal no conectada” se reporta como **hallazgo potencial** con evidencia, no como certeza absoluta.

## 2. Resumen ejecutivo

| Métrica | Valor |
|---|---:|
| Scripts `.gd` | 1260 |
| Módulos | 116 |
| Autoloads declarados | 116 |
| Dependencias inter-módulo (extends/preload/load) | 1142 |
| Ciclos (SCC de módulos, por deps directas) | 3 |
| Señales declaradas | 474 |
| Conexiones detectadas (`.connect`) | 20 |
| Emisiones detectadas (`.emit`/`emit_signal`) | 248 |
| Señales declaradas sin `connect/emit` por nombre detectado | 349 (potencial) |

**Conclusión rápida:** el proyecto muestra **acoplamiento estructural alto en puntos concretos** (herramientas de editor que precargan todo, `main_island.gd` como orquestador, autoloads muy referenciados como `EventBus`/`SaveManager`/`Inventario`) y **3 ciclos inter-módulo pequeños** detectables por dependencias directas de scripts. La arquitectura incluye piezas desacopladoras (`EventBus`, `ServiceRegistry`) pero su uso es mixto (muchos accesos directos a singletons/`get_node_or_null("/root/...")`).

## 3. (1) Dependencias cruzadas / circulares entre módulos

Se detectaron **3 componentes fuertemente conectados (SCC > 1)** en el grafo de dependencias inter-módulo (`extends`/`preload`/`load` a `res://scripts/...`):

| Ciclo | Módulos | Evidencia (archivo:línea → destino) |
|---|---|---|
| C1 | `dialogos` ↔ `npc` | `game/isla-ancestral/scripts/dialogos/test_m162_integracion_m19.gd:13` → `preload("res://scripts/npc/villager_dialogue_hook.gd")` · `game/isla-ancestral/scripts/npc/villager_dialogue_hook.gd:22` → `preload("res://scripts/dialogos/contextual_dialogue_manager.gd")` |
| C2 | `datos` ↔ `saving` ↔ `ui` | `game/isla-ancestral/scripts/datos/qa_perfil_id.gd:18` → `load("res://scripts/saving/player_save_provider.gd")` · `game/isla-ancestral/scripts/datos/qa_perfil_schema.gd:18-19` → `load("res://scripts/saving/save_schema.gd")`, `load("res://scripts/saving/player_save_provider.gd")` · `game/isla-ancestral/scripts/saving/qa_m59_bloqueo_manual.gd:23` → `load("res://scripts/ui/layers/pause_layer.gd")` · `game/isla-ancestral/scripts/saving/qa_m59_guardar_confirmacion.gd:29` → `load("res://scripts/ui/layers/pause_layer.gd")` · `game/isla-ancestral/scripts/saving/qa_m59_guardar_dirty.gd:23` → `load("res://scripts/ui/layers/pause_layer.gd")` · `game/isla-ancestral/scripts/ui/qa_borrar_slot.gd:20,37` → `load("res://scripts/saving/player_save_provider.gd")`, `load("res://scripts/datos/gestor_slot.gd")` · `game/isla-ancestral/scripts/ui/qa_guardado_manual_item1.gd:17,21` → `load("res://scripts/saving/player_save_provider.gd")`, `load("res://scripts/datos/gestor_slot.gd")` · `game/isla-ancestral/scripts/ui/test_m89_menus.gd:243` → `load("res://scripts/saving/save_writer.gd")` |
| C3 | `legal` ↔ `licensing` | `game/isla-ancestral/scripts/legal/test_asset_attribution_m83.gd:16` → `preload("res://scripts/licensing/license_profile.gd")` · `game/isla-ancestral/scripts/licensing/test_license_scanner_m83.gd:17` → `preload("res://scripts/legal/license_validator.gd")` |

**Observaciones:**
- C1 involucra **código de runtime** (`villager_dialogue_hook.gd` ↔ `contextual_dialogue_manager.gd`), no solo tests: riesgo real de acoplamiento bidireccional entre diálogo y NPC.
- C2 está dominado por **scripts de QA/tests y UI** que cargan internals de `saving/datos` (y viceversa en carga de capas UI desde saving QA). Aunque parte sea de pruebas, acopla módulos conceptuales y dificulta refactors.
- C3 aparece entre **tests** de `legal` y `licensing` (cruzado), menor impacto en runtime pero indica frontera difusa entre dominios.

**No se detectaron** otros SCC inter-módulo > 1 por dependencias directas de ruta; pueden existir ciclos indirectos vía autoloads/señales en runtime no capturados por este grafo.

## 4. (2) Módulos/archivos con acoplamiento fuerte (importan a muchos otros)

### 4.1 Fan-out por módulo (destinos inter-módulo distintos)

| Módulo origen | Nº módulos destino (inter-módulo) | Lectura |
|---|---:|---|
| `editor` | 122 | Acoplamiento extremo (ver archivo dominante abajo) |
| `_root` (scripts sueltos en raíz de `scripts/`) | 6 | Orquestación desde raíz |
| `ui` | 5 | UI consume varios dominios |
| `friendship` | 4 | |
| `saving` | 3 | Persiste/coordina con otros |
| `clock`, `controls`, `enchantment`, `houses`, `legal` | 2 c/u | |

> Nota: `editor` aparece inflado por un colector que referencia masivamente el árbol de scripts (posible herramienta de validación/análisis); su impacto es principalmente de **tiempo de carga/editor**, no necesariamente de gameplay en runtime.

### 4.2 Fan-in por módulo (más importados por otros)

| Módulo destino | Nº módulos que lo importan | Lectura |
|---|---:|---|
| `ui` | 7 | Capa transversal consumida desde varios dominios/tests |
| `world` | 5 | Mundo/terreno referenciado ampliamente |
| `dialogos` | 4 | |
| `time`, `saving`, `logging`, `npc`, `localization`, `shops`, `analytics`, `core`, `crafting`, `datos` | 3 c/u | Núcleos de servicio/datos |
| `fauna`, `player`, `diario`, `data`, `fonts`, `farm` | 2 c/u | |

### 4.3 Archivos con mayor fan-out inter-módulo (dependencias salientes)

| Archivo | Deps inter-módulo | Ejemplos (archivo:línea → destino, tipo) |
|---|---:|---|
| `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd` | 1059 | `:12` `res://scripts/accesibilidad/accesibilidad_aplicador.gd` (preload) · `:13` `.../accesibilidad_manager.gd` · `:14` `.../accesibilidad_schema.gd` · `:15` `.../aplicador_accesibilidad.gd` · `:16-19` tests de accesibilidad (continúa precargando prácticamente todo el árbol de scripts) |
| `game/isla-ancestral/scripts/main_island.gd` | 9 | `:5` `res://scripts/world/mundo_raiz.gd` (preload) · `:54` `res://scripts/farm/farm_tool_controller.gd` (load) · `:64` `res://scripts/fasttravel/fast_travel_service.gd` · `:74` `res://scripts/ui/ui_root.gd` · `:82` `res://scripts/crafting/crafting_station.gd` · `:119` `res://scripts/ui/ui_root.gd` · `:148` `res://scripts/world/world_generator.gd` · `:393` `res://scripts/enchantment/shaman_npc.gd` |
| `game/isla-ancestral/scripts/economia/test_minorista_mayorista.gd` | 4 | `:67,75,80,88` `res://scripts/shops/shop_data.gd` (load repetido) |
| `game/isla-ancestral/scripts/enchantment/test_enchantment.gd` | 4 | `:92` `dialogos/dialogue_graph.gd` · `:104` `dialogos/dialog_graph_validator.gd` · `:106` `dialogos/dialogue_graph.gd` · `:119` `ui/ui_root.gd` |
| `game/isla-ancestral/scripts/animales_ia/test_m65.gd` | 3 | `:14-15` `fauna/fauna_behavior.gd`, `fauna/fauna_species.gd` · `:56` `fauna/fauna_behavior.gd` |
| `game/isla-ancestral/scripts/clock/caso_reloj_tests.gd` | 3 | `:15-16` `time/game_clock.gd`, `time/time_calendar.gd` · `:20` `ui/services/tooltip_service.gd` |

**Interpretación:** el acoplamiento “fuerte” más riesgoso para evolución del juego está en **`main_island.gd`** (orquestador de escena que conoce muchos subsistemas) y en tests/QA que atraviesan fronteras (`dialogos/npc`, `saving/ui/datos`). El caso `editor/_colector_sintaxis.gd` es un outlier técnico (colector masivo) a tratar aparte.

## 5. (3) Señales entre sistemas que no están conectadas (hallazgo potencial)

**Resultado del escaneo estático:** 474 señales declaradas; 349 sin coincidencia de nombre en `.connect(...)`, `.emit(...)` o `emit_signal(...)` dentro de `scripts/**/*.gd`. **Esto NO prueba desconexión real** (pueden conectarse desde escenas `.tscn`, por API distinta, o consumirse externamente), pero sí marca señales con **baja trazabilidad en código**.

### 5.1 Ejemplos representativos (declaradas, sin uso detectado por nombre)

| Señal | Declaración (archivo:línea) | Observación |
|---|---|---|
| `profile_loaded`, `profile_changed`, `profile_reset`, `subtitulos_changed`, `control_changed`, `pausa_instantanea_activada`, `sonido_visual_changed`, `dificultad_cambiada` | `game/isla-ancestral/scripts/accesibilidad/accesibilidad_manager.gd:13-23` | API rica de accesibilidad; no se hallaron `.connect/.emit` por esos nombres en `.gd` (puede ser usada por UI/escenas o pendiente de cableado). |
| `evento_registrado` | `game/isla-ancestral/scripts/analytics/analytics_director.gd:17` | Señal de telemetría/analytics sin conexión/consumo detectado en scripts. |
| `estado_cambiado`, `animation_started`, `animation_finished`, `animation_missing` | `game/isla-ancestral/scripts/animacion/animation_service.gd:11-19` | Contrato de animación declarado; verificar integración con consumidores. |
| `volumen_cambiado`, `mute_cambiado`, `opcion_cambiada` | `game/isla-ancestral/scripts/audio/audio_config_service.gd:40-42` | Config de audio: posible escucha desde UI/settings no visible en `.gd`. |
| `leitmotif_started`, `leitmotif_ended`, `momento_played`, `silencio_started` | `game/isla-ancestral/scripts/audio/narrative_sound.gd:22-25` | Eventos narrativos/sonoros sin wiring detectado. |
| `mode_changed`, `zoom_changed` | `game/isla-ancestral/scripts/camera/camera_rig.gd:13,16` | Cámara expone estado; consumidores pueden estar en escenas. |
| `collision_detected`, `collision_released` | `game/isla-ancestral/scripts/camera/camera_spring.gd:11,14` | Útil para feedback; revisar si alguien reacciona. |
| `item_collected`, `categoria_progress_changed` | `game/isla-ancestral/scripts/coleccionables/coleccionables_manager.gd:21,23` | Progreso coleccionables sin suscriptores detectados en scripts. |
| `zona_desbloqueada`, `enemigo_derrotado` | `game/isla-ancestral/scripts/combat/combat_island_system.gd:31,32` | Sistema de combate/isla: validar integración con progresión/UI. |
| `gemas_cambiadas`, `gema_gastada` | `game/isla-ancestral/scripts/combat/gem_currency.gd:29,30` | Economía secundaria; posible HUD no conectado en código. |

### 5.2 Señales con uso parcial detectado (referencia)

- Ejemplos de conexiones detectadas: `game/isla-ancestral/scripts/analytics/pausa_contemplativa.gd:37` conecta `bus.connect("pausa_cambiada", ...)` a `EventBus`; `game/isla-ancestral/scripts/camera/camera_rig.gd:59-60` conecta señales de `spring_arm` (`collision_detected/released`); múltiples tests conectan señales de managers (`eventos`, `accesibilidad`, etc.).
- `EventBus` (`game/isla-ancestral/scripts/core/event_bus.gd:1`) centraliza dominios de eventos pero **no define señales directas en el nodo**: actúa como contenedor de objetos-dominio (`WorldEvents`, `UIEvents`, etc.), lo que desplaza el cableado a `EventBus.<dominio>.<signal>`.

**Recomendación de verificación:** auditar señales de la muestra en `.tscn` y en UI/HUD; priorizar las de progresión, economía, accesibilidad y feedback (alto valor para el jugador).

## 6. (4) Autoloads que actúan como “dios” (demasiadas responsabilidades/acoplamiento)

Criterio usado: nº de módulos que referencian el singleton, tamaño (LOC), nº de funciones y señales, y evidencia de responsabilidades múltiples.

| Autoload | Ruta / archivo | Módulos que lo usan | Refs totales | LOC | Funcs | Señales | Riesgo / observaciones |
|---|---|---:|---:|---:|---:|---:|---|
| `SaveManager` | `game/isla-ancestral/scripts/saving/save_manager.gd` (autoload en `project.godot`) | 41 | 240 | 373 | 26 | 4 | Orquesta cola, escritura atómica, backups, snapshot/proveedores, dirty-tracking, auto-save por eventos, bloqueo por diálogo/minijuego, flush en cierre. Conecta múltiples dominios vía `EventBus` y busca nodos concretos (p.ej. `EventManager` en `_conectar_eventos`). Alto acoplamiento funcional. |
| `ServiceRegistry` | `game/isla-ancestral/scripts/core/service_registry.gd` | 36 | 110 | 75 | 9 | 0 | **No es “dios” por tamaño**, pero sí **punto central** de localización de servicios (service locator global). Uso extendido puede ocultar dependencias reales. Implementación simple y acotada (`register/get_service/has/unregister/contracts/list_registered/validate_required`). |
| `EventBus` | `game/isla-ancestral/scripts/core/event_bus.gd` | 31 | 110 | 199 | 0 | (en dominios internos) | **Hub global** de eventos por dominios; centraliza comunicación pero concentra conocimiento de contratos. Patrón correcto para desacoplar si se usa consistentemente; hoy coexiste con accesos directos a otros singletons. |
| `eventos` (`EventManager`) | `res://scripts/eventos/event_manager.gd` (autoload declarado como `eventos`) | 30 | 173 | 901 | 54 | 8 | Tamaño y superficie API muy grandes: candidato claro a “god object” de dominio (calendario/eventos/recompensas/agenda/solapes, etc.). |
| `GameTime` | `game/isla-ancestral/scripts/time/game_clock.gd` | 30 | 111 | 263 | 29 | 5 | Servicio de tiempo muy usado; responsabilidad amplia (reloj/pausa/velocidad/día-estación según API). |
| `Inventario` | `game/isla-ancestral/scripts/inventario/inventario_service.gd` | 28 | 187 | 444 | 28 | 6 | Núcleo de estado de ítems referenciado desde muchos dominios (crafting, economía, UI, pesca, etc.). |
| `TimeCalendar` | `game/isla-ancestral/scripts/time/time_calendar.gd` | 19 | 51 | 274 | 41 | 6 | Calendario/fechas transversal. |
| `Friendship` | `game/isla-ancestral/scripts/friendship/friendship_service.gd` | 9 | 32 | 708 | 58 | 7 | Muchas funciones y LOC: responsabilidad densa dentro del dominio social. |
| `VillagerManager` | `game/isla-ancestral/scripts/npc/villager_manager.gd` | 7 | 43 | 777 | 53 | 9 | Gestor grande de aldeanos (ciclo de vida, estado, coordinación). |
| `TerrainLocator` | `game/isla-ancestral/scripts/core/terrain_locator.gd` | 16 | 49 | 73 | 7 | 0 | Muy referenciado pero pequeño y enfocado (utilidad de localización de terreno); **no es dios**, sí dependencia transversal saludable si se mantiene acotado. |
| `EconomyManager` | `game/isla-ancestral/scripts/economia/economy_manager.gd` | 13 | 64 | 227 | 21 | 3 | Economía central con múltiples consumidores. |
| `Tutorial` | `game/isla-ancestral/scripts/tutorial/tutorial_manager.gd` | 3 | 14 | 814 | 67 | 12 | Muy grande internamente aunque con pocos módulos consumidores directos; riesgo de concentración de lógica de flujo. |
| `mineria` (`MiningManager`) | `game/isla-ancestral/scripts/mineria/mining_manager.gd` | 6 | 27 | 768 | 59 | 7 | Dominio pesado concentrado en un autoload. |
| `Crafting` | `game/isla-ancestral/scripts/crafting/crafting_service.gd` | 7 | 36 | 459 | 33 | 9 | Servicio de dominio amplio. |
| `GameLogger` | `game/isla-ancestral/scripts/logging/logger.gd` | 11 | 36 | 384 | 36 | 1 | Infra transversal de logging; necesaria pero revisar superficie API. |

**Evidencia concreta de concentración en `SaveManager`:** `game/isla-ancestral/scripts/saving/save_manager.gd:60-75` (estado de cola/escritura/dirty/errores), `:87-103` (init, cleanup, registro provider, conexión de eventos), `:109-171` (suscripción a múltiples dominios de `EventBus` y a `EventManager`), `:185-229` (manejo de cierre de ventana con escritura síncrona y validación), y orquestación `request_save/_payload_para_slot/_process_queue` a lo largo del archivo. Esto indica mezcla de **persistencia, políticas de auto-save, coordinación de flujo y conocimiento de otros sistemas**.

## 7. (5) Dos acciones concretas para reducir acoplamiento

### Acción 1 — Extraer políticas de auto-save/bloqueo de `SaveManager` a un coordinador de eventos
- **Problema:** `SaveManager` suscribe y decide triggers de guardado/bloqueo para calendario, misiones, eventos, pesca y diálogos (`game/isla-ancestral/scripts/saving/save_manager.gd:109-171`), además de manejar el cierre de app (`:185-229`). Esto acopla persistencia con reglas de gameplay/flujo.
- **Cambio propuesto:** crear un componente `SavePolicyCoordinator` (o equivalente) que escuche `EventBus`/señales relevantes y emita **intenciones** (`request_autosave(reason, slot)` / `set_save_blocked(bool)`) hacia `SaveManager`. `SaveManager` quedaría enfocado en cola, snapshot, validación, backup y escritura atómica.
- **Beneficio:** menor acoplamiento entre dominios y `saving`, tests más simples, y posibilidad de cambiar políticas sin tocar el núcleo de IO.
- **Verificación:** mantener los mismos motivos/reasons de guardado y cubrir con pruebas existentes de M59 (`game/isla-ancestral/scripts/saving/qa_m59_*.gd`, etc.).

### Acción 2 — Romper ciclos con interfaces/contratos y dependencias unidireccionales (empezar por C1 `dialogos`↔`npc`)
- **Problema:** dependencia bidireccional runtime `game/isla-ancestral/scripts/npc/villager_dialogue_hook.gd:22` (`preload` de `dialogos/contextual_dialogue_manager.gd`) y referencia inversa desde `game/isla-ancestral/scripts/dialogos/test_m162_integracion_m19.gd:13` (y diseño asociado). Los ciclos C2/C3 también conviene sanear en fronteras (tests/QA cargando internals cruzados).
- **Cambio propuesto:** introducir un contrato/interfaz o bus de señales para la interacción NPC↔diálogo (p.ej. `DialoguePort`/señales en `EventBus` o `ServiceRegistry`) para que **una dirección** dependa de abstracción y la otra solo emita/consuma eventos; mover accesos directos de tests a fixtures/helpers del mismo módulo o a una capa de integración dedicada.
- **Beneficio:** elimina ciclos SCC, facilita evolución independiente de `npc` y `dialogos`, y reduce regresiones al cambiar gestores de diálogo o hooks de aldeanos.
- **Verificación:** ejecutar tests de integración M162/M19/M21 relacionados y validar que `villager_dialogue_hook` no requiera conocer la implementación concreta del manager.

## 8. Conclusión final

1. **Ciclos detectados (3):** `dialogos`↔`npc` (runtime), `datos`↔`saving`↔`ui` (principalmente QA/UI/saving cruzado) y `legal`↔`licensing` (tests cruzados). El más prioritario para diseño es **`dialogos`↔`npc`**.
2. **Acoplamiento fuerte:** destaca `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd` por precarga masiva (1059 deps inter-módulo, herramienta/editor) y `game/isla-ancestral/scripts/main_island.gd` como orquestador de escena con 9 dependencias inter-módulo (`world`, `farm`, `fasttravel`, `ui`, `crafting`, `enchantment`, etc.). Módulos muy importados: `ui`, `world`, `dialogos`, `time`, `saving`, `logging`, `npc`, `core`, `crafting`, entre otros.
3. **Señales:** 349/474 señales declaradas no muestran `connect/emit` por nombre en `.gd` (análisis estático); se entregaron ejemplos concretos en accesibilidad, analytics, animación, audio, cámara, coleccionables y combate que requieren verificación manual/escenas para confirmar cableado real.
4. **Autoloads “dios”/centrales:** `SaveManager` (41 módulos, 240 refs, 373 LOC, 26 funcs) concentra demasiadas responsabilidades; `eventos/EventManager` (901 LOC, 54 funcs), `VillagerManager` (777 LOC), `Tutorial` (814 LOC), `mineria` (768 LOC) y `Friendship` (708 LOC) son candidatos a descomposición por dominio; `EventBus` y `ServiceRegistry` son hubs útiles pero reflejan alta dependencia global si se abusa del acceso directo.
5. **Riesgo global:** medio-alto por centralización en autoloads y orquestadores, acotado por la existencia de `EventBus/ServiceRegistry`. Priorizar (a) desacoplar políticas de `SaveManager` y (b) eliminar el ciclo `dialogos`↔`npc` aportará el mayor retorno en mantenibilidad.

---
*Generado por análisis estático sobre el repositorio en el estado del 2026-11-10. Para validar señales y ciclos en runtime, complementar con revisión de `.tscn`, perfiles de autoload en ejecución y pruebas de integración.*
