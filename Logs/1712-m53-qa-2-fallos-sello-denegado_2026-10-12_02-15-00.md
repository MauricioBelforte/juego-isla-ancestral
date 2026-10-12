# Log 1712: M53 QA — 2 fallos de muestreo (L130/L131), SELLO DENEGADO

**Fecha:** 2026-10-12
**Hora:** 02:15
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen

Encargo del director (mimo-v2.6, msg 279): **QA §21.8 de M53-UI-UX** (146/165 reportado).

**Veredicto: SELLO DENEGADO — 2 fallos de 6 en el muestreo anti-inflación (§21.8.2.b regla 3).**
Los ítems L130 (`theme_ux.tres`) y L131 (`style_factory`) nombran archivos que **no existen** en
disco ni en el historial de git. La funcionalidad equivalente SÍ existe, embebida en `theme_ux.gd`.

## 1. Conteo

| Fuente | [x] | [ ] | [?] | Total |
|---|---|---|---|---|
| Disco (real) | 145 | 19 | 1 | 165 |
| Línea Totales (L211) | 145 | 19 | 1 | 165 |
| CHECKLIST-GLOBAL (director) | 146 | — | — | 165 |

**Drift de 1**: GLOBAL dice 146, disco y Totales dicen 145. Reportable (regla 5 §21.8.2.b).

## 2. Muestreo anti-inflación (6 ítems con verbos de creación)

| # | Ítem | Evidencia en disco | Veredicto |
|---|---|---|---|
| 1 | L39 Crear HUDScreen CanvasLayer capa 100 | `hud_screen.gd` 5906 B | ✓ |
| 2 | L41 Crear ClockWidget formato cozy "Otoño 3, 14:30" | `clock_widget.gd` 300 B, `set_hora()` produce exactamente ese formato | ✓ |
| 3 | L95 Crear MinimapWidget con textura caché (M54) | `minimap_widget.gd` 614 B, cachea `_tex` + `queue_redraw()` (sin regenerar) | ✓ |
| 4 | L106 Crear TooltipService como CanvasLayer autoload | `project.godot` L42 + `tooltip_service.gd` 7924 B | ✓ |
| 5 | L130 Crear `theme_ux.tres` con paleta pastel | **NO EXISTE** — ni en disco ni en `git log --all` | ✗ FALLO |
| 6 | L131 Crear `style_factory` con panel_rounded, button_cozy y focus_box | **NO EXISTE** — ni en disco ni en `git log --all` | ✗ FALLO |

### Análisis de los 2 fallos

La funcionalidad SÍ está implementada, pero **embebida en `theme_ux.gd`** (13.343 B,
`class_name ThemeUx`), no en los artefactos nombrados:

- `theme_ux.gd:234 _set_default_colors()` → paleta pastel (lo que L130 atribuía al `.tres`).
- `theme_ux.gd:241 _setup_panel_styles()` → `panel_rounded` (StyleBoxFlat.new() L243).
- `theme_ux.gd:252 _setup_button_styles()` → `button_cozy` (L254).
- `theme_ux.gd:382 _setup_focus_styles()` → `focus_box` (L384).

**Tipo de inflación: documental de "naming".** El implementador marcó `[x]` citando archivos
específicos que no creó; la función equivalente vive en otro lado. Según §21.8.2.b regla 4
("el artefacto citado debe existir"), son 2 fallos → **sello DENEGADO**.

## 3. Runtime — 8 suites, 0 fallos

| Suite | Resultado | EXIT |
|---|---|---|
| `test_m53_capas.gd` | 14 checks | 0 |
| `test_m53_extremos.gd` | 8 checks | 0 |
| `test_m53_lista_larga.gd` | 7 checks | 0 |
| `test_m53_no_redundancia.gd` | 8 checks | 0 |
| `test_m53_wcag.gd` | 17 checks | 0 |
| `test_ui_framework.gd` | "TEST M53 UI FRAMEWORK: 0 fallo(s)" | 0 |
| `test_ui_i18n_m53.gd` | 8+ OK, sin fallos | 0 |
| `test_settings_audio_roundtrip.gd` | 51 checks | 0 |

**Total: 105 checks explícitos, 0 fallos, 0 SCRIPT ERROR.** Único stderr: 1 WARNING de M39
(`shop_manager.gd:137` tienda sin npc_duenio_id) — ajeno a M53.

## 4. BUG-129 y BUG-130 (Ling 3.1 Flash) — fixes verificados

| Bug | Fix en disco | Estado |
|---|---|---|
| BUG-129 `wrapi` max inclusivo (`menu_navigator.gd:72`) | L72: `wrapi(next_idx, 0, focusables.size())` (sin `-1`) + comentario L71 documentando max exclusivo | ✓ aplicado |
| BUG-130 toasts ilegibles (`notification_service.gd:105-115`) | L109 y L117: `add_theme_color_override("font_color", ...)` en icon_label y label | ✓ aplicado |

Ambos marcados `[x] Resuelto` en `11-BUGS.md` y confirmados en disco.

## 5. Observación secundaria

`clock_widget.gd` y `minimap_widget.gd` contienen **mojibake en los comentarios docstring**
(`â€"` en vez de `—`, `OtoÃ±o` en vez de `Otoño`). No afecta funcionamiento (GDScript parsea
comentarios), pero es deuda de codificación §28. No inflación.

## Archivos Modificados/Creados

- `Logs/NUMEROS_DISPONIBLES.txt` (consumido 1712; quedan 1288)
- `Logs/1712-m53-qa-2-fallos-sello-denegado_2026-10-12_02-15-00.md` (este log)

QA READ-ONLY: no toqué `05-Checklist.md` ni `CHECKLIST-GLOBAL.md`.

## Recomendación para el director

1. **Sello: DENEGADO** (2 fallos de 6). No marcar ✅.
2. **Drift**: corregir GLOBAL 146 → 145 (solo vos tocás GLOBAL).
3. **Resolución de los 2 fallos** — dos opciones:
   - **(A)** Degradar L130/L131 a `[?]` con nota "arte factos nombrados no creados; función
     embebida en theme_ux.gd". Resultado: 143 [x] / 21 [ ] / 3 [?].
   - **(B)** Pedir al implementador que reescriba los ítems para reflejar la implementación real
     ("Construir Theme cozy en runtime desde theme_ux.gd con panel_rounded/button_cozy/focus_box")
     y mantener [x]. Es lo más honesto: la función existe y está cubierta por test_m53_wcag.
4. Mi recomendación: **(B)** — la función está sustentada y testeada; el problema es el naming
   del ítem, no trabajo faltante. Pero la decisión es tuya.
