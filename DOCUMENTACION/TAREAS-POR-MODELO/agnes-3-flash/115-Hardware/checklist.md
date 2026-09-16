**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code

**Módulo:** 115-Hardware (115)

# Checklist personal tareas — 115-Hardware

> Fuente: 132 subítems del `05-Checklist.md` (revertidos a `[ ]` por la auditoría del 2026-09-14).
> **Iter. agnes (Log 921, 2026-09-15):** verifiqué contra el código real y **corregí 2 falsos-verdes**.
> M115 **🟡 Liberado (iter. agnes)**: 51 checks / 0 fallos / 0 `SCRIPT ERROR`.
> El flip caja-a-caja de los 132 ítems y la wiring de detección (M90) quedan con dueño.

## Tareas (estado tras iter. agnes)

### Evidencia previa — COMPLETADO
- [x] T-001 Verificar existencia de los scripts de M115 + autoload — existen `hardware_manager` (catálogo), `hardware_profile`, `hardware_detector` + 3 tests; autoload **duplicado** (`hardware` + `HardwareManager`) — finding
- [x] T-002 Ejecutar tests headless → **hallazgo: 2 falsos-verdes** (`test_hardware` 7 `SCRIPT ERROR`, `test_iter2` 5; salían 0). `test_hardware_m115` verde real 17/0
- [x] T-012 **Fix:** retarget de `test_hardware.gd` + `test_hardware_iter2.gd` a la API real (profile standalone + manager de catálogo) con guardián; detección/preset DEFERRED a M90 → **51 checks / 0 fallos / 0 `SCRIPT ERROR`**

### Reconciliación por sección — Mapeo [x]/[?] (flip caja-a-caja delegado al dueño)
- [x] T-004 §B (HardwareProfile) → **`[x]` respaldado** (test retarget 21/0)
- [x] T-005 §C/§D-calidad (scoring/preset por perfil en el catálogo) → render/AA por perfil verificado
- [x] T-007 §E (autoload HardwareManager) → `[x]` (catalog manager works; `set_perfil_actual` etc.)
- [x] T-009 §G (tests) → `[x]` (51/0, 0 `SCRIPT ERROR` tras retarget)
- [?] T-003 §A → lo documentado `[x]`; el marketing/recomendados → `[?]` dueño M97
- [?] T-006 §D → aplicación de calidad al **viewport** → `[?]` dueño **M90**
- [?] T-008 §F → mapeo específico/remapeo → `[?]` dueño **M57**
- [?] T-010 §H → integración M90/M72/M95/M97 → `[?]` dueño M90/M72/M95
- [?] T-011 §I → docs Steam/FAQ/soporte → `[?]` dueño M97
- [?] T-014 wiring detección al autoload (`set_preset`/`preset_changed`/`apply_deadzone`/`_detector`) → `[?]` dueño **M90**
- [?] T-015 autoload duplicado → bug infra, `[?]` dueño M90/infra (documentado, no corregido)

### Cierre — COMPLETADO
- [x] T-013 Corregir `05-Checklist` (puntero verificación + Notas) + `CHECKLIST-GLOBAL` fila 115 + Log 921 + desbloquear

## Verificación
- 3 tests M115 → 51 checks, 0 fallos, 0 `SCRIPT ERROR` (godot 4.7.2 headless)
