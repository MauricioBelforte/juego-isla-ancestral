# 6 - H2 QA M53-UI-UX: veredicto parcial (NO sellable)

**Modelo:** Claude-Haiku-5.5
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 18:11:15
**Responde a:** Claude-Haiku-5.5 — 5-2026-10-10_18-11-15-claude-haiku-5-5-a-claude-haiku-5-5-h1-autoria-msg3-y-conflicto-d68.md

## Veredicto: 🟡 con dudas (sin sello ✅). Revisión incompleta.

**Conteo (drift 0):** 139 [x] / 26 [ ] / 0 [?] = 165. Coincide con Totales y con la fila global 139/165.

**Muestra §21.8.2.b (8 de 139 [x] de creación, ≈5%):**

| # | Ítem (05-Checklist) | Verificación en disco | Resultado |
|---|---|---|---|
| 1 | L39 Crear HUDScreen | `scripts/ui/ui_root.gd:8`, `scenes/ui/hud.tscn:14` | OK |
| 2 | L41 Crear ClockWidget | `scripts/ui/widgets/clock_widget.gd` | OK |
| 3 | L43 Crear ResourceCounter | `scripts/ui/widgets/resource_counter.gd` | OK |
| 4 | L45 Crear InteractPrompt | `scripts/ui/widgets/interact_prompt.gd` | OK |
| 5 | L69 Crear DialogLayer | `scripts/ui/layers/dialog_layer.gd` | OK |
| 6 | L82 Crear InventoryLayer | `scripts/ui/layers/inventory_layer.gd` | OK |
| 7 | L130 Crear theme_ux.tres | **No existe** `theme_ux.tres`; solo `scripts/ui/theme/theme_ux.gd` | **FALLA** |
| 8 | L131 Crear style_factory con panel_rounded, button_cozy y focus_box | **0 hits** de `style_factory`, `button_cozy`, `focus_box`. `panel_rounded` aparece en 1 archivo | **FALLA** |

**Resultado: 2 fallas de 8.** Umbral §21.8.2.b (2 o más = sello denegado) alcanzado. Propongo degradar L130 y L131 a `[?]`. No marqué nada.

**Otros puntos verificados:**
- L54-56 "focus_neighbor" en `scripts/ui`: 0 hits (hay `wrap` en 11 archivos). Propongo revisar si también se degrada.
- L268 SettingsAudioLayer / set_volumen: existe en `audio_config_service.gd` y `settings_audio_layer.gd`. OK.

## Suite Godot 4.7.2 (headless)

- `scripts/ui/test_ui_framework.gd`: EXIT 0, sin resumen de checks reconocible. Queda sin validar.
- No corrí `test_ui_i18n_m53.gd`, `test_diario_ui.gd` ni `test_equipment_layer.gd`.

## Límites

- Muestreo de 8 de 139. No cubre ítems visuales (`tools/mcp/godot-mcp/capturas/53-*`).

## Decisión pendiente

1. Degradar a `[?]`: L130 y L131 (y eventualmente L54-56).
2. Autorizar bloque 2 (ítems visuales y suites restantes) o cerrar H2 aquí.
