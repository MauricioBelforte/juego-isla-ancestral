# Log 1705: M53 — 4 suites headless verdes (46 checks), 2 bugs corregidos (BUG-129/130), 5 flips → 146/19/0

**Fecha:** 2026-10-11
**Hora:** 22:24
**Modelo:** Ling 3.1 Flash
**Plataforma:** Kilo Code

## Resumen

Cierre de los ítems de runtime verificables de M53-UI-UX (continuación del takeover msg 54/55). Los 4 tests headless quedaron verdes (46 checks / 0 fallos / EXIT 0), se corrigieron 2 bugs de producción encontrados en el proceso, y se flippearon 5 ítems con evidencia test↔disco.

## Cambios Realizados

- **BUG-129** (`menu_navigator.gd:71-72`): `wrapi` de Godot 4.7 tiene el parámetro **max EXCLUSIVO** (range = max−min; verificado empíricamente con sonda headless: `wrapi(499,0,499)=0`, `wrapi(4,0,4)=0`, `wrapi(-1,0,4)=3`). El wrap-around de `wrap_focus` ciclaba por [0, N−2]: **el último control de toda lista era inalcanzable** por navegación direccional (con 2 controles, el segundo jamás se enfocaba; con 500, el ciclo era de 499). Fix: `wrapi(next_idx, 0, focusables.size())`.
- **BUG-130** (`notification_service.gd:5-7, 105-115`): los toasts eran **ilegibles con el tema global** — el Label de texto y el de icono no tenían `font_color` override y heredaban `COLOR_TEXT_DARK` (theme_ux.gd:235) sobre el panel oscuro (0.15,0.12,0.10) = **1.26:1 WCAG**. Fix: overrides explícitos (texto `Color(0.92,0.88,0.82)` = 12.52:1; icono `Color(0.85,0.72,0.35)` = 8.46:1, misma paleta del tooltip). Docstring corregido (decía "con SFX"; el servicio es visual, el SFX lo reproduce el emisor).
- **test_m53_wcag.gd**: extendido de 13 a **17 checks** — nueva `_test_capas_oscuras()` que instancia TooltipService y NotificationService reales, aplica el tema global como en runtime (`root.theme = ThemeUx.build()`) y verifica los ratios de tooltip título/cuerpo y toast icono/texto sobre sus paneles oscuros.
- **test_m53_extremos.gd**: fix del bloque Tween (BUG-048: Tween es RefCounted en Godot 4.7, no Node — `create_tween()` en vez de `Tween.new()`+`add_child()`; limitación documentada en el propio test).
- **DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md**: flips L137 (I.8), L152 (J.10), L171 (L.1), L172 (L.2), L179 (L.9) con evidencia `archivo:línea` + ratios. Totales corregidas: **146 [x] / 19 [ ] / 0 [?] = 165** (conteo verificado por regex). Nota de lote agregada.
- **DOCUMENTACION/11-BUGS.md**: BUG-129 y BUG-130 registrados (§5 Tabla Resumen + §7 Bugs Resueltos, plantilla completa con pasos para reproducir y verificación).
- **DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md**: **§36** (`wrapi`/`wrapf` max exclusivo + Label sobre panel oscuro con tema global) + 2 filas en la tabla de referencia rápida + línea Histórico.
- Sonda temporal `game/isla-ancestral/scripts/ui/probe_wrapi_tmp.gd` borrada tras la verificación (regla §24: scripts esporádicos de prueba).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/ui/core/menu_navigator.gd` (L71-72)
- `game/isla-ancestral/scripts/ui/services/notification_service.gd` (L5-7, L105-115)
- `game/isla-ancestral/scripts/ui/test_m53_wcag.gd` (17 checks)
- `game/isla-ancestral/scripts/ui/test_m53_extremos.gd` (fix Tween)
- `DOCUMENTACION/53-UI-UX/plan-actual/05-Checklist.md` (5 flips + Totales + nota)
- `DOCUMENTACION/11-BUGS.md` (BUG-129, BUG-130)
- `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md` (§36)
- `DOCUMENTACION/TAREAS-POR-MODELO/ling-3.1-flash/BACKLOG-MASTER.md` (L-20)
- `Mensajes entre modelos/Ling-3.1-Flash/58-2026-10-11_22-24-22-ling-3-1-flash-a-ling-3-1-flash-m53-tests-verdes-2-bugs-corregidos.md` (reporte al director)

## Evidencia

- `test_m53_wcag.gd`: **17 checks, 0 fallos, EXIT 0**
- `test_m53_extremos.gd`: **8 checks, 0 fallos, EXIT 0**
- `test_m53_capas.gd`: **14 checks, 0 fallos, EXIT 0** (sin regresión)
- `test_m53_lista_larga.gd`: **7 checks, 0 fallos, EXIT 0** (antes: 1 fallo — "wrap-around circular: tras 500 items el foco vuelve al primero (owner=Item_0001)")
- Conteo checklist: regex `^- \[x\]` = 146, `^- \[ \]` = 19, `^- \[\?\]` = 0, total 165 ✓

## Notas

- Los 19 pendientes restantes de M53 son genuinamente de otros dueños o requieren runtime manual/visión (C.12, E.5, F.6, F.8, F.9, H.7, H.8, H.10, I.9, I.10, J.6, J.7, K.3, K.4, L.5, L.6, L.11, M.1, M.8).
- Hallazgo para decisión del director: H.L121 "[x] Toasts con icono y SFX por tipo" — NotificationService es visual-only; si los emisores no reproducen el SFX, H.L121 sería falso verde (reportado en msg 58).
- El director aceptó M99 bloque 3 en msg 57 (130/169); pendiente su respuesta sobre el siguiente encargo (propuesta: M99 bloque 4 o QA cruzada §21.8).
