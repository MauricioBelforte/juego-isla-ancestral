**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 02: Documentación del Proyecto

## ID del Módulo
- **Código:** M02 (plan maestro: sección 2 del `Plan-inicial-minimo.md`)
- **Carpeta del componente:** `DOCUMENTACION/03-Documentacion-Del-Proyecto/`
- **Dependencias:** Componente 01 (Fundamentos) y Componente 02 (Visión y Concepto)
- **Módulos que dependen de este:** todos (es el meta-sistema de documentación; fija convenciones y catálogo que el resto consume)

---

## 1. Problema

El proyecto ya produce documentación (GDD, biblia, planes, componentes), pero el **sistema documental** no está formalizado: no hay catálogo único de documentos con dueño, las convenciones viven dispersas en el AGENTS.md, no hay milestones con horizonte temporal, y la trazabilidad de los 152 módulos depende de convenciones orales. Sin este módulo, el riesgo es **duplicación, desactualización y pérdida de contexto** a medida que crecen los componentes.

## 2. Objetivos del Módulo

1. Formalizar el **catálogo de documentos del proyecto** (los 25 puntos del plan maestro) con estado y módulo dueño.
2. Fijar por escrito las **convenciones de nombres**, estructura de carpetas y estándar de documentación vigentes.
3. Definir el **control de versiones** de documentos (git) y el **sistema de tareas/prioridades** (protocolo).
4. Definir **milestones** y **roadmap** con horizonte temporal razonable para el alcance v1.0.
5. Formalizar el **backlog inicial** (= los 152 módulos del plan maestro).
6. Crear los **5 documentos generales** de la raíz de `DOCUMENTACION/` (`1-` a `5-*-ACTUAL.md`) como esqueletos vigentes que los módulos futuros completan.

## 3. Alcance del Módulo

**Incluye:**
- Catalogar y fijar dueños (no escribir el contenido de todos): GDD, narrativa, mundo, personajes, misiones, sistemas, técnico, arte, audio, UI/UX, economía, progresión, monetización, legal, QA, publicación.
- Convenciones de nombres, estructura de carpetas, estándar de documentación, control de versiones, sistema de tareas, prioridades, milestones, roadmap, backlog inicial.
- Creación de los 5 `*-ACTUAL.md` generales (estructura + estado; el contenido substantivo lo aporta cada módulo dueño).

**No incluye (contenido que vive en otros módulos):**
- El contenido de cada documento especializado (ej: documento de arte → módulo Estilo de Arte; documento técnico → Arquitectura/Engine; documento de economía → Economía).
- La verificación legal del nombre del juego (la registra como pendiente de Legal M78).

## 4. Restricciones

| Restricción | Detalle |
|---|---|
| Idioma | Español obligatorio en toda documentación |
| Fuentes | `AGENTS.md` es el reglamento; los 152 módulos son el backlog |
| Inmutabilidad | `plan-inicial/` y `DOCUMENTACION/00-PLAN-INICIAL/` NO se modifican |
| Formato | 5 archivos obligatorios por componente; checklist ≥100 ítems; firmas de modelo/plataforma |
| Trazabilidad | Cada documento del catálogo tiene UN módulo dueño |

## 5. Entregables del Módulo

| # | Entregable | Estado |
|---|---|---|
| 1 | Catálogo de 25 documentos con estado y dueño | ✅ (03-Diseno.md §2) |
| 2 | Convenciones de nombres documentadas | ✅ (03-Diseno.md §3) |
| 3 | Estructura de carpetas formalizada | ✅ (03-Diseno.md §4) |
| 4 | Estándar de documentación consolidado | ✅ (03-Diseno.md §5) |
| 5 | Control de versiones de documentos (git) | ✅ (03-Diseno.md §6) |
| 6 | Sistema de tareas y prioridades | ✅ (03-Diseno.md §7) |
| 7 | Milestones y roadmap | ✅ (03-Diseno.md §8) |
| 8 | Backlog inicial (152 módulos) | ✅ (= Plan-inicial-minimo.md) |
| 9 | 5 documentos generales `*-ACTUAL.md` (esqueletos) | ✅ creados en raíz de DOCUMENTACION |
| 10 | 5 archivos del componente + checklist ≥100 ítems | ✅ |

## 6. Criterios de Aceptación

1. Los 25 puntos del plan maestro (sección 2) resueltos o con dueño explícito.
2. Checklist del módulo con mínimo 100 ítems verificables y estados honestos.
3. Ninguna convención nueva contradice `AGENTS.md`.
4. Los 5 `*-ACTUAL.md` existen en la raíz de `DOCUMENTACION/` con estructura y estado.
5. `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/README.md` y Logs actualizados.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M001** — Fundamentos del Proyecto | Convenciones de documentación |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M001** — Fundamentos del Proyecto | Depende de este módulo |

