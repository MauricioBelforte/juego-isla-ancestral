# Log 533: M118 CI-CD — Auditoría de workflows + fix godot_version (4.3 → 4.7.2)

**Fecha:** 2026-09-02
**Hora:** 17:40
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Auditoría del CI/CD (M118): se revisaron los 4 workflows del repo y se detectó un bug real: `testing.yml` usaba `godot_version: 4.3` mientras el proyecto es 4.7.2 — el CI de tests estaba roto de facto. Corregido a 4.7.2.

## Auditoría (resultados)

- **testing.yml**: GdUnit4 vía `firebelley/godot-export@v5.2.1`, `godot_version: 4.3` → **FIX: 4.7.2**.
- **quality.yml**: GDScript Linter headless (coherente con la suite de calidad del proyecto).
- **backup.yml**: backup externo (Google Drive) — automatización de backups M107.
- **bug_metrics.yml**: dashboard de métricas de bugs (M102) por Python.

## Archivos Modificados/Creados

- Modificados: `.github/workflows/testing.yml` (godot_version 4.7.2), `DOCUMENTACION/118-CI-CD/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md` (fila 118 → 🟡 12/100), `Logs/ULTIMO_NUMERO.txt` (→533)
