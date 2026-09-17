**Modelo:** MiMo V2.5 (OpenCode)
**Plataforma:** OpenCode

# 06-Plan-Testings.md — Módulo 53: UI/UX

## 1. Navegación por Teclado

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-01 | Focus inicial en menú principal | Abrir MenusLayer | Primer botón (Jugar) tiene foco |
| T-02 | Navegación direccional | Flechas ↑↓←→ | El foco se mueve entre botones |
| T-03 | Wrap-around circular | Flecha abajo en último botón | Vuelve al primer botón |
| T-04 | Selección con Enter | Enter en botón "Jugar" | Se emite jugar_pedido |
| T-05 | Cierre con Escape | Escape con capa abierta | Se cierra la capa, foco restaurado |
| T-06 | Tab entre pestañas | Tab en pantalla con tabs | Cambia de pestaña |

## 2. Navegación por Gamepad

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-07 | D-pad en menú | D-pad ↑↓ | Navega entre botones |
| T-08 | A/B en menú | A = seleccionar, B = volver | Funciona como Enter/Escape |
| T-09 | Prompts cambian | Conectar gamepad | Muestra iconos de gamepad (X, A, B) |

## 3. Navegación por Ratón

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-10 | Hover en botón | Mouse sobre botón | Cambia color (hover style) + sonido leve |
| T-11 | Click en botón | Click izquierdo | Selecciona + sonido click |
| T-12 | Hover no roba foco gamepad | Mover mouse mientras se navega con gamepad | El foco del gamepad no se pierde |

## 4. Diálogos

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-13 | Apertura por evento | Emitir dialog_requested | DialogLayer se abre, GameClock pausado |
| T-14 | Typing effect | Texto largo aparece | Se escribe carácter por carácter |
| T-15 | Skip typing | Enter durante typing | Muestra texto completo instantáneamente |
| T-16 | Avanzar página | Enter sin typing | Avanza al siguiente nodo |
| T-17 | Elegir opción | Tecla 1/2/3/4 o foco+Enter | Selecciona opción correcta |
| T-18 | Cierre por dialog_finished | Emitir dialog_finished | DialogLayer se cierra, GameClock restaurado, foco restaurado |

## 5. Inventario

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-19 | Abrir inventario | Tecla I o acción inventario | InventoryLayer visible, mundo pausado |
| T-20 | Selección de slot | Click en slot con ítem | Slot resaltado, botón descarte habilitado |
| T-21 | Swap por doble click | Click en slot A, click en slot B | Ítems intercambiados |
| T-22 | Toggle favorito | Doble click en mismo slot | Se marca/desmarca favorito |
| T-23 | Descarte con confirmación | Click "Descartar" → ConfirmPopup → Confirmar | Ítem eliminado, slot libre |
| T-24 | Cancelar descarte | Click "Descartar" → ConfirmPopup → Cancelar | Ítem conservado |
| T-25 | Filtros de categoría | Click en pestaña de categoría | Solo muestra ítems de esa categoría |
| T-26 | Búsqueda | Escribir en barra de búsqueda | Filtra ítems por nombre/descripción |

## 6. Minimapa

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-27 | Marcadores con formas | Ver marcadores en minimapa | Lugar=cuadrado, Templo=diamante, Tienda=triángulo, Viaje=círculo |
| T-28 | Ícono jugador | Mover personaje | Dot dorado sigue la posición |
| T-29 | Zoom con scroll | Scroll up/down sobre minimapa | Zoom in/out sin afectar cámara |
| T-30 | Pan con middle click | Middle click + drag | Mueve el mapa |

## 7. Feedback

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-31 | Sonido hover | Mover foco a botón | Sonido suave de hover |
| T-32 | Sonido click | Click en botón | Sonido de confirmación |
| T-33 | Sonido inválido | Acción no permitida | Sonido suave (no alarmante) |
| T-34 | Sin flash | Navegar toda la UI | Ningún parpadeo ni flash |

## 8. Accesibilidad

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-35 | Alto contraste | Activar high_contrast | Texto más oscuro, bordes más gruesos |
| T-36 | Reduce motion | Activar reduce_motion | Tweens desactivados, sin transiciones |
| T-37 | Escala de UI 1.5 | Cambiar ui_scale a 1.5 | UI legible, sin solapamientos |
| T-38 | Navegación sin ratón | Solo teclado/gamepad | Todas las pantallas operables |

## 9. Edge Cases

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-39 | Cierre rápido doble pulsación | Doble tap rápido en Escape | Solo se cierra una capa |
| T-40 | Alt-tab | Alt-tab y volver | Foco restaurado en capa visible |
| T-41 | Inventario + diálogo | Abrir inventario mientras hay diálogo | Capas se encolan, no compiten |
| T-42 | 10 notificaciones seguidas | Emitir 10 toasts rápidos | Cola sin desbordes |

## 10. Rendimiento

| # | Escenario | Pasos | Resultado esperado |
|---|-----------|-------|-------------------|
| T-43 | UI budget | Medir con Profiler | UI ≤ 8% del frame |
| T-44 | Draw calls | Escena poblada + HUD | Sin draw calls duplicados |
| T-45 | Minimapa | Mundo voxel cargado | Sin regeneración por frame |
