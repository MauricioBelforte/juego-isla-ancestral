**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 01: Visión y Concepto

## ID del Módulo
- **Código:** M01 (plan maestro: sección 1 del `Plan-inicial-minimo.md`)
- **Carpeta del componente:** `DOCUMENTACION/02-Vision-Y-Concepto/`
- **Dependencias:** Componente 01 (`01-Fundamentos-Del-Proyecto`)
- **Módulos que dependen de este:** M02 (Documentación del Proyecto), M03 (Game Engine), M05 (Estilo de Arte Visual), M07 (Audio), M14 (UI/UX)

---

## 1. Problema

El juego existe como idea, narrativa (biblia) y GDD maestro, pero carece de una **identidad consolidada y verificable**: nombre definitivo, pitch, propuesta de valor, pilares y alcance explícito. Sin esta capa conceptual cerrada, todos los módulos posteriores (arte, audio, programación, marketing) trabajan contra supuestos no validados y el riesgo de *scope creep* es máximo.

## 2. Objetivos del Módulo

1. Definir y fijar por escrito la identidad completa del juego (nombre, géneros, público, plataformas, cámara, estilo, tono).
2. Consolidar la filosofía del proyecto (cero violencia) y traducirla a pilares accionables.
3. Crear los materiales de comunicación: elevator pitch, descripción de una frase y descripción de una página.
4. Definir el alcance de la **v1.0** (qué entra) y el **fuera de alcance inicial** (qué queda como roadmap).
5. Definir principios de accesibilidad y rendimiento del juego.
6. Resolver los 26 puntos de la sección 1 del plan maestro (trazabilidad 1:1).

## 3. Alcance del Módulo

**Incluye:**
- Consolidación y redacción de identidad, pitch, descripciones, pilares, propuesta de valor, alcance y principios.
- Documentación de este módulo (5 archivos principales, checklist de 100+ ítems).
- Trazabilidad con los documentos de origen (`IDEA-BASE-DEL-JUEGO.md`, `HISTORIA-DEL-JUEGO.md`, `Plan-de-produccion.md`, `Plan-inicial-minimo.md`, investigación de juegos).

**No incluye (pertenecen a otros módulos):**
- Elección de motor (M03), documento de arte (M05), documento de audio (M07), documento de narrativa detallada (M02), documento de UI/UX (M14), plan de monetización (M-profesión monetización), documento legal completo (M02/legal).
- Código: este módulo es 100% documental; no generará scripts.

## 4. Restricciones

| Restricción | Detalle |
|---|---|
| Filosofía | Ausencia total de combate, muerte y penalizaciones violentas (GDD §1, directiva 2) |
| Idioma | Todos los entregables en español |
| Fuentes | Ninguna decisión puede contradecir GDD, biblia narrativa ni plan de producción |
| Alcance | La v1.0 se rige por la Sección 1 del `Plan-de-produccion.md` (Aurora completa + 1-2 islas + 2-3 sellos + cierre parcial) |
| Tono | Cálido, misterioso, contemplativo, esperanzador (Biblia narrativa §Concepto) |
| Rendimiento | Objetivo 60 FPS con voxel optimizado (GDD §5, directiva 1) |

## 5. Entregables del Módulo

| # | Entregable | Estado |
|---|---|---|
| 1 | Nombre definitivo y título provisional verificados | Resuelto en docs; **verificación de disponibilidad pendiente** |
| 2 | Definición de género principal y secundarios | ✅ Resuelto (GDD §1) |
| 3 | Público objetivo y edad recomendada | ✅ Resuelto (este componente) |
| 4 | Plataformas objetivo y cámara | ✅ Resuelto (GDD §1) |
| 5 | Estilo visual, tono y filosofía | ✅ Resuelto (GDD §1, Biblia §1) |
| 6 | Características diferenciadoras y propuesta de valor | ✅ Resuelto (este componente) |
| 7 | Elevator pitch + descripción de frase + descripción de página | ✅ Resuelto (este componente) |
| 8 | Pilares de diseño, narrativa, visual y sonoro | ✅ Resuelto (este componente) |
| 9 | Principios de accesibilidad y rendimiento | ✅ Resuelto (este componente + GDD §5) |
| 10 | Alcance v1.0 y fuera de alcance inicial | ✅ Resuelto (Plan-de-producción §1) |
| 11 | 5 archivos de documentación del componente con checklist 100+ ítems | ✅ Entregado |

## 6. Criterios de Aceptación

1. Los 26 puntos de la sección 1 del `Plan-inicial-minimo.md` quedan resueltos o con dueño/pendiente explícito (trazabilidad).
2. El checklist del módulo contiene **mínimo 100 ítems** verificables con estado honesto (`[ ]`/`[x]`/`[?]`).
3. Ninguna definición contradice GDD, biblia o plan de producción.
4. El alcance v1.0 está por escrito y es revisitable (anti-scope-creep).
5. `CHECKLIST-GLOBAL.md` refleja el estado del módulo.
6. Log de finalización en `Logs/`.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M001** — Fundamentos del Proyecto | Visión del proyecto y filosofía |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M001** — Fundamentos del Proyecto | Depende de este módulo |

