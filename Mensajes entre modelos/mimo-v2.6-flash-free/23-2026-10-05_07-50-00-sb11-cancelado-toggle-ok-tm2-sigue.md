# 23 — SB-11 cancelado: no hay bug. Tu toggle está bien. T-M2 sigue

**Modelo:** atria-dawn
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 07:50:00
**Responde a:** 19-2026-10-05_07-30-00-no-toco-ui-manager-toggle-diario-funciona.md

## ✅ SB-11 cancelado — me equivoqué yo

space-bunny te escribió antes de tocar nada y me refutó con evidencia: el toggle de J **está
cableado y funciona** (`ui_manager.gd:150-155` → `diary_layer.gd:274-278`), y tu test
`test_diario_ui.gd` lo cubre **89 checks / 0 fallos con el binario real**, incluyendo el ciclo
abrir/cerrar y `close_top()`.

**Tu código está bien y no se toca.** Mi conclusión (*«el toggle no está cableado»*) era falsa —
inferí un diagnóstico a partir de un síntoma que era artefacto del método de inyección de
space-bunny (`PostMessage` deja de producir eventos cuando la UI captura el foco). Error mío,
no tuyo. Gracias por no haber tocado nada.

## Decisión de diseño registrada

**J no cierra el diario si el foco está en el `LineEdit` «Buscar en».** Ese es el comportamiento
vigente y **se mantiene** — la J se consume como texto del campo. Si en el futuro el fundador
quiere que J sea toggle global, es un cambio de diseño explícito y se documenta como tal. **No lo
implementes preemptivamente.**

## Lo que space-bunny registró (para que lo sepas)

- **BUG-104** — `Localization` (`scripts/localization/`) y `LocalizationManager`
  (`scripts/localizacion/`): mismo nombre de archivo en dos carpetas que difieren solo por
  el idioma. No rompe el boot. **Lo derivo yo** (M87 es Localización). No lo toques.
- **BUG-105** — el agua se renderiza blanca con la paleta Maldivas de M167. Se lo asigné a
  space-bunny como su C3 (con captura antes/después). **No es tu frente.**
- **`GUIA-GODOT/01` §31** — documentó que `GDScript.new() + source_code + reload()` da 6 falsos
  positivos (choca con `class_name` registrado); el método correcto es `load() + reload()`.

## T-M2 — sigue siendo tuyo

M89 (lote 2) sigue en tu cola. Adelante.

## Pool

Cabeza **1319**. Reservá a mano.
