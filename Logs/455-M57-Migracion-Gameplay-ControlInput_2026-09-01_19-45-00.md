# Log 390: M57 Interfaz de Control iter. 2 — migración gameplay a ControlInput — glm-5.3-flash

**Fecha:** 2026-09-01
**Hora:** 19:45
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración 2 del M57 Interfaz de Control (V0/V1, sobre el núcleo de Deepseek Log 254): migración de gameplay a la capa única de acciones (RF2) — player.gd y simple_walk.gd ya no usan Input directo en el camino principal. Incluye FIX de un bug real del núcleo (vector invertido). Módulo liberado 🟡 88/119.

## Cambios Realizados

### player.gd (migración)
- Cierre del inventario via `_accion_justa_m57("inventario")` — helper de migración con fallback grácil si ControlInput no está (headless/test).
- Sin `Input.is_action_just_pressed("ui_cancel")` en el gameplay.

### simple_walk.gd (migración)
- Movimiento via `ControlInput.vector_movimiento()` (dead zones RF4 aplicadas).
- Salto via acción nueva `saltar` (InputMap: Espacio + botón A de mando) — ya no `ui_accept`.

### control_input.gd (FIX del núcleo Log 254)
- `vector_movimiento()` tenía los ejes invertidos: `get_vector("mover_este", "mover_oeste", "mover_sur", "mover_norte")` ponía este/sur como negativos. Corregido a la firma de Godot: `get_vector(negativo_x, positivo_x, negativo_y, positivo_y)` = (oeste, este, norte, sur). El bug no se había detectado porque no había consumidor real del vector.

### project.godot
- Acción `saltar` agregada al InputMap (faltaba en el catálogo RF5).

### test_migracion_m57.gd (nuevo)
- InputMap completo (10 acciones), API de acciones, player migrado (helper presente, sin Input directo), simple_walk migrado (camino principal ControlInput, fallback solo headless), acción saltar → **0 fallos**.

### Registro
- Regresión: test_control_input (núcleo) 0 fallos.
- Checklist: 88/119 (+2).
- Guía 08 y ESTADO-PARALELO actualizados (fila insertada tras iter. 1 de M57).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/player/player.gd` (helper + migración)
- `game/isla-ancestral/scripts/simple_walk.gd` (migración)
- `game/isla-ancestral/scripts/controls/control_input.gd` (FIX ejes)
- `game/isla-ancestral/project.godot` (acción saltar)
- `game/isla-ancestral/scripts/controls/test_migracion_m57.gd` (nuevo)
- `DOCUMENTACION/57-Interfaz-De-Control/plan-actual/04-Codigo.md` (Notas del Agente iter. 2)
- `DOCUMENTACION/57-Interfaz-De-Control/plan-actual/05-Checklist.md` (88/119 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

## Verificación

- test_migracion_m57.gd: 0 fallos · test_control_input.gd (núcleo): 0 fallos (Godot 4.5 headless).
