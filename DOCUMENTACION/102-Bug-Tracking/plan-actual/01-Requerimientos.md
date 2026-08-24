**Modelo:** SWE-1.6
**Plataforma:** Devin

# 01-Requerimientos.md — Módulo 102: Bug Tracking

## ID del Módulo
- **Código:** M102 (plan maestro: sección 101 — Bug Tracking)
- **Carpeta:** `DOCUMENTACION/102-Bug-Tracking/`
- **Dependencias:** M101 (QA General). Dependen de este: M110 (Debug Menu), M112 (Testing Automático)
- **Carácter:** Módulo de infraestructura de desarrollo (sin impacto en gameplay)

## 1. Problema

El proyecto necesita un **sistema organizado de seguimiento de bugs** para registrar, priorizar, asignar y verificar correcciones de errores de forma sistemática durante todo el ciclo de desarrollo (prototipo → release).

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Herramienta de bugs | Sistema para registrar y gestionar incidencias |
| RF2 | Categorías | Clasificación por tipo (gameplay, UI, audio, render, etc.) |
| RF3 | Severidades | Niveles de impacto (crítico, mayor, menor, trivial) |
| RF4 | Prioridades | Orden de atención (inmediata, alta, media, baja) |
| RF5 | Reproducibilidad | Estado de facilidad de reproducción (siempre, a veces, nunca) |
| RF6 | Pasos para reproducir | Plantilla estandarizada de reporte |
| RF7 | Metadata técnica | Versión, plataforma, build |
| RF8 | Evidencia | Adjuntar logs, capturas, videos |
| RF9 | Contexto específico | Seed de generación, save afectado |
| RF10 | Asignación | Responsable de la corrección |
| RF11 | Estados del bug | Flujo de trabajo (nuevo → en progreso → verificado → cerrado) |
| RF12 | Verificación | Confirmación de corrección con regresión |
| RF13 | Historial | Registro de cambios y comentarios |
| RF14 | Integración con QA | Flujo desde detección hasta cierre |

## 3. Requisitos No Funcionales

- Uso de GitHub Issues (ya disponible por el proyecto, costo $0).
- Plantilla de issue estandarizada con campos obligatorios.
- Flujo de trabajo compatible con metodología ágil/sprints.
- Baja curva de aprendizaje para desarrolladores y testers.
- Sin dependencia de herramientas externas de pago.

## 4. Criterios de Aceptación

1. Los 21 puntos de la sección 101 del plan maestro resueltos.
2. Plantilla de issue definida en `.github/ISSUE_TEMPLATE/bug_report.md`.
3. Flujo de estados y etiquetas documentado.
4. Integración con M101 (QA General) y M110 (Debug Menu) especificada.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M101** — QA General | Base para qa general |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M101** — QA General | Depende de este módulo |

