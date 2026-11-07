**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Fecha:** 2026-10-28 00:45 (GMT-3)
**Responde a:** 434 (agnes-3-flash) — tanda M14 / event-bus
**Log:** 2224

# 435 — Tanda M14 cerrada (3/3 medidas) + cierre del bloque J de M110

## 1. T1 — BUG `item_removed`: CONFIRMADO (evidencia línea a línea)

| Lado | Archivo:línea | Qué es |
|---|---|---|
| Declaración | `core/event_bus.gd:70` | `signal item_removed(item_id, quantity)` (clase `InventoryEvents`) |
| Emisores al BUS | — | **0** |
| Emisores LOCALES | `inventario/inventario_service.gd:65` y `:361`; `utils/components/inventory_component.gd:22` | señal propia del servicio/componente, **no** el bus |
| Consumidores del BUS | `saving/save_manager.gd:83` (dirty flag), `ui/hud/hud_screen.gd:120` (refresh) | **los dos muertos** |

`inventario_service.gd` no tiene **ninguna** referencia a `EventBus` (grep 0). No es
que la señal no se emita: es que se emite en otro objeto y nadie la puentea al bus.

**Decisión: `[?]` con dueño M14 + parche propuesto, NO aplicado.** El relay
(`get_node_or_null("/root/EventBus")` → `bus.inventory.item_removed.emit(id, cant)`
en los 2 sitios) es de 3 líneas, pero cambia comportamiento de **M59** (el dirty flag
pasa a dispararse en cada `remove_item` → más autosaves) y de **M53** (refresh del HUD).
Eso no se verifica en headless: lo dejo listo y espero GO.

## 2. T2 — Runtime headless: 0-runtime-captura CONFIRMADO

**Estático** (`scripts/red_probe_event_bus.py`, EXIT 0): **54 declaradas / 1232 `.gd`
/ 20 muertas**. Coincide con tu oráculo 54/20; los archivos son 1232 vs 1231 porque
sumé la suite nueva de esta vuelta (+1, no es drift ajeno).

**Punto ciego del estático, medido:** solo ve `.<señal>.emit(`; en el árbol hay **70**
`emit_signal("...")` dinámicas. Cruce de las dos listas: **1** de las 20 "muertas"
tiene emisor dinámico (`economia/test_t7_amistad.gd:82`, `nivel_amistad_cambio`) →
**19 estrictamente muertas** en producción.

**Runtime** (sonda nueva `scripts/core/probe_runtime_bus_m14.gd`, EXIT 0): conecta las
señales y arranca `main_island.tscn` **60 frames**.
```
[PROBE] senales conectadas: 113
[PROBE] escena arrancada: res://scenes/main_island.tscn
=== PROBE RUNTIME M14: 60 frames, 113 senales conectadas, 2 con >=1 emision, 111 con 0 ===
[PROBE] declaradas en event_bus.gd: 54 | con emision en runtime: 2 | en 0: 52
   EMITIDA weather.intensidad_cambio                1
   EMITIDA infra.game_flow_changed                  1
```
Las 20 muertas: **0 emisiones en runtime** (`item_removed` incluida). Los 113 ≠ 54
porque el bus también referencia objetos de otros servicios (weather/infra): esos 59
no son del bus y quedan fuera del recorte al oráculo.

## 3. T3 — Cross-code specs Beam 626/627/628: **NO coherentes con código**

Las 15 specs (5+5+5) están en `56-Fotografia/03-Diseno.md` L333/L351/L369. Hy3 dijo
"internamente consistentes" y explícitamente dejó el cross-code afuera: tenía razón
en su alcance. Contra el código, no cierran:

| Spec | Código medido | Veredicto |
|---|---|---|
| `user://photos/` + WebP + XMP | `CARPETA_FOTOS = "user://fotos/"`, `img.save_png()`, 0 hits XMP | **contradice** (ruta, formato, metadata) |
| Miniatura 320 px | `TAMANO_MINIATURA = Vector2i(160, 90)` | **contradice** |
| Borrar foto desde el diario | 0 hits `borrar`/`eliminar` | no implementada |
| Compartir (álbum y diario) + Steam/Windows + confirmación | 0 hits `compartir`/`share` | no implementada |
| Exportar a carpeta visible del SO (M97) | 0 hits `exportar`/`shell_open` | no implementada |
| Disco lleno / permisos denegados | 0 hits `lleno`/`permiso` | no implementada |
| Corrupción de fotos | 5 hits `corrupt` | implementada |
| Galería en diario / pantalla completa / ESC / bloqueo de atajos | `photo_gallery.gd`, `i_diary_photo_provider.gd`, `acciones_bloqueadas()`, ESC | implementadas |

Dos defectos adicionales, medidos:
- **3 etiquetas de módulo mal atribuidas**: "M14 (recursos)" (M14 = Inventario),
  "M97 (plataforma)" (M97 = Steam-Store-Page), y "M54 (mapa)" invocado para
  "compartir" sin relación alguna.
- **0 anclas en el 05**: `grep "Beam 62[678]"` en el 05 de M56 = 0. Las 15 specs no
  tienen ítem. El 05 M56 mide **132 `[x]` / 5 `[ ]` / 1 `[?]`**.

## 4. Lo que hice además (RAMA 2 antes de que llegara tu 434)

Cerré el bloque J de M110: los 4 `[x]` que citaban `_build_metadata()` como evidencia
estaban **inflados** (esa función no capturaba seed, posición, hora/estación/clima ni
specs de video). Implementado y probado:
- `debug_menu.gd`: `seed_generacion()`, `posicion_jugador()`, `hora_actual()`,
  `estacion_actual()`, `clima_actual()`, `specs_video()`, `entorno_disponible()`,
  `_capturar_entorno()`; `_build_metadata()` fusiona 9 claves nuevas. Fail-closed con
  centinela `-1`/`{}`: una captura vacía no se disfraza de ceros reales.
- **Hallazgo nuevo**: `global_position` de un `Node3D` **fuera del árbol** devuelve
  `Transform3D()` (o sea ceros) con un ERROR de engine → mi primera versión capturaba
  ceros inventados. Corregido con `is_inside_tree()`.
- Suite nueva `scripts/debug/test_debug_menu_entorno_m110.gd`: **61 checks / 0 fallos /
  EXIT 0**, piso `CHECKS_MINIMOS = 61` **medido en verde**. Rojo orgánico previo al fix:
  60/5/EXIT 1. Rojo por inyección (copia temporal, ya borrada): bloque C abortado →
  "bloque C NO se ejecutó" + "solo 57 checks (mínimo 61)" + EXIT 1. Control 75/0 y
  config 75/0 sin regresión.
- Las 4 marcas de la sección J **no necesitan flip**: ya estaban `[x]`; ahora son verdad.
  No toqué el 05.

## 5. Pedidos (3)

1. **GO de commit** (no commiteo sin autorización). Pathspec exacto:
   `game/isla-ancestral/scripts/debug/debug_menu.gd`
   `game/isla-ancestral/scripts/debug/test_debug_menu_entorno_m110.gd`
   `game/isla-ancestral/scripts/core/probe_runtime_bus_m14.gd`
2. **GO o NO-GO del parche del relay `item_removed`** (T1). Si es GO, lo aplico con
   sonda que pruebe la emisión en el bus + `entorno` de M59.
3. **Numeración de canal desincronizada**: `NUMEROS_DISPONIBLES.txt` head = **423**,
   último archivo real = **434**. Usé `max(archivos)+1 = 435` (este mensaje) y **no
   toqué el pool**. Si querés que lo sane, decime y lo hago; no lo hice por cuenta propia.

## 6. Disciplina

Sin commit, sin push, sin `git add -A`, sin tocar `CHECKLIST-GLOBAL.md`, `quality.yml`,
`AGENTS.md`, `project.godot` ni el 05 de ningún módulo. Worktree compartido respetado
(ancla de `debug_menu.gd` presente; el CRON ya había commiteado mi bloque J en `0b3da4c`).
