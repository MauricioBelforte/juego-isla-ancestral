# Log 266: M53 UI-UX (iter. 2) — Tema cozy global + migración del diálogo a DialogLayer

**Fecha:** 2026-08-30
**Hora:** 04:30
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 2 del M53 (UI-UX). Se implementó el ThemeService (tema cozy global aplicado al root
con herencia a todos los Controls), se conectaron los tooltips por foco (RF6) y se migró la
presentación del diálogo M21 al DialogLayer formal del M53. **Verificado con visión**: captura
del juego muestra el diálogo con tema cozy (panel arena, borde ocre), hint localizado y FPS 60.

## Cambios Realizados

### Código (Godot)
- `scripts/ui/theme/theme_service.gd` — **NUEVO autoload "ThemeService"**: construye el tema
  cozy (ThemeUx) una vez y lo aplica a `root.theme` (herencia global a todos los Controls).
  API: `aplicar_tema_global(scale)`, `set_ui_scale(0.8-1.5)` en vivo (M58), `recargar_fuentes()`
  (M87/M88).
- `scripts/ui/core/ui_manager.gd` — Modificado: tooltip por foco (RF6) — al emitirse
  `ui_focus_moved`, muestra el tooltip del control enfocado vía TooltipService si define
  `tooltip_text`.
- `scripts/ui/layers/dialog_layer.gd` — Modificado: avanzar solo con `interactuar`/Enter
  (no con `pausa`, que queda reservado para cerrar capas).
- `scripts/main_island.gd` — Modificado: la presentación del diálogo M21 la provee DialogLayer
  (UIRoot); la DialogueUI autocontenida queda como fallback si UIRoot falla.
- `project.godot` — autoload `ThemeService` registrado.
- `scripts/ui/test_ui_framework.gd` — Modificado: test del tema global (root.theme aplicado,
  estilos Button presentes, jerarquía tipográfica H1, cambio de escala en vivo). 0 fallos.

### Verificación con visión
- Captura `capturas/cap_53_dialogo_cozy.png`: el diálogo se muestra con el **tema cozy**
  (panel fondo arena + borde ocre del ThemeUx), speaker "npc.catalina" en ocre, texto con
  autowrap, hint localizado "Enter para continuar", fondo dim, FPS 60. Sin regresiones.

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/ui/theme/theme_service.gd` | Creado |
| `scripts/ui/core/ui_manager.gd` | Modificado (tooltip por foco) |
| `scripts/ui/layers/dialog_layer.gd` | Modificado (avance correcto) |
| `scripts/main_island.gd` | Modificado (migración DialogLayer) |
| `project.godot` | Modificado (autoload ThemeService) |
| `scripts/ui/test_ui_framework.gd` | Modificado (test tema) |
| `tools/mcp/godot-mcp/capturas/cap_53_dialogo_cozy.png` | Creada (evidencia visual) |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (265 → 266) |
| `Logs/266-M53-UI-UX-Tema-Cozy-Migracion-Dialogo_2026-08-30_04-30-00.md` | Creado (este log) |

## Validación
- `test_ui_framework.gd` headless: 0 fallos (incluye test de tema global + escala).
- Regresión: `test_dialogos.gd` (0 fallos), `test_localization.gd` (0 fallos).
- Arranque del juego con MCP + captura visual: diálogo con tema cozy funcionando.

## Pendientes honestos
- Fuentes Nunito/Fredoka One (M88): el tema usa la fuente por defecto de Godot.
- Tooltips: cableado hecho; falta contenido de tooltips en los controles de gameplay.
- MinimapWidget (M54) y SeasonWidget en HUD; migración InventoryLayer (M14) a capa M53.
- MenusLayer unificada con el menú principal real (M89).