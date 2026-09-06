**Modelo:** glm-5.3-flash (último modificador; consolidación de iter. 1-6 multiagente)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-04

# 02-Analisis.md — Módulo 71: Progresión (plan-actual, decisiones D1-D10)

> ⚠️ Documenta las decisiones de análisis REALES adoptadas por el código vigente
> (scripts/progresion/), consolidando 6 iteraciones multiagente. Los ítems del
> checklist referencian estos IDs.

## D1 — Descartar XP numérica y niveles de jugador
**Decisión:** sin XP ni nivel numérico global — la progresión es por hitos con condiciones data-driven.
**Justificación:** presión numérica anti-cozy (M152); el jugador no ve "Lv. 7" sino "Coleccionista Novato".

## D2 — Descartar árbol de habilidades
**Decisión:** sin árbol de habilidades — los desbloqueos se activan por condiciones, no por puntos a distribuir.
**Justificación:** complejidad de balance y optimización ansiosa sin aporte al gameplay cozy.

## D3 — Descartar progresión lineal estricta
**Decisión:** los hitos NO requieren un orden — hito_previo existe como condición opcional pero la mayoría son independientes.
**Justificación:** M22/M23 son no lineales; el gating duro contradice el diseño cozy.

## D4 — Descartar gating duro por reputación o monedas
**Decisión:** la reputación (PlayerProfile.reputacion()) es SOLO métrica consultable — nunca bloquea progreso ni tiendas. La riqueza nunca es requisito del progreso principal (regla de oro).
**Justificación:** anti-cozy M152/M94; los sellos de M22 son el único gating narrativo.

## D5 — Adoptar registry central + eventos (M07)
**Decisión:** un solo ProgressionManager autoload con catálogo JSON y evaluación event-driven (dirty flags O(1) por stat). Sin registro por módulo.
**Justificación:** hitos transversales (items+amistad+viajes en una condición compuesta) sin duplicar evaluadores; los módulos dueños alimentan eventos, M71 solo refleja.

## D6 — Adoptar JSON data-driven (no .tres)
**Decisión:** hitos.json con schema v1 en vez de MilestoneDefinition .tres.
**Justificación:** headless-friendly (CI puede validarlo sin editor), curaduría más simple, sin ClassNames extra. Migración a .tres si el volumen lo exige.

## D7 — Adoptar evaluación event-driven con dirty flags + caché
**Decisión:** re-evaluación SOLO en eventos (nunca por frame) con indexación condición→hito O(1) por stat + caché de resultados (máx 64) + predicado puro para tests.
**Justificación:** RN de rendimiento (5000 reevaluaciones sin picos); cero polling.

## D8 — Adoptar RF10 gating suave (no bloqueante)
**Decisión:** condiciones imposibles detectadas (estáticas al boot + dinámicas bajo demanda) y reportadas a M66 con logs accionables — NUNCA bloquean el juego.
**Justificación:** anti-softlock M66; el jugador siempre tiene otra cosa que hacer.

## D9 — Adoptar RF12 títulos cosméticos
**Decisión:** títulos otorgados por recompensas de hitos (tipo "titulo"), idempotentes, sin poder — solo reconocimiento visible en M53.
**Justificación:** M152 (reconocimiento sin poder); retro-compatible con saves v1.

## D10 — Descartar progresión aislada por módulo
**Decisión:** la progresión NO vive en M13/M18/M22 — M71 centraliza el registro de hitos transversales y refleja los módulos dueños (M13 herramientas, M22 sellos) sin duplicar su lógica.
**Justificación:** sin centralización, cada módulo reinventaría hitos y no habría hitos combinados.
