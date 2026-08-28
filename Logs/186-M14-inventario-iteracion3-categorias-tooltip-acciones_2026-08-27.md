# Log 186: M14 Inventario — iteración 3 (categorías, tooltip, acciones, .tres items)

**Fecha:** 2026-08-27
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Implementada la **iteración 3 del M14 (Inventario)**: 18 .tres de ItemData básicos, pestañas de categoría con contadores, tooltip lazy con delay 0.5s, acciones contextuales (usar/favorito/descartar), cierre con ESC, y fondo semi-transparente. Corregidos 2 errores de type inference y 1 de add_child deferred.

## Cambios realizados

### 1. ItemData .tres básicos (18 archivos)
Creados en `data/items/`: dirt, grass, stone, sand, clay, wood, planks, copper_ore, iron_ore, crystal, gemstone, glass, ancient_crystal, ice, snow, gravel, moss, mud. Cada uno con id, nombre, descripción, categoría, stack_max, rareza y precio.

### 2. Pestañas de categoría (E2)
- Barra de pestañas con 10 categorías: Todos, Construcción, Herramientas, Arte, Items, Naturaleza, Cocina, Trabajo, Ropa, Decoración
- Filtro por categoría: solo muestra slots con items de la categoría seleccionada
- Contadores de capacidad actualizados

### 3. Tooltip lazy con delay 0.5s (E6)
- Tooltip PanelContainer con nombre, descripción, rareza y precio
- Aparece después de 0.5s de hover sobre un slot
- Se oculta al salir del slot
- Posicionado junto al slot hovered

### 4. Acciones contextuales click derecho (E7)
- Menú emergente con: Usar, Favorito/Desfavorecer, Descartar
- Usar: imprime item_id (placeholder para M15/M16)
- Favorito: alterna flag favorito del slot
- Descartar: elimina item del slot con feedback

### 5. Cierre con ESC (E12)
- ESC cierra inventario y oculta tooltip/context menu
- Mouse vuelve a modo capturado

### 6. Fondo semi-transparente
- ColorRect backdrop oscurece el fondo
- Click en backdrop no cierra (por ahora)

### 7. Fixes
- `rareza_str`: tipo explícito `String` en vez de `:=` con array access
- `slot_rect`: tipo explícito `Rect2` en vez de `:=` con get_global_rect()
- `_create_hotbar_hud.call_deferred()`: evita add_child durante _ready()
- Error 9.36 documentado en 07-GUIA-GODOT.md

## Archivos creados
- `data/items/dirt.tres`, `grass.tres`, `stone.tres`, `sand.tres`, `clay.tres`, `wood.tres`, `planks.tres`, `copper_ore.tres`, `iron_ore.tres`, `crystal.tres`, `gemstone.tres`, `glass.tres`, `ancient_crystal.tres`, `ice.tres`, `snow.tres`, `gravel.tres`, `moss.tres`, `mud.tres`

## Archivos modificados
- `scripts/player/player.gd` — panel mejorado, tooltip, context menu, ESC, fixes
- `DOCUMENTACION/07-GUIA-GODOT.md` — error 9.36 documentado

## Verificación
- Boot headless: **SIN ERRORES** (solo warnings pre-existentes)
- M13 (herramientas): sigue funcionando
- M14 (inventario): pestañas, tooltip, acciones funcionales

## Pendientes para iteración 4
- Drag-drop entre slots
- Almacenamiento doméstico (casa), cofres colocables (M17)
- Integraciones M15 (recursos), M16 (crafting), M39 (tiendas)
- Persistencia de hotbar en guardado M59
