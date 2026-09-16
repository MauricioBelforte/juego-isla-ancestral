**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code

**Módulo:** 96-Plataformas (96)

# Checklist personal tareas — 96-Plataformas

> Fuente: 36 `[ ]` del `05-Checklist.md` (revertido parcial; "Totales" decía 102/102 = **sobre-cierre**,
> real 69/36/1). **Iter. agnes (Log 924, 2026-09-16):** verifiqué el código real (30/0) + cerré 2 ítems
> concretos. M96 **🟡 Liberado (iter. agnes)**: 71/106.

## Tareas (estado tras iter. agnes)

### Cerrados en iter. agnes (Log 924)
- [x] T-001 Verificar código real: `platform_manager.gd` + bridges + `test_plataformas_m96.gd` **30/0** (0 `SCRIPT ERROR`)
- [x] T-002 **§1.4 "formato único de la matriz"** → creé `plan-actual/MATRIZ-PLATAFORMAS.md` (tabla de 10 plataformas derivada de `plataformas.json`)
- [x] T-003 **§21.2 "cláusula documentada cross-play NO aplica"** (single-player, sin M77 online) → en `MATRIZ-PLATAFORMAS.md`
- [x] T-004 Reconciliar sobre-cierre del `Totales` (102/102 → real 69/36/1 → 71/34/1) + mapear owners

### `[?]` con dueño (NO lo hago: son decisiones de política/presupuesto)
- [?] T-005 GATE de consolas P2 (PS/Xbox/Switch) + MS Store P3 → **dueño fundador/M142** (presupuesto/NDA)
- [?] T-006 Costes devkits/testing/total → **M149**
- [?] T-007 Prioridades/recursos/ventanas + revisión trimestral → **M144**
- [?] T-008 Requisitos de rendimiento probados → **M61**
- [?] T-009 Mapeo logros offline/catch-up → **M59** · Portabilidad save v3.x → **M60** · UI/remapeo gamepad → **M57/M58**
- [?] T-010 Feed a M149/M142/M143 → **M149/M142/M143**

## Verificación
- `godot --headless --script res://scripts/plataformas/test_plataformas_m96.gd` → 30/0, 0 `SCRIPT ERROR`
