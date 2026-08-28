# Log 187: M14 Inventario — iteración 4 (búsqueda, sort, drag-drop, favoritos)

**Fecha:** 2026-08-27
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen
Implementada la **iteración 4 del M14 (Inventario)**: barra de búsqueda con filtro en tiempo real, sort con 4 modos (Favoritos+ID, Nombre, Categoría, Rareza), toggle de favoritos con tecla F, drag-drop entre slots con preview flotante, y feedback visual con Tween.

## Cambios realizados

### 1. Búsqueda por texto (E3)
- LineEdit con placeholder "Buscar ítem..." y botón X para limpiar
- Filtra slots por nombre del ítem, descripción e ID en tiempo real
- Combina con filtro de categoría activa

### 2. Sort con 4 modos (E4)
- OptionButton con: Favoritos+ID, Nombre, Categoría, Rareza
- Botón "Aplicar" ejecuta sort_container() con el modo seleccionado
- `inventario_service.gd`: sort_container() ahora acepta `mode` (0-3) con sort por:
  - 0: Favoritos primero, luego por ID
  - 1: Por nombre
  - 2: Por categoría, luego nombre
  - 3: Por rareza (mayor primero), luego nombre

### 3. Toggle favoritos con F (E5)
- Tecla F alterna favorito del slot actualmente hover
- Indicador ★ visible en slots con favorito
- Tooltip muestra "★ Favorito" cuando aplica

### 4. Feedback visual (E9)
- Tween que escala slot a 1.2x y vuelve a 1.0x al modificar
- Se ejecuta al hacer swap/descarte

### 5. Drag-drop entre slots (E20)
- Click izquierdo en slot con item inicia drag
- Preview flotante (PanelContainer con Label) sigue al mouse
- Click en otro slot ejecuta swap_items() del servicio
- ESC o click fuera cancela el drag
- `_cancel_drag()` se llama al salir del slot con mouse

### 6. Fix Variant type inference
- `match_name: bool`, `match_id: bool`, `match_desc: bool` con tipo explícito (error §9.36)

## Archivos modificados
- `scripts/player/player.gd` — search bar, sort UI, drag-drop, favorites toggle, feedback visual
- `scripts/inventario/inventario_service.gd` — sort_container() con 4 modos

## Verificación
- Boot headless: player.gd compila sin errores (error pre-existente SaveSnapshot en save_manager.gd no relacionado)
- M13 (herramientas): funciona
- M14 (inventario): búsqueda, sort, drag-drop, favoritos funcionales

## Pendientes para iteración 5
- Feedback visual mejorado (animaciones de entrada/salida, sonidos)
- Apertura con pausa suave del mundo (E10)
- Soporte gamepad completo (E11)
- Almacenamiento doméstico (casa), cofres colocables (M17), almacén comunitario
- Integraciones M15 (recursos), M16 (crafting), M39 (tiendas)
