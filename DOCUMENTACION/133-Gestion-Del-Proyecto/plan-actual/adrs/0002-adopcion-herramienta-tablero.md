# ADR-0002: Adopción de GitHub Projects v2 como tablero de gestión
**Fecha:** 2026-08-28 · **Estado:** Propuesto (pendiente de confirmación explícita del fundador)

**Modelo:** GLM
**Plataforma:** Kilo

## Contexto

La gestión del proyecto necesita un tablero visual para el trabajo diario. El análisis del módulo 133 (`plan-actual/02-Analisis.md` §1.4, decisión D2) evaluó herramientas gratuitas y concluyó que **GitHub Projects (Projects v2)** es la opción más adecuada porque vive junto al repositorio, sincroniza con issues/ramas y mantiene el estado real en `CHECKLIST-GLOBAL.md` (el tablero es espejo, no fuente de verdad). La documentación original dejó pendiente la **confirmación humana** de la herramienta.

## Decisión

Adoptar **GitHub Projects v2** como tablero principal (vista Kanban por estados + vista Roadmap por hitos M0-M5), con `CHECKLIST-GLOBAL.md` como única fuente de verdad y **Markdown local como contingencia offline** permanente. Mientras el fundador no confirme, la gestión funciona igualmente sin tablero (todo el estado es repositorio).

## Opciones descartadas

- **Trello (plan gratis)** → fuera del repo; sincronización manual doble; riesgo de desincronización.
- **Notion (plan gratis)** → pesado de mantener; fuera del repo; riesgo de quedar obsoleto (RN3/RN10).
- **Tablero físico / solo Markdown** → accesible y versionado, pero sin vistas visuales cómodas para el flujo diario; se conserva como modo offline, no como principal.
- **Obsidian + Git** → wiki local excelente, pero orientado a un solo usuario y con curva adicional para agentes.

## Consecuencias

- Positivas: tablero integrado con issues/PRs; cero costo; sincronización unidireccional simple (repo → tablero); la gestión no depende de él para funcionar.
- Negativas: requiere internet para el tablero (mitigado con contingencia offline); mantenimiento manual de la sincronización al reservar/liberar módulos.
- El primer tablero se crea con un issue por módulo cuando el fundador confirme la decisión (entonces este ADR pasa a `Aceptado` por acta o edición firmada).

**Firma:** GLM / Kilo
