# Reporte de integración entre módulos — `game/isla-ancestral/scripts/`

**Modelo:** Glyph Cluster  
**Plataforma:** Kilo Code (Agent Manager)  
**Fecha:** 2026-11-09  
**Alcance:** análisis estático de referencias entre módulos en `game/isla-ancestral/scripts/**/*.gd` + configuración `game/isla-ancestral/project.godot`. No se ejecutó el juego; las conclusiones sobre señales “no conectadas” son candidatas estáticas (pueden existir conexiones dinámicas, por escena, por tests o por convención no detectada por regex).

## Metodología (evidencia)

- Inventario: **452** archivos `.gd` bajo `game/isla-ancestral/scripts/`.
- Patrones buscados: `class_name`, `signal`, `extends`, `preload/load(res://scripts/...)`, `.connect/.emit/emit_signal`, `get_node_or_null("/root/...")`, `ServiceRegistry.*`, `EventBus.*`.
- Conteos globales (scripts): declaraciones `signal` **474**; `.connect/connect(` **769**; `.emit/emit_signal` **776**.
- Acoplamiento global (refs): `get_node_or_null(.../root/...)` **825**; `ServiceRegistry.` **11**; `EventBus.` **67**.
- Autoloads declarados en `project.godot`: **116** entradas `*=*res://...` (líneas 16–131, `[autoload]`).

## 1) ¿Hay dependencias cruzadas entre módulos?

**Sí, abundantes.** Se observan tres formas principales:

### 1.a Dependencias por autoload global (acoplamiento implícito)
Muchos módulos acceden a singletons por `/root/...` o por nombre global, lo que crea dependencias de composición/arranque no expresadas en tipos locales.

Ejemplos (con líneas):
- `game/isla-ancestral/scripts/saving/save_manager.gd:88` — `get_node_or_null("/root/EventBus")`; además conecta múltiples dominios del bus (`:93-101`, `:103`, `:105`, `:115-119`).
- `game/isla-ancestral/scripts/core/softlock_guard.gd:71` — `/root/EventBus`; suscripción a `bus.infra.carga_iniciada` (`:73`) y a `SaveManager.save_completed` (`:76`).
- `game/isla-ancestral/scripts/ui/core/ui_manager.gd:47-48` — `/root/EventBus`; conecta `ui.hud_request`/`ui.dialog_requested` (`:52-54`), y se acopla a `/root/ControlInput` (`:58`) y `/root/GameSettings` (`:62`).
- `game/isla-ancestral/scripts/core/bootstrap.gd:126,147` — `/root/EventBus`; registra/autoregistra dominios vía `ServiceRegistry` (`:85-90`, `:149-156`, `:172`, `:178`).
- `game/isla-ancestral/scripts/transporte/transport_manager.gd:183` carga `res://...` de red (ResourceLoader) y `:312` usa `/root/EventBus` para emitir `TRIP_FINISHED`.
- Acoplamiento UI→dominio por autoload: `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd:49,187,202,284,294,325,379,398` (`/root/Inventario`); `game/isla-ancestral/scripts/crafting/crafting_ui.gd:200,264`; `game/isla-ancestral/scripts/shops/shop_ui.gd:210,236,275,288`.

### 1.b Dependencias por `preload/load("res://scripts/...")` entre carpetas-módulo
El análisis de `preload/load` a rutas `res://scripts/<módulo>/...` muestra cruces; el mayor volumen proviene del **módulo `editor`** (herramientas de autoría), que carga casi todo el proyecto.

Top cruces por `preload/load` (conteo, origen → destino):
- `58` `editor -> ui`, `52` `editor -> legal`, `43` `editor -> templos`, `35` `editor -> world`, `34` `editor -> core`, `28` `editor -> dialogos`, `25` `editor -> ia_npc`, etc.
- Módulos que más importan a otros (refs totales / módulos destino distintos): `editor` **1049 / 112**; `_root` **9 / 6**; `ui` **9 / 5**; `saving` **7 / 3**; `friendship` **5 / 4**.

**Interpretación:** `editor` es un “hub” de dependencias, pero mayormente fuera del runtime de juego; aun así, cualquier refactor masivo debe considerar su superficie. En runtime, los cruces menores (`ui`, `saving`, `friendship`, etc.) son más relevantes para acoplamiento funcional.

### 1.c Dependencias por EventBus tipado (intento de desacoplo, con coste central)
`EventBus` actúa como mediador de dominios (`world/economy/inventory/quest/npc/calendar/time/weather/travel/vehicle/ui/player/infra/progresion/diary/fishing`): `game/isla-ancestral/scripts/core/event_bus.gd:11-43` (estructura), `:49-199` (señales por dominio). Esto reduce dependencias directas entre dominios, pero concentra el contrato en un singleton global.

## 2) ¿Hay módulos que importan a muchos otros (acoplamiento fuerte)?

**Sí.** Indicadores de acoplamiento fuerte (autobús global + tamaño/responsabilidad + fan-out):

| Archivo | refs `/root`/ServiceRegistry/EventBus (aprox.) | funcs | signals | LOC (aprox.) | Observación |
|---|---:|---:|---:|---:|---|
| `game/isla-ancestral/scripts/debug/debug_menu.gd` | 26 | 107 | 3 | 1309 | Herramienta de debug: acoplamiento amplio esperado, pero riesgo si se usa como patrón. |
| `game/isla-ancestral/scripts/progresion/progression_manager.gd` | 21 | 55 | 5 | 960 | Manager grande con alto alcance. |
| `game/isla-ancestral/scripts/eventos/event_manager.gd` | 20 | 54 | 8 | 902 | Orquesta varios dominios. |
| `game/isla-ancestral/scripts/transporte/transport_manager.gd` | 19 | 59 | 6 | 703 | Carga recursos + integra bus/save/ui implícitos. |
| `game/isla-ancestral/scripts/friendship/friendship_service.gd` | 19 | 58 | 7 | 709 | Dominio con muchas integraciones. |
| `game/isla-ancestral/scripts/shops/shop_ui.gd` | 19 | 28 | 0 | 368 | UI acoplada a autoloads de dominio. |
| `game/isla-ancestral/scripts/logros/achievement_service.gd` | 18 | 39 | 3 | 623 | Servicio transversal. |
| `game/isla-ancestral/scripts/saving/save_manager.gd` | (refs en cabecera) | — | 4 | ~650+ | **Hub**: suscribe calendario, economía, inventario, misiones, NPC, mundo, pesca, UI, eventos (`:93-119`). |
| `game/isla-ancestral/scripts/ui/core/ui_manager.gd` | 10 | 43 | 3 | 646 | Orquesta capas, foco, pausa, EventBus UI, ControlInput, GameSettings (`:46-71`). |
| `game/isla-ancestral/scripts/core/bootstrap.gd` | — | — | — | 194 | Conoce lista completa de dominios esperados/autoregistro (`:17-27`, `:64-90`, `:171-183`). |

**Conclusión (2):** el acoplamiento fuerte se concentra en **autoload managers/orquestadores** (`SaveManager`, `UIManager`, `Bootstrap`, `Progression`, `EventManager`, `TransportManager`, servicios transversales) y en **UI que consulta autoloads de dominio** directamente. Esto es funcional, pero aumenta el coste de cambio y el riesgo de orden de inicialización.

## 3) ¿Hay señales entre sistemas que no están conectadas?

**Hallazgos (candidatos estáticos, no prueba definitiva):**

- **Declaradas sin `.connect` encontrado por nombre (heurística): 209/474.** Muchas son señales de `EventBus` (contrato central) o de dominios que pueden conectarse dinámicamente, desde escenas `.tscn`, o en tests; la heurística no ve `connect(Callable)` con referencias indirectas en todos los casos. Aun así, destacan casos concretos:
  - `game/isla-ancestral/scripts/core/event_bus.gd:171` — `signal boot_completado()` (dominio `infra`). `Bootstrap` lo emite (`game/isla-ancestral/scripts/core/bootstrap.gd:132`) y documenta “0 consumidores” (`:124-125`), pero **no se encontró `.connect` a `boot_completado` en `scripts/`**. Riesgo: contrato de arranque sin oyentes (hoy aceptado por diseño, pero frágil si se espera reacción).
  - `game/isla-ancestral/scripts/core/scene_manager.gd:13-15` — `cambio_iniciado/cambio_completado/cambio_fallido`: emitidas por el manager, pero **no se hallaron conexiones** en scripts (pueden usarse externamente o faltar integración).
  - `game/isla-ancestral/scripts/core/softlock_guard.gd:28,31` — `recuperacion_completada`, `toast_requerido`: emitidas (`:163,176`), sin conexiones detectadas en scripts (posible deuda de UI/telemetría).
  - En `EventBus`, señales como `chunk_modified` (`event_bus.gd:54`), `biome_changed` (`:56`), `vessel_arrived` (`:104`), `vehicle_docked/aviso` (`:130,132`), `layer_requested/confirm_requested` (`:142,144`), `ui_layers_changed/ui_focus_moved` duplicadas a nivel bus (`:148,150`), `player_died/level_up/damage_taken` (`:154-158`), `categoria_completa` (`:188`) aparecen como candidatas sin conexión directa por nombre en el barrido; **requieren verificación runtime/escenas** antes de actuar.

**Conclusión (3):** hay **candidatas de señales huérfanas o subutilizadas**, especialmente contratos de infraestructura (`boot_completado`, `SceneManager`), feedback/recuperación (`SoftlockGuard`) y parte del `EventBus`. Se recomienda auditar con una sonda runtime (similar a `game/isla-ancestral/scripts/core/probe_runtime_bus_m14.gd:7-45`, que ya advierte emisiones dinámicas no vistas por grep) y revisar conexiones en `.tscn`.

## 4) ¿Hay autoloads que actúan como “dios” con demasiadas responsabilidades?

**Sí, hay indicios claros en varios autoloads** (116 en total: `project.godot:16-131`).

- **`Bootstrap`** (`res://scripts/core/bootstrap.gd`, autoload `project.godot:25`): registra servicios core, valida requeridos, autoregistra dominios con un **catálogo hardcodeado** de la “lista completa” (`:17-27,64-90`), sincroniza flujo de juego, decide carga de escena principal vs CLI (`:137-166`), emite `boot_completado` (`:120-133`), verifica integridad de dominios (`:171-183`) y expone API de registro. Centraliza conocimiento transversal del arranque.
- **`EventBus`** (`project.godot:16`): concentra **todos los dominios** y ~150+ señales tipadas en una fachada global (`event_bus.gd`). Es un “dios de comunicación”: útil para desacoplar pares, pero crea dependencia omnipresente y un punto de cambio de contrato.
- **`UIManager`** (`project.godot:43`): pila modal, foco, pausa del árbol, integración con `EventBus` UI, `ControlInput`, `GameSettings`, tooltips, hover sounds, restauración de foco, accesibilidad M58/M87 (`ui/core/ui_manager.gd:46-120+`). Alta cohesión aparente pero **múltiples razones de cambio**.
- **`SaveManager`** (`project.godot:21`): cola/atomicidad/backups, snapshot/providers, carga, dirty tracking, auto-save por día/misión/evento, bloqueo por diálogo/pesca, integración con EventBus y múltiples dominios (`saving/save_manager.gd:22-119`). Es un orquestador de persistencia con amplio fan-in/fan-out.
- **`ServiceRegistry`** (`project.godot:18`): registro/consulta/validación, avisos de acceso temprano, diagnóstico de duplicados (`core/service_registry.gd`). Más acotado, pero combinado con `Bootstrap` forma un núcleo de composición global.
- **Candidatos adicionales por tamaño/acoplamiento:** `ProgressionManager`, `EventManager`, `TransportManager` (tabla sección 2). El **volumen de autoloads (116)** también sugiere presión hacia el patrón “singleton global” que puede escalar a responsabilidades difusas si no se gobierna.

## 5) Dos acciones para reducir acoplamiento

### Acción 1 — Introducir “puertos”/interfaces de dominio y resolverlos por `ServiceRegistry` (reducir `/root` hardcodeado)
**Objetivo:** que UI y orquestadores dependan de contratos (nombres de servicio + API mínima) en vez de rutas `/root/<Autoload>` y del árbol de escena.

- Pasos concretos: (1) definir contratos estables en `ServiceRegistry` (p. ej. `inventario`, `economia`, `time`, `ui_notifications`) y asegurar registro en bootstrap con verificación; (2) reemplazar accesos repetidos tipo `get_node_or_null("/root/Inventario")` en `ui/layers/inventory_layer.gd:49,187,202,284,294,325,379,398`, `crafting/crafting_ui.gd:200,264`, `shops/shop_ui.gd:210,236,275,288` por `ServiceRegistry.get_service(...)` o un helper tipado; (3) prohibir nuevos `/root/...` fuera de `core/*` salvo justificación.
- Beneficio: menor acoplamiento al nombre del autoload/escena, testabilidad con dobles, y arranque más observable (ya existe `validate_required`/avisos en `service_registry.gd`).

### Acción 2 — Segmentar `EventBus` y gobernar señales (dominios acotados + auditoría de huérfanas)
**Objetivo:** mantener el desacoplo evento-driven sin convertir `EventBus` en un contrato monolítico difícil de evolucionar.

- Pasos concretos: (1) establecer una regla: señales nuevas deben tener **al menos un emisor y un consumidor previstos** documentados; para contratos “futuros” (p. ej. `boot_completado` en `event_bus.gd:171`), marcar explícitamente estado (`@experimental`/nota) o añadir un consumidor no-op de diagnóstico; (2) ejecutar periódicamente una sonda runtime tipo `core/probe_runtime_bus_m14.gd` en CI/headless para detectar señales declaradas nunca emitidas/conectadas en escenarios reales; (3) revisar `SceneManager` (`:13-15`) y `SoftlockGuard` (`:28,31`) para conectar o retirar señales; (4) a mediano plazo, evaluar sub-buses por dominio cargados perezosamente o módulos que suscriban interfaces, reduciendo la necesidad de que cada sistema conozca el bus completo.
- Beneficio: menos superficie de cambio global, detección temprana de wiring roto, y contratos más claros entre sistemas.

## Conclusión final

El proyecto presenta **dependencias cruzadas significativas** propias de una arquitectura centrada en **autoloads (116)**, con `EventBus`/`ServiceRegistry` como ejes de integración. El acoplamiento fuerte se concentra en **orquestadores** (`SaveManager`, `UIManager`, `Bootstrap`, managers de progresión/eventos/transporte) y en **UI que accede directo a dominios por `/root`**. El módulo `editor` domina los `preload/load` cruzados (herramienta, no runtime). Existen **candidatas de señales sin conexión** detectables estáticamente —destaca `infra.boot_completado` emitida sin oyentes en scripts, y señales de `SceneManager`/`SoftlockGuard`— que deben validarse con sonda runtime/escenas antes de eliminarlas. Priorizar **contratos por `ServiceRegistry`** y **gobernanza/auditoría de señales** reducirá el acoplamiento sin romper el patrón “Signal Up, Call Down” ya adoptado.
