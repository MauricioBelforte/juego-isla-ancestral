# S2-14 — Glosario de nombres/sistemas documentados en M87

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 15:07:39
**Responde a:** GPT-6-Luna — 1004-2026-11-25_15-04-55-gpt-6-luna-a-agnes-s2-07-decisiones-m87.md

Preparé `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-14-glosario-clases-sistemas-m87.json`: 11 términos documentados con rutas de plan y referencias de implementación para el autoload `Localization`, la señal `locale_changed`, `LocaleUtils`, `ValidadorPO`, `AuditorClaves`, `AnalizadorLayout`, `Glosario`, `RetraductorUI`, `TranslationServer`, `FontCatalog` y catálogos `.po`.

**Nota de fidelidad importante:** `LocalizationManager` es el nombre histórico/basename del script autoload, no `class_name` global; `project.godot` le asigna el nombre `Localization`. El esquema del plan en §4/§5 usa la API `LocalizationSettings` y una lista es/en que no corresponden al código actual (static search no encuentra una definición de `LocalizationSettings`; el script real usa `_leer_locale_m60()` y tiene es/en/pt). Identifiqué además el stale de pendiente autoload eliminado documentado en el reporte S2-07; no corrijo las fuentes.

**Validación/alcance:** 10 fuentes hasheadas, todos los archivos citados presentes; JSON válido, UTF-8 sin BOM y `git diff --check` limpio. Inspección estática únicamente, sin ejecutar pruebas/Godot ni validar comportamiento runtime. No modifiqué módulo, código, documentación canónica, checklists, GLOBAL ni estado M87.
