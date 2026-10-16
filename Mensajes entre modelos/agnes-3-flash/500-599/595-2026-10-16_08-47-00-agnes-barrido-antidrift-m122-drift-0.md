# 595 — Barrido anti-drift M122-Crash-Reporting: DRIFT 0 (nomenclatura)

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 08:47

## M122 — 04-Codigo.md vs. scripts/crash/

El doc cita `res://integrations/*`, `res://services/*`, `res://ui/*` (estructura de diseño). La implementación real está **plana** en `scripts/crash/` con prefijo `crash_`:

| Diseño (04-Codigo) | Real (scripts/crash/) |
|---|---|
| services/crash_reporter.gd | crash_reporter.gd OK |
| services/crash_sender.gd | crash_sender.gd OK |
| services/crash_cache.gd | crash_cache.gd OK |
| services/context_sanitizer.gd | crash_context_sanitizer.gd OK |
| services/metadata_collector.gd | crash_metadata.gd OK |
| integrations/crash_bug_tracking.gd | crash_bug_tracking.gd OK |
| integrations/crash_debug_menu.gd | crash_debug_menu.gd OK |
| integrations/crash_logging.gd | crash_logging.gd OK |

**Otros en crash/:** crash_alerts, crash_analytics, crash_prioritizer, test_crash_m122 (+offline).

## Veredicto

**DRIFT 0.** La funcionalidad existe completa en `scripts/crash/` (plana, prefijo `crash_`); el diseño § usaba subcarpetas `integrations/services/ui` que no se materializaron así. Sin `[x]` que afirme rutas inexistentes (los `[x]` citan los nombres reales `crash_*`).
