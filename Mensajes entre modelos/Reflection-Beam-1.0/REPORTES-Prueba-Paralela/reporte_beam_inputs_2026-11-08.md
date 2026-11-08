# Reporte: Análisis de gestión de inputs (teclado/mouse/gamepad)

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo
**Fecha:** 2026-11-08
**Proyecto:** juego-isla-ancestral / game/isla-ancestral

## 1. Archivos analizados

- `game/isla-ancestral/scripts/controls/control_input.gd` (autoload `ControlInput`, M57) — capa única de acciones.
- `game/isla-ancestral/scripts/player/player.gd` — movimiento/interacción con teclas hardcoded.
- `game/isla-ancestral/scripts/camera/follow_camera.gd` — rotación mouse, zoom scroll.
- `game/isla-ancestral/scripts/debug/debug_menu.gd` — registra acciones en runtime (F1/backtick, Esc).
- `game/isla-ancestral/project.godot` sección `[input]` (líneas 181 en adelante) — bindings por defecto.

## 2. (1) Cómo se gestionan las entradas

Existen **dos capas paralelas y no unificadas**:

1. **ControlInput** (`control_input.gd`): autoload que envuelve `InputMap` con acciones por nombre (`accion_presionada`, `accion_justa`, `eje`, `vector_movimiento`), detección de dispositivo activo (`_unhandled_input`, líneas 109–124), remapeo con detección de conflictos (`remapear`, `hay_conflicto`, líneas 168–184), dead zones, sensibilidad/inversión, vibración y persistencia atómica JSON (`_guardar_config`/`_cargar_config`, líneas 278–308).
2. **Lectura directa de `Input`** en `player.gd` (`_physics_process`, líneas 303–348, 413–420) con teclas hardcoded (W/A/S/D, espacio, C/V/N/T, Q/E), y en `follow_camera.gd` (`_unhandled_input`, líneas ~64–78) con `InputEventMouseMotion` y `MOUSE_BUTTON_WHEEL_*`.

Resultado: el jugador usa teclas fijas que **no pasan por ControlInput**, por lo que el remapeo y la persistencia no afectan el movimiento. Solo las consultas puntuales usan el helper `_accion_justa_m57` (player.gd:53), que además no se invoca en el flujo principal.

## 3. (2) Validación de inputs antes de usarlos

- ControlInput **no valida** que la acción exista antes de llamar `Input.is_action_pressed` (`accion_presionada`, línea 63; `accion_justa`, línea 66; `eje`, línea 70). Una acción inexistente devuelve `false` silenciosamente (sin error explícito).
- `_dict_a_evento` (líneas 370–386) devuelve `null` para tipos desconocidos y `_aplicar_serializado` (líneas 337–357) solo verifica `InputMap.has_action(accion)` antes de agregar, pero **no evita duplicados** ni valida índices (ej. `keycode` 0).
- `remapear` (líneas 168–175) borra el evento con `action_erase_event` y luego `action_add_event`; si el erase falla, el evento se duplica.
- `player.gd` no valida que `_camera`, `_terrain` o `_voxel_tool` existan antes de usarlos en varios puntos (ej. `_do_raycast` sí valida `_camera`, pero `_break_block` asume `_voxel_tool`).

## 4. (3) Problemas de inputs fantasma o duplicados

- **Duplicación al cargar config**: `_aplicar_serializado` (líneas 337–357) hace `action_add_event` sin limpiar los eventos previos. Si `_cargar_config` se ejecuta más de una vez (o al combinar defaults de `project.godot` con remapeos guardados), la misma tecla queda registrada dos veces en la acción.
- **Conflicto de bindings**: en `project.godot` `[input]`, `interactuar` y `equipamiento` comparten la tecla **E** (physical_keycode 69). También `pausa` (Esc) y `debug_menu_close` (Esc) y el toggle de mouse en `player.gd` (líneas 303–313) consumen Esc, generando handlers duplicados.
- **Teclas dev sin guardas de UI**: `player.gd` procesa W/A/S/D y saltos en `_physics_process` incluso con inventario abierto en parte del flujo (solo `_tool_controller.input_habilitado` se desactiva; el movimiento horizontal no se bloquea).
- **ControlInput._unhandled_input** (líneas 109–124) no llama `set_input_as_handled()`, por lo que el evento sigue propagándose a otros `_unhandled_input` (player, cámara), pudiendo generar respuestas fantasma.
- `_restaurar_accion` (líneas 258–264) borra todos los eventos pero no repone defaults, dejando la acción vacía hasta recargar la escena.

## 5. (4) Bindings de teclado configurados correctamente

- `project.godot` define correctamente WASD + joypad axes para `mover_*`, Space + joypad button 0 para `saltar`, mouse wheel para zoom, Esc para pausa.
- **Inconsistencia de catálogo**: `ControlInput.ACCIONES_CATALOGO` (líneas 29–33) **no incluye** `saltar`, `diario`, `equipamiento`, `ocultar_hud`, `tomar_foto`, `colocar`? (incluye `colocar`). Por tanto, esas acciones no se serializan ni se remapean desde ControlInput.
- `ControlInput.eje()` (líneas 70–73) usa `deadzone_palanca_izq` para **todas** las acciones, incluyendo triggers de cámara, lo cual es incorrecto (debería usar `deadzone_gatillo` para gatillos).
- `follow_camera.gd` no usa acciones del InputMap para zoom/rotación; lee eventos crudos, por lo que no es remapeable.

## 6. (5) Sugerencias de mejora (2)

1. **Unificar la lectura de input en ControlInput**: migrar `player.gd` y `follow_camera.gd` para usar `ControlInput.accion_presionada/accion_justa/vector_movimiento/eje` en lugar de `Input.is_key_pressed(KEY_*)` y eventos crudos; ampliar `ACCIONES_CATALOGO` con `saltar`, `diario`, `equipamiento`, `ocultar_hud`, `tomar_foto`. Esto habilita remapeo, persistencia y detección de dispositivo de extremo a extremo.
2. **Corregir `_aplicar_serializado` para evitar duplicados/fantasmas**: antes de `action_add_event`, borrar los eventos existentes de la acción (o deserializar solo si el archivo es válido y limpiar primero); añadir guardas `InputMap.has_action` en `accion_presionada/accion_justa/eje`; resolver el conflicto de **E** (interactuar vs equipamiento) asignando teclas distintas y consumir eventos en `_unhandled_input` de ControlInput con `set_input_as_handled()` cuando cambie el dispositivo.

## 7. Conclusión final

La gestión de inputs está **fragmentada**: existe una capa bien diseñada (`ControlInput`) con remapeo y persistencia, pero el gameplay (`player.gd`, `follow_camera.gd`) la ignora y lee teclas/eventos directos de Godot. Se detectan **duplicados reales** (config que re-agrega eventos sin limpiar, binding E duplicado entre `interactuar` y `equipamiento`) y **riesgo de inputs fantasma** (Esc consumido por varios handlers, eventos no consumidos en ControlInput, teclas dev activas con UI abierta). Recomendación: unificar todo el gameplay a través de ControlInput y endurecer la validación/limpieza en `_aplicar_serializado`.

---
*Reporte generado por Reflection-Beam-1.0 (Kilo).*
