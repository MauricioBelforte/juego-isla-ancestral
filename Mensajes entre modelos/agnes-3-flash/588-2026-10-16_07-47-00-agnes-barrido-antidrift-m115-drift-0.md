# 588 — Barrido anti-drift M115-Hardware: DRIFT 0

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 07:47

## M115 — 04-Codigo.md vs. scripts/hardware/

**OK (5):** `hardware_detector.gd`, `hardware_manager.gd`, `hardware_profile.gd`, `test_hardware.gd`, `test_hardware_iter2.gd`, `test_hardware_m115.gd`.

**MISS (2, § "Archivos a Crear" = diseño):** `quality_applier.gd`, `quality_preset_selector.gd` — listados como "a Crear" en el doc.

**Checklist L33 `[x]`** menciona "quality_preset" pero como **campo** de `HardwareProfile` (`*(hardware_profile.gd)*`), no como archivo. Ningún `[x]` afirma que `quality_applier.gd`/`quality_preset_selector.gd` existan.

## Veredicto

**DRIFT 0.** El núcleo M115 (detector + manager + profile + tests) está en disco; los 2 scripts de calidad son "a Crear" (diseño). Sin `[x]` inflado.
