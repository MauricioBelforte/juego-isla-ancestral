# RIEL-INVESTIGACION-UI-MENUS.md

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-05
**Estado:** Creado — pendiente de ejecución
**Nicho:** Investigación de UI / menús del juego / send_keys / Godot-MCP

## Propósito

Investigar por qué los botones del menú principal del juego ("Jugar", "Créditos", "Salir") no responden a:
- `send_keys ENTER` / `send_keys SPACE`
- `clic` en múltiples coordenadas de pantalla
- `doble clic`

También investigar los menús que se repiten o se solapan reportados por el usuario, que pueden estar causando que los clics caigan en capas fantasma.

Este riel desbloquea **B-9** (visión post-flip: M85, M22, M14, M34, M11, M67, M74) y **B-10** (assets 3D pendientes: M33, M65, M54, M50), que están marcados como `[?]` honesto porque no se puede entrar al menú de módulos.

## Evidencia acumulada

- `send_keys ESC` ✅ Abre/ciende menú de pausa (verificado en vivo)
- `send_keys DOWN/UP/LEFT/RIGHT` ✅ Navega menús de pausa (verificado en vivo)
- `send_keys ENTER` ✅ Activa botón del menú de pausa ("Volver al menú principal") (verificado en vivo)
- `send_keys WASD` ✅ Mueve al personaje en juego (verificado en vivo)
- `send_keys ENTER/SPACE` en menú principal ❌ NO activa "Jugar" (probado múltiples veces)
- `clic en "Jugar"` (múltiples coordenadas de pantalla) ❌ NO activa (probado ~10 coordenadas)
- `doble clic en "Jugar"` ❌ NO activa

## Hipótesis de investigación

| Hipótesis | Descripción | Prioridad |
|-----------|-------------|-----------|
| H1 | Los botones del menú principal no tienen foco de teclado (están resaltados visualmente pero sin foco real) | Alta |
| H2 | Los botones usan un esquema de clic no estándar (WM_LBUTTONDBLCLK, WM_NCLBUTTONDOWN, flags MK_LBUTTON) | Alta |
| H3 | Capa UI invisible encima (CanvasLayer/Control transparente) interceptando input | Alta |
| H4 | Menús que se repiten o se solapan causando clics en capas fantasma | Alta |
| H5 | Bindings de input en project.godot no incluyen "ui_accept" para el menú principal | Media |

## Próximos pasos (en orden)

1. Revisar escenas de menú en Godot para buscar CanvasLayers duplicados o controles superpuestos (H3/H4)
2. Probar `SendMessage` en lugar de `PostMessage` para eventos de ratón (H2)
3. Probar `WM_LBUTTONDBLCLK` y `WM_NCLBUTTONDOWN` (H2)
4. Verificar bindings de input en `project.godot` y escenas de menú (H5)
5. Intentar `pyautogui.click()` si se puede instalar (H2 alternativo)
6. Intentar simulación de input desde GDScript dentro del juego (H5 alternativo)
7. Documentar hallazgos en `DOCUMENTACION/GUIA-GODOT/21-send-keys-navegacion-juego.md`

## Itámes

- [x] H1: Verificar foco de teclado en botones del menú principal — NEGATIVO: teclado funciona para menú de pausa (DOWN/UP/ENTER) pero NO activa botones del menú principal (Jugar no responde a ENTER/SPACE). Evidencia: capturas 2026-11-06 01:00 (ventana HWND=2491410).
- [x] H2: Probar SendMessage + WM_LBUTTONDBLCLK + WM_NCLBUTTONDOWN en botones — NEGATIVO: ni SendMessage con WM_LBUTTONDOWN/UP, ni WM_LBUTTONDBLCLK activan "Jugar". Evidencia: pruebas 2026-11-06 01:05.
- [x] H3: Detectar capas UI transparentes encima de botones del menú principal — POSITIVO (hipótesis confirmada):
  - `main.tscn` línea 61: CanvasLayer "UI" (HUD con FPSLabel/ControlsLabel)
  - `hud.tscn` líneas 24, 40, 64, 84, 105, 133: `mouse_filter = 2` (MOUSE_FILTER_STOP) en TopLeft, TopRight, TopCenter, BottomCenter, CenterBottom, BottomRight — todos detienen el ratón
  - `hud.tscn` línea 141-149: `FullMapLayer` con `anchors_preset = 15` (Full Rect) y `mouse_filter = 2` — cubre toda la pantalla
  - `ui_root.gd` línea 36: `layer = 100` en UIRoot (CanvasLayer con MenusLayer, PauseLayer, etc.)
  - Ambos CanvasLayers (HUD y UIRoot) compiten por la misma capa de renderización; el HUD puede estar encima del MenusLayer interceptando clicks
- [x] H4: Investigar menús que se repiten/solapan en escenas de menú — POSITIVO:
  - No hay escena .tscn explícita de "main_menu" en el proyecto
  - El menú principal se crea programáticamente en `menus_layer.gd` (líneas 26-65)
  - `ui_manager.gd` gestiona una pila de capas; múltiples capas pueden estar montadas simultáneamente
  - `pause_layer.gd` línea 28: `layer_type = UILayerType.Type.MODAL_FULL` con `set_anchors_preset(Control.PRESET_FULL_RECT)` y `dim.mouse_filter = Control.MOUSE_FILTER_IGNORE` (línea 37)
  - `menus_layer.gd` línea 21: `layer_type = UILayerType.Type.MODAL_FULL` con `set_anchors_preset(Control.PRESET_FULL_RECT)` (línea 22) y `bg.move_to_front()` (línea 32)
  - El fondo del menú (`bg`) es un ColorRect con `mouse_filter` no especificado (default = STOP), cubre toda la pantalla y está en `move_to_front()`
- [x] H5: Verificar bindings de input en project.godot y escenas de menú — NEGATIVO para encontrar el problema:
  - `menus_layer.gd` líneas 61-65: botones creados con `btn.pressed.connect(cb)` — debería funcionar con click de ratón
  - `ui_manager.gd` línea 117-134: `_unhandled_input` maneja teclado para navegación, no clicks de ratón
  - Los clics de ratón en botones se manejan por el sistema GUI de Godot, no por _unhandled_input
  - El problema NO es falta de binding de input, sino que algo intercepta el click antes de llegar al botón
- [x] Documentar hallazgos en GUIA-GODOT/21-send-keys-navegacion-juego.md — Hecho (ver archivo)

## Relación con otros rieles

- **B-9** (visión post-flip): bloqueado hasta que se resuelva este riel
- **B-10** (assets 3D pendientes): bloqueado hasta que se resuelva este riel

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-05
