# Log 215: M14 Inventario — iteración 2 (servicio + UI básica + integración M13)

**Fecha:** 2026-08-27
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Implementada la **iteración 2 del M14 (Inventario)**: señales reactivas, operaciones de movimiento (mover/swap/split/sort), conexión extracción M13→inventario, hotbar visual de 6 slots y panel de inventario con tecla B. El inventario ahora está **conectado al juego** — al romper un bloque con herramienta, el drop se agrega al bolsillo y aparece en la hotbar.

## Cambios realizados

### 1. Fix señales slot_changed (`inventario_contenedor.gd`)
- Agregada señal `slot_changed(idx: int)` al `ContenedorInventario`
- Se emite al modificar slots en add_item (pasada 1 y 2) y remove_item
- Servicio reenvía señal como `slot_changed(container, slot_idx)` para UI reactiva

### 2. Operaciones de movimiento (`inventario_service.gd`)
- `move_item(from_container, from_slot, to_container)` — mueve slot completo con auto-apilado
- `swap_items(from_container, from_slot, to_container, to_slot)` — intercambia dos slots
- `split_stack(from_container, from_slot, amount, to_container)` — separa cantidad exacta
- `sort_container(container, mode)` — ordena por favoritos → id

### 3. Conexión M13→M14 (`player.gd` + `tool_controller.gd`)
- `_on_bloque_extraido()` ahora llama `Inventario.add_item(item_id, amount)` por cada drop
- `_get_drops()` retorna `[{"item_id": "dirt", "amount": 1}]` en vez de `[block_id]`
- `_block_to_item_id()` estático mapea block_id int → item_id string (18 bloques)

### 4. Hotbar visual (`player.gd`)
- CanvasLayer con 6 slots (PanelContainer + Label) en la parte inferior
- Actualización automática por señal `Inventario.inventario_actualizado`
- Muestra primeros 6 slots del bolsillo: id (6 chars) + cantidad

### 5. Panel de inventario (`player.gd`)
- Tecla B abre/cierra panel con grilla 4×6 (24 slots)
- Muestra capacidad "Bolsillo: X/24"
- Botón "Cerrar (B)"
- Mouse visible al abrir, oculto al cerrar
- Actualización por señal en tiempo real

### 6. Fix warning shadowing (`player.gd`)
- Renombrado `result` → `ray_result` en `_break_block()` fallback

## Archivos modificados
- `game/isla-ancestral/scripts/inventario/inventario_contenedor.gd` — señal slot_changed + emisiones
- `game/isla-ancestral/scripts/inventario/inventario_service.gd` — métodos mover/swap/split/sort + forwarding de señales
- `game/isla-ancestral/scripts/tools/tool_controller.gd` — _get_drops() con string IDs + _block_to_item_id()
- `game/isla-ancestral/scripts/player/player.gd` — integración inventario, hotbar HUD, panel inventario, fix shadowing

## Verificación
- Boot headless: **SIN ERRORES** (solo warnings pre-existentes de event_bus.gd)
- M13 (herramientas): sigue funcionando (raycast + extracción)
- M14 (inventario): extracción ahora agrega items al bolsillo
- Hotbar: visible con 6 slots actualizados
- Panel inventario: abre con B, muestra contenido, cierra con B

## Pendientes para iteración 3
- Pestañas de categoría, búsqueda, filtros (sección E del checklist)
- Tooltips con delay y acciones contextuales
- Almacenamiento doméstico (casa), cofres colocables (M17)
- Drag-drop entre slots y contenedores
- Crear .tres de ItemData básicos (dirt, grass, stone, etc.)
- Integraciones M15 (recursos), M16 (crafting), M39 (tiendas)
