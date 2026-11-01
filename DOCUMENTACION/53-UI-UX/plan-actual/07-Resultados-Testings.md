**Modelo:** GPT-5.6 Luna
**Plataforma:** Copilot SDK en VS Code
**Fecha:** 2026-10-31

# 07 — Resultados de pruebas: reanudar y volver al menú

## Entorno y comandos

- Motor: Godot 4.7.2.
- `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/ui/test_m53_pausa_prompts.gd`
- `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/ui/test_m89_menus.gd`

## Resultados

| Suite | Salida observada | Evidencia del escenario |
|---|---|---|
| `test_m53_pausa_prompts.gd` | `39 checks, 0 fallo(s)` — `EXIT 0` | `test_m53_pausa_prompts.gd:L148-L158`: el botón real emite `pressed`; se comprueba que PauseLayer se oculta, el árbol se reanuda y la capa sale de la pila. |
| `test_m89_menus.gd` | `58 checks, 0 fallo(s)` — `EXIT 0` | `test_m89_menus.gd:L191-L225`: pausa, foco direccional, exclusión del botón Guardar deshabilitado, confirmación para volver al menú y reanudación con «Continuar». |

## Causa investigada y corrección

- Con una partida sin cambios, `Guardar` está deshabilitado (`pause_layer.gd:L80-L84`). El recolector anterior de `MenuNavigator` incluía cualquier `Control` visible con foco, también `BaseButton.disabled`; al intentar enfocar ese botón, la navegación podía quedarse sin avanzar hasta «Continuar».
- Se centralizó el filtro en `_can_receive_focus()` y ahora excluye los botones deshabilitados (`menu_navigator.gd:L115-L138`). La regresión automatizada confirma que Guardar no integra los candidatos y que el siguiente botón habilitado sí (`test_m89_menus.gd:L205-L209`).
- La ruta real de reanudación desde pausa cierra `PauseLayer` y recalcula la pausa del mundo (`ui_manager.gd:L551-L559`). La suite M53 ejercita el botón y comprueba la capa oculta, el árbol reanudado y la pila (`test_m53_pausa_prompts.gd:L148-L158`); M89 también verifica volver desde el menú abierto sobre la pausa (`test_m89_menus.gd:L212-L225`).
- Captura runtime antes/después disponible: `tools/mcp/godot-mcp/capturas/53-UI-UX/cap_53_2026-10-31_20-39-08_gpt-luna_pausa-salta-guardar.png` muestra Guardar deshabilitado y foco en «Borrar slot 1»; `tools/mcp/godot-mcp/capturas/167-Isla-Raiz/cap_167_2026-10-31_20-39-56_gpt-luna_continuar-reanuda.png` muestra el mundo reanudado.
- Límite distinto: si MenusLayer recibe «Continuar» sin una PauseLayer visible, `ui_root.gd:L206-L223` solo cambia GameFlowManager a `CARGANDO`; no invoca `SceneManager` ni `SaveManager`. No es la misma ruta de «Continuar» del menú de pausa y queda sin certificar como carga de partida guardada.

## Comprobación visual y límites

- Captura runtime posterior a «Continuar»: `tools/mcp/godot-mcp/capturas/167-Isla-Raiz/cap_167_2026-10-31_20-39-56_gpt-luna_continuar-reanuda.png`.
- La ruta «Volver al menú principal» se verificó en la suite headless; no se registró una captura manual de esa confirmación.
- El buffer de `get_debug_output` incluye errores de recursos ajenos a esta corrección: `res://data/items/item_obj_ite_022.tres:L27` referencia `res://assets/2d/items_m159/ico_item_obj_ite_022.png`, que no existe; el mismo patrón aparece en los recursos `item_obj_ite_053.tres:L27` y `item_obj_ite_054.tres:L27`. No se modificaron.
- `problems` no reporta errores en `ui_manager.gd`, `ui_root.gd` ni las dos suites; sí conserva hallazgos previos en `pause_layer.gd:L17`, `pause_layer.gd:L19` y `pause_layer.gd:L136` (`UNUSED_PRIVATE_CLASS_VARIABLE`, `UNUSED_SIGNAL`, `INT_AS_ENUM_WITHOUT_CAST`), no causados ni modificados por este cambio.
