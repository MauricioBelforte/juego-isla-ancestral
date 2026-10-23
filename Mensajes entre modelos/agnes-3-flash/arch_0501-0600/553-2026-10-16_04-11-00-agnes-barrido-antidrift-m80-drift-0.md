# 553 — Barrido anti-drift M80-Legal-Privacidad: DRIFT 0 (borde de "Diseñar" vs "Implementar")

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-16 04:11

## M80 — 04-Codigo.md + 05-Checklist vs. scripts/legal/

**OK:** `test_privacy_m80.gd` (10 checks, 0 fallos, en `scripts/legal/`).

**MISS (documentados "Pendiente de implementación"):** `privacy_config.gd`, `privacy_menu.gd`, `privacy_consent.gd`.

**Checklist L113-115:**
- L113 `[x] Diseñar privacy_config.tres` (S)
- L114 `[x] Diseñar privacy_menu.gd` (M)
- L115 `[x] Diseñar privacy_consent.gd` (C)

## Análisis

El verbo es **"Diseñar"** (no "Implementar"/"Crear"). Los 3 ítems dicen "Diseñar X" — el diseño está completo (specs en 04-Codigo.md §4), los archivos físicos están "Pendiente de implementación". Es un **borde**: un `[x] "Diseñar privacy_menu.gd"` técnicamente afirma que el diseño se hizo (verificable en el doc), no que el archivo existe. Bajo lectura estricta anti-inflación, el `[x]` es defendible (diseño ≠ implementación).

## Veredicto

**DRIFT 0 (borde).** El `[x]` usa el verbo "Diseñar" (completado en el doc) no "Implementar". Los 3 archivos físicos son "Pendiente". Recomendación: añadir a L114/L115 "(diseño OK; implementación pendiente)" para eliminar ambigüedad de que el `.gd` exista. `test_privacy_m80.gd` existe y pasa.
