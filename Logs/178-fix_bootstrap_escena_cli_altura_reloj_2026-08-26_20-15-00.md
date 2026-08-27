# Log 178: Fix bootstrap escena CLI + altura negativa widget reloj — verificación in-engine M30

**Fecha:** 2026-08-26
**Modelo:** GLM
**Plataforma:** Cline

## Resumen

El usuario reportó que no veía el reloj en pantalla (solo FPS, controles WASD, tictac, terreno verde, cielo celeste). Se relanzó `preview_reloj.tscn` y se diagnosticaron y corrigieron **3 bugs** que impedían ver el widget. El reloj quedó **verificado visualmente in-engine**: visible en la esquina superior derecha y avanzando en vivo (08:00 → 09:00).

## Cambios Realizados

### Bug 1 — Bootstrap pisaba la escena pedida por CLI (causa del reporte del usuario)
- El autoload `bootstrap.gd` hacía `change_scene_to_file(main_island.tscn)` sin importar qué escena se lanzara: al abrir `preview_reloj.tscn` cargaba la isla con su HUD de debug (FPS/WASD) — por eso el usuario veía FPS y controles pero no el reloj.
- **Fix:** `_load_main_scene()` ahora compara `get_tree().current_scene.scene_file_path` con `MAIN_SCENE_PATH`: si difiere (escena CLI), no redirige; si es igual, omite la recarga (evita doble carga en arranque normal).

### Bug 2 — Altura negativa del panel del reloj (invisible aún con la escena correcta)
- `w_reloj.gd` hacía `set_anchors_preset(PRESET_TOP_RIGHT)` (que deja `offset_bottom = 0`) y luego fijaba solo `offset_top = 16` → altura `0 - 16 = -16 px` → rectángulo degenerado, sin errores de script.
- **Fix:** reemplazada la manipulación manual de offsets por la API canónica `set_anchors_and_offsets_preset(PRESET_TOP_RIGHT, PRESET_MODE_MINSIZE, 16)`, que posiciona por tamaño mínimo y sigue el borde derecho en cualquier resize.

### Bug 3 — Recorte del HUD por escalado DPI 125 % de la ventana
- La ventana creada por CLI quedaba con cliente ≈1152 px físicos pero el render 1:1 → el panel anclado a la derecha se recortaba (invisible en pantalla aunque el rect lógico fuera correcto).
- **Fix:** `DisplayServer.window_set_mode(WINDOW_MODE_MAXIMIZED)` desde la preview: Godot recalcula viewport y zoom con el tamaño real del monitor (1242×648) y el HUD queda íntegro. Verificado con captura in-engine.

### Mejoras de verificación
- `preview_reloj.gd`: debug de rects (`[M30-DEBUG]`) + **auto-captura de 2 frames del viewport in-engine** (`[M30-CAP]`) con 6 s de diferencia — método confiable que evita las capturas stale del SO (la MCP `capture_window` y `ImageGrab` devolvieron frames cacheados/ventanas tapadas).
- Nuevo script reutilizable `tools/mcp/godot-mcp/scripts-reutilizables/cap_printwindow.py` (captura HWND vía `PrintWindow`, funciona con ventana tapada).
- Script de prueba `tools/mcp/godot-mcp/scripts-prueba/verificar_reloj_vivo.py` (análisis de píxeles; quedó obsoleto frente a la captura in-engine, se conserva como referencia).

## Verificación

- `[M30-DEBUG]` maximizado: `WReloj rect=[P:(994,16), S:(232,121)] visible:true`; viewport 1242×648 (completo).
- Captura in-engine final (`cap_30_2026-08-26_20-06-01_inengine.png`): reloj **09:00**, "Lunes, 1 de Primavera, Año 1", chip "Primavera", panel íntegro en la esquina superior derecha.
- Consola sin errores de script.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/core/bootstrap.gd` — fix escena CLI (respaldo: `scripts/core/Obsoletos/2026-08-26_19-20-00_bootstrap.gd`)
- `game/isla-ancestral/scripts/clock/w_reloj.gd` — fix anclaje canónico (respaldo: `scripts/clock/Obsoletos/2026-08-26_19-35-00_w_reloj.gd`)
- `game/isla-ancestral/scripts/clock/preview_reloj.gd` — maximizado + debug rects + auto-captura in-engine
- `tools/mcp/godot-mcp/scripts-reutilizables/cap_printwindow.py` — NUEVO
- `tools/mcp/godot-mcp/scripts-prueba/verificar_reloj_vivo.py` — NUEVO
- `tools/mcp/godot-mcp/capturas/30-Reloj-En-Tiempo-Real/` — iter4–iter8 + in-engine + maximizada (evidencia completa)
- `DOCUMENTACION/07-GUIA-GODOT.md` — §9.25 y §9.26 + histórico
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` — descubrimientos de capturas (stale/in-engine/PrintWindow)
- `DOCUMENTACION/30-Reloj-En-Tiempo-Real/plan-actual/05-Checklist.md` — nota de re-verificación
- `CHECKLIST-GLOBAL.md` — fila 48 actualizada (actividad 20:10, notas Log 178)

