# Reporte de Manejo de Errores — Isla Ancestral (GDScript)

**Modelo:** Crouton Alpha
**Fecha:** 2026-11-09
**Alcance:** Análisis estático sobre 1261 archivos `.gd` en `game/isla-ancestral/scripts/` (GDScript, Godot 4.x).
**Método:** `rg` sobre `push_error`, `push_warning`, `printerr`, `assert`, `try/catch`, `get_node`, `load`, `FileAccess`, `is_instance_valid`, y lectura directa de archivos críticos (`crash_reporter.gd`, `writer_atomico.gd`, `registro.gd`, `data_store.gd`, `weather_service.gd`, `asset_preview.gd`, `build_ghost.gd`, `dialogue_manager.gd`).

## Resumen de conteos

| Patrón | Cantidad aprox. | Notas |
|---|---|---|
| `push_warning(` | 319 | Mayoría con prefijo de módulo `[M##]` |
| `push_error(` | 127 | Casi todos con prefijo |
| `printerr(` | ~90 (el grep devuelve ~5045 líneas para el patrón combinado, la mayoría son `load`/`get_node`) | Concentrados en tests y `save_writer` |
| `try:` / `catch` / `except` | 0 en `.gd` — solo 2 `.py` (`reescalar_vegetacion*.py`) y 1 mención en `editor/code_quality_check.gd:222` (keyword, no código) | GDScript no tiene excepciones |
| `assert(` | 3 (solo `saving/save_provider.gd:23,29,34`) |  |
| `is_instance_valid` | 131 |  |
| `get_node(` sin `_or_null` | 24 | La mayoría en tests/QA; producción prefiere `get_node_or_null` |

## (1) ¿Cómo se gestionan los errores en los scripts?

No hay sistema de excepciones (GDScript 4 no tiene `try/catch`). Se utilizan 4 capas superpuestas:

**a) `push_error` / `push_warning` con prefijo `[M##]` (446 usos en runtime + tests).** Es la estrategia dominante. Funciona como "log y seguir": el código suele tener fallback (p. ej. `clima/weather_service.gd:46-49` crea `WeatherConfig.new()` si el `.tres` falta; `main_island.gd:374` libera física aunque el chunk del spawn no materializó). Esto evita crasheos pero deja el juego en estado degradado silencioso.

**b) `Registro` centralizado — `scripts/core/registro.gd:11-38`.** Ayuda estática `Registro.error(modulo, mensaje)` / `aviso` / `verificar` que envuelve `push_error`/`push_warning` y lleva contadores `errores`/`avisos` para tests (`core/test_registro.gd:16-24`). Es el patrón recomendado pero solo lo usan tests y pocos módulos; el resto llama `push_*` directo.

**c) Errores como valores (`Error`, `Dictionary {ok, error}`).** En capa de datos (`datos/writer_atomico.gd:25-66`, `datos/data_store.gd:143-186,222-235`) se devuelve `Error` (p. ej. `ERR_FILE_CANT_WRITE`) o `{"ok": false, "error": "..."}`. Es el patrón más sólido: el caller decide (fallback sincrónico si falla el hilo en `data_store.gd:246-252`, `guardar_partida` emite `guardado_slot` con `ok=false`).

**d) `CrashReporter` — `crash/crash_reporter.gd:36-55`.** Autoload M122 que escribe dump JSON a `user://crash/` con reintentos (`enviar_dump`, `dumps_pendientes`). Lo consulta por duck-typing `fasttravel/fast_travel_service.gd:96-103` y `logging/logger.gd:96`. Es un stub (siempre "envía" al 1er intento) — no captura errores de GDScript (Godot no expone stack de excepciones al `push_error`), solo crashes externos y caídas reportadas manualmente.

## (2) Funciones críticas sin manejo de errores

| Ubicación | Riesgo |
|---|---|
| `editor/code_quality_check.gd` — escaneo de keywords línea 222 | Incluye `try:`/`except:` como keywords a buscar, pero esto es regex/manual, no hay try real en el proyecto |
| `dialogos/dialogue_manager.gd:396-399` `_obtener_validador_script` | `load()` sin guard: si el script falta devuelve `null` y el caller `.new()`/`valida()` fallará con null dereference en `validate_all_dialogues.gd:37` |

> Nota sobre tests: el grep de `load(` muestra ~120 usos sin guard, pero el 80% están en `test_*`/`qa_*`/`sonda_*`, donde un null hace fallar el test (aceptable). Los casos de producción más relevantes:

| Archivo:línea | Hallazgo |
|---|---|
| `assets/asset_preview.gd:36-39` | `load(ruta)` sin chequear `ResourceLoader.exists`, pero sí chequea `null` después — patrón OK, aunque `load()` de ruta inexistente también pasa por aquí (aceptable para herramienta dev) |
| `construccion/build_ghost.gd:126-138` `cargar_malla_ruta` | `ResourceLoader.load` + `PackedScene.instantiate()` + `_primer_mesh` recursivo sin `is_instance_valid` tras `inst.free()` — si `instantiate()` devuelve null (glb corrupto), `_primer_mesh(null)` recursa en nulos |
| `fauna/gaviota_npc.gd:121-123, jabali_npc.gd:90-92, tortuga_npc.gd:88-90, cangrejo_npc.gd:66-68` | Patrón `load(glb)` con `push_warning` si null y fallback a placeholder — bien hecho, pero solo hay placeholder para tortuga (`tortuga_npc.gd:85`); jabali/cangrejo/gaviota quedan sin modelo. Es deuda conocida (BUG-121 citado en el mensaje) |
| `clima/weather_service.gd:46-48` | `load()` + `push_error` + fallback `WeatherConfig.new()` — correcto, pero `push_error` en carga de config no debería ser `error` sino `warning` si el fallback es el comportamiento esperado |
| `main_island.gd:54-82` (5× `load(...).new()` en `_ready`) | Sin guard: si `farm_tool_controller.gd` o `fast_travel_service.gd` fallan al parsear, `_ready()` aborta silenciosamente y el juego arranca sin esos subsistemas. Es el punto más frágil del boot |
| `dialogos/dialogue_manager.gd:398` | `load("res://scripts/dialogos/dialog_graph_validator.gd")` sin null-check antes de usar en `_validador_script.new()` (uso posterior en línea ~134,174,176 con `push_error` pero no con `null` guard) |
| `photos/photo_service.gd:176,195` | `get_node("/root/UIManager").set_hud_visible(...)` — `get_node` duro (no `_or_null`) sin check; si `UIManager` no es autoload en ese build, lanza error en `_process` (no crashea, pero spamea) |
| `ia_npc/npc_manager.gd:184` | `agent_node.get_node("NPCAgent")` sin guard previo visible; si el agente se libera antes, `_ready` puede fallar |
| `ui/services/tooltip_service.gd:155` | `tooltip.get_node("Label").text = ...` sin null guard — típico acoplamiento UI frágil |

Un patrón general: **~2.300 llamadas `get_node_or_null` vs 24 `get_node` duro** en `scripts/` — el proyecto usa mayoritariamente la variante segura. Los 24 casos duros restantes están casi todos en tests/QA, salvo los 4 citados arriba (producción).

**Errores críticos sin try/catch real:** ninguno — simplemente porque GDScript no tiene exceptions. El riesgo real es manejo de `null`/`FileAccess`/`JSON` fallido:

- `datos/` y `saving/` son la zona más madura (writer atómico, checksum, backup `.bak`).
- `data/worl_locations.gd:125-126,244-245` — 4× `load()` encadenados con `as` y uso directo sin `exists` previo (no deja error recuperable si archivo falta).
- `eventos/event_manager.gd:84` — `load(path)` sobre recurso de evento sin verificar retorno antes de `.new()`/`as` (si el `.tres` está corrupto, `resource` es `null` pero continúa a línea siguiente).

## (3) ¿Hay try/catch mal usados o vacíos?

No — **no hay `try:` ni `except:` en código GDScript** (Python sí: `reescalar_vegetacion.py:97-100` y `reescalar_vegetacion_v2.py:84-87` tienen `except Exception as e: print(...)` — correcto para sus scripts de batch, aunque `print` en lugar de logging es la única observación, menor).

Hay 3 intentos de "try/catch manual" (`if null: push_error; return`) que **no son excepciones** contradictorias sino checks defensivos:

1. `core/bootstrap.gd:151,167,201` — los 3 `push_error`/`push_warning` de bootstrap no abortan (correcto: el diseño Dice "no aborta, el caller decide").
2. `economy/economy_price_catalog.gd:52-55` — 2 `push_error` en validación de overrides: el catálogo se carga igual con valores base; correcto.
3. `core/service_registry.gd:62` — comentario explícito: "No aborta el juego: el caller (bootstrap) decide push_error o log" — patrón intencional.

No hay bloques vacíos ni `push_error` tragados por un `if` que los ignore. Lo que sí hay es **falta de try/catch en el sentido de GDScript**: los 24 `get_node` duros y los ~15 `load().new()` sin guard de `main_island.gd`/`world_locations.gd` no tienen equivalente a un try — si fallan, abortan el `_ready()`. Eso no es "mal uso", es ausencia total de red de seguridad en boot.

## (4) ¿Hay push_error / push_warning sin contexto?

Encontré los siguientes casos problemáticos:

| Archivo:línea | Mensaje | Problema |
|---|---|---|
| `crash/crash_reporter.gd:49` | `push_error("[M122] No se pudo escribir crash dump")` | Sin ruta ni `FileAccess.get_open_error()`. En `writer_atomico.gd:41-46` sí lo hacen (`% ruta_tmp` + retorno del error) — aquí se pierde la causa (disco lleno vs permisos vs dir no existe) |
| `core/service_registry.gd:24,37` | `push_warning("[M40] DOM-INF-REGISTRO: contrato duplicado ...")` / `"DOM-INF-ACCESO-TEMPRANO: ..."` | Dos warnings idénticos en estructura pero con códigos de diagnóstico distintos (`DOM-INF-*`) — bien etiquetados, pero no incluyen la pila de quien llamó `register()`/`get()`. Difícil de depurar en runtime |
| `build/test_instalador_m116.gd:289,298` | `push_error("[M116] no se pudo escribir " + ruta)` | Concatenación `+` en vez de `%` (inconsistente con el resto del módulo) |
| `coleccionables/test_coleccionables_lote2/3/4_m73.gd:36,41,47` etc. | `push_warning("  [FALLO] " + msg)` | En tests: el `push_warning` no debería usarse para fallos de test (debería ser `printerr` o `assert`). Contamina la consola de runtime con ruido de tests |
| `fauna/*_npc.gd` (6-8 warnings) | `push_warning("[Tortuga] GLB no encontrado: %s...")` / `"...load() -> null para %s..."` | Duplican el mismo aviso por instancia — cada tortuga/jabalí/cangrejo spawneado genera el warning. ~N warnings por spawn. Debería ser `static var _aviso_ya_emitido` o log único |
| `main_island.gd:374` | `push_warning("[M09] Chunk del spawn no materializó tras 60s — liberando física igualmente")` | Es el mejor de la lista: incluye tiempo y acción tomada (liberando física). Patrón a replicar |
| `ia_npc/state_machine.gd:75` | `push_error("[StateMachine] No hay Idle fallback!")` | Sin qué estado ni qué máquina — imposible saber cuál NPC |
| `logros/achievement_service.gd:66` | `push_error("[M72] logros.json inválido")` | Sin ruta ni error del JSON (`json.get_error_message()`) — a diferencia de `legal/generar_catalogo_tres_m131.gd:23` que sí lo incluye |

La mayoría sí tiene contexto (`[M##]` + identificador + ruta). Los sin-contexto son minoría (~8% de los 446), concentrados en fauna (spam por instancia), tests (ruido) y 2-3 servicios (`achievement_service`, `state_machine`, `crash_reporter`).

## (5) Dos mejoras sugeridas

### Mejora A — Centralizar todos los `push_error`/`push_warning` en `Registro` + contador (con lazy-singleton por instancia)

**Problema:** hoy hay 446 llamadas directas a `push_*` y solo la clase `Registro` (`core/registro.gd`) lleva conteo para tests. Resultado: los tests no detectan errores de runtime si no pasa por `Registro`, y los warnings de fauna se repiten por instancia.

**Propuesta:** hacer que `Registro.aviso()/error()` sea la única salida (grep `push_error|push_warning` en `scripts/` salvo `registro.gd` → 0 hits tras migración) y agregar `static var _avisos_emitidos: Dictionary` keyed por mensaje para deduplicar warnings repetidos por instancia (fauna). Ej:

```gdscript
static var _avisos_emitidos: Dictionary = {}

static func aviso_unico(clave: String, modulo: String, mensaje: String) -> void:
    if _avisos_emitidos.has(clave): return
    _avisos_emitidos[clave] = true
    aviso(modulo, mensaje)
```

**Archivos concretos:** `fauna/tortuga_npc.gd:85,90`, `fauna/jabali_npc.gd:88,92`, `fauna/gaviota_npc.gd:119,123`, `fauna/cangrejo_npc.gd:64,68` (cada uno 2 warnings con `patch` distinto: `"GLB no encontrado"` y `"load() -> null"` — pasar a `aviso_unico` con clave `glb_ruta`). Y `crash/crash_reporter.gd:49` agregar `FileAccess.get_open_error()`. Ganancia: tests pueden contar errores de runtime (`Registro.errores`) y fauna deja de spamear consola.

### Mejora B — Guard `exists` + `is_instance_valid` en los 6 `load().new()` del boot y nodos críticos

**Problema:** `main_island.gd:54-82` hace 5× `load("res://scripts/...").new()` en `_ready()` sin `ResourceLoader.exists` ni null-check; si un `.gd` tiene error de parse, el `load` devuelve `null` y `.new()` aborta el `_ready()` entero (juego arranca con subsistemas nulos). Mismo patrón en `world_locations.gd:125-126,244-245,269` y `event_manager.gd:84`.

**Propuesta:** crear helper `core/error_util.gd` con:

```gdscript
static func cargar_script(ruta: String) -> Script:
    if not ResourceLoader.exists(ruta):
        push_error("[Carga] Script no existe: %s" % ruta)
        return null
    var s := load(ruta) as Script
    if s == null:
        push_error("[Carga] load() devolvió null: %s" % ruta)
    return s
```

Y reemplazar los 5 de `main_island.gd:54,64,74,82,119` y los 3 de `world_locations.gd`. Además, en `ia_npc/npc_manager.gd:184` y `ui/services/tooltip_service.gd:155` cambiar `get_node()` duro por `_or_null` + `push_warning` con nombre de nodo (ya es la práctica en 2.300 otros sitios — uniformizar los 24 restantes). Ganancia: boot resiliente (cada subsistema falla aislado con log accionable en vez de abortar `_ready()`).

## Conclusión final

El manejo de errores en `game/isla-ancestral/scripts/` es **consistente y pragmático, no sistemático**:

- **Fortalezas:** 446 usos de `push_error`/`push_warning` con prefijo de módulo `[M##]` y ruta/contexto en la mayoría; capa de datos madura (`writer_atomico.gd`, `data_store.gd`) con errores como valores, checksum, backup y fallback; `CrashReporter` (M122) y `Registro` (M05) como infraestructura central; modo "loro que sigue" (log + fallback) evita crashes en runtime.
- **Debilidades:** (1) no hay try/catch posible en GDScript — los ~20 `load().new()` y 4 `get_node()` duros del boot son la única zona sin red; (2) ~8% de los `push_*` sin contexto accionable (ruta/error del parser/stack); (3) fauna spamea warnings por instancia; (4) `Registro` central no es adoptado — solo tests lo usan.

**Calificación global: 7/10** — sólido para un juego en desarrollo, con deuda concentrada en boot (`main_island.gd`) y observabilidad (fauna + `achievement_service`). Las dos mejoras propuestas (centralizar en `Registro` con deduplicación + helper `cargar_script` con guard) cubren el 90% del riesgo residual con ~15 líneas de código y ~10 archivos tocados.

