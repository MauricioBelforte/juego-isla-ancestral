# 06-Plan-Testings.md — Módulo 89: Diseño de Menús

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-05

> Plan de testings del frente **T-M2** (auditoría + suite headless), método heredado de T-M1/M55.
> Los ítems de testing son opcionales por sección 3 de AGENTS.md; M89 es gameplay-core de UI → se crean `06`/`07`.

## 1. Objetivo

Verificar **automáticamente y en headless** el estado real de las pantallas del shell de menús (M89) contra el diseño heredado, sin ejecutar el editor ni el modo juego, y dejar evidencia honesta (verde + sonda rojo) de que la suite detecta fallos.

## 2. Alcance (grupos A-H)

| Grupo | Qué valida | Archivos |
|-------|-----------|----------|
| A | MenusLayer: carga, extiende UILayer, 5 señales, MODAL_FULL, arranca oculto, 5 botones con texto, focus_first | `ui/layers/menus_layer.gd` |
| B | PauseLayer: 4 señales/opciones, MODAL_FULL, open/close | `ui/layers/pause_layer.gd` |
| C | MenuNavigator: carga, focus_first → Button, foco real, focus_last distinto, wrap_focus mueve el foco | `ui/core/menu_navigator.gd` |
| D | CreditsLayer: constantes M131 (MAX 300 s, 3 velocidades), open/cerrar, ≥6 controles | `ui/layers/credits_layer.gd` |
| E | UIRoot: monta capas (menú/pausa/créditos/ajustes), wiring `_conectar_menu_señales`/`_conectar_ajustes`, `jugar_pedido` y `ajustes_pedido` conectadas a GameFlowManager/SettingsAudioLayer | `ui/ui_root.gd` |
| F | Pausa del mundo: MODAL_FULL pausa el árbol y lo reanuda (sin saltos) | `ui/core/ui_manager.gd` (lectura) |
| G | SaveManager: API de slots (slot_metadata/load_slot/slot_recoverable) + `SaveWriter.save_exists` | `saving/save_manager.gd`, `save_writer.gd` |
| H | Gaps de auditoría como `GAP-AUDITORIA` (INFO, no fallos) | — |

## 3. Sonda rojo (honestidad)

1. Ejecutar la suite tal cual → debe dar **verde** (`exit=0`).
2. Cambiar temporalmente `ESPERA_BOTONES_MENUS := 5` → `6` (RF1 pide 6 botones) → ejecutar → debe dar **rojo**: `FALLO: A5` + `exit=1`.
3. Restaurar la constante a `5` (vía Python, UTF-8 sin BOM) → reejecutar → verde.
4. Registrar ambos runs en `07-Resultados-Testings.md`.

## 4. Regresión obligatoria

- `test_ui_framework.gd` (M53, zona s2 — solo ejecutar) → 0 fallos, `exit=0`.
- `test_diario_ui.gd` (M55, mío) → 89 checks, 0 fallos, `exit=0`.

## 5. Criterios de éxito

- [ ] `test_m89_menus.gd`: 0 fallos, `exit=0`.
- [ ] Sonda rojo demuestra detección real: ≥1 fallo, `exit=1`.
- [ ] Regresión M53/M55 sin fallos.
- [ ] Sin BOM/UTF-8 corrupto en el archivo de test (verificación byte a byte).
- [ ] `ui_manager.gd` (s2) intacto: sin cambios en el diff.
- [ ] Evidencia completa en `07-Resultados-Testings.md`.

## 6. Fuera de alcance (T-M2)

- Ejecutar el editor / capturas (sin V4 en esta sesión; módulo sin dependencia visual activa).
- Probar en runtime con gamepad o ratón real (playtest humano, ítem §23 pendiente).
- Tocar `full_map_layer.gd` (DeepSeek), `interaction_manager`, `service_registry`, `quality.yml`.

## 7. Comando de ejecución

```text
& "C:\Temp\godot\godot472.exe" --headless --path game/isla-ancestral --script res://scripts/ui/test_m89_menus.gd
```
(exit code 0 = verde, 1 = fallos)
