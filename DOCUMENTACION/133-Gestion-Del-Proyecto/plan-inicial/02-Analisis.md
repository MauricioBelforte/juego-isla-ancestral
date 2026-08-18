**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Documentación inicial (plan original)

---

# 02-Analisis.md — Módulo 133: Gestión del Proyecto

## 1. Análisis del Dominio

### 1.1 La realidad del desarrollo indie cozy

El desarrollo de *Isla Ancestral* es un proyecto indie autofinanciado: un fundador (posiblemente solo), presupuesto cero, alcance enorme (GDD con varias islas, templos y sistemas) y un vertical slice (M138) como primer gran hito verificable. En este contexto:

- **El proceso debe ser liviano:** cada hora invertida en gestión es una hora menos de desarrollo. El proceso óptimo es el mínimo necesario para que el trabajo no se desorganice.
- **El mayor riesgo no es técnico:** es el **abandono**. Los proyectos indie de una sola persona mueren por desmotivación, saturación, falta de hitos tangibles y ausencia de comunidad, más que por problemas técnicos.
- **El equipo puede ser híbrido:** humano + agentes de IA multi-modelo. Esto exige reglas claras de coordinación para que los agentes no pisen el trabajo de otros ni inflen el estado real del proyecto.

### 1.2 Metodologías ágiles aplicadas a equipos chicos

| Metodología | Descripción | Ventajas | Desventajas para este proyecto |
|-------------|-------------|----------|-------------------------------|
| **Scrum clásico** | Sprints de 2-4 semanas, roles (PO, Scrum Master, devs), ceremonias completas | Estructura conocida, visibilidad | Demasiada burocracia para 1 persona; roles imposibles de llenar sin ficción |
| **Kanban** | Tablero con columnas y límites de trabajo en progreso (WIP), flujo continuo | Ligero, flexible, visual | No fuerza hitos ni fechas; sin presión de cierre puede estancarse en "casi listo" |
| **Scrumban** | Hibrido: tablero Kanban + planificación e inspección periódica | Equilibrio entre flexibilidad y estructura | Requiere disciplina para mantener las iteraciones |
| **Hitos por vertical slice** | El proyecto se organiza en hitos de producto completos y jugables en vez de sprints de duración fija | Cada hito es demonstrable y motivante; el juego siempre está en un estado "jugable" | La estimación de hitos grandes es difícil; requiere desglose en tareas |
| **Waterfall / plan grande** | Plan maestro completo ejecutado en fases secuenciales | Sensación de control | Frágil ante cambios; años sin juego jugable; máximo riesgo de abandono |

**Conclusión:** la combinación **Kanban liviano + hitos por vertical slice** es la más adecuada. El proyecto ya dispone de un plan maestro (152 módulos) que funciona como backlog; el tablero Kanban ordena el flujo; los hitos (prototipo M137, vertical slice M138, pre-alpha M139...) dan el ritmo y la motivación.

### 1.3 Gestión de agentes multi-modelo (protocolo existente)

El proyecto no parte de cero: `AGENTS.md` (sección 21) ya define un protocolo multiagente robusto:

- **`CHECKLIST-GLOBAL.md`**: tabla resumen con una fila por módulo (ID, estado, progreso, prioridad, complejidad, dependencias, agente actual, última actividad, notas). Es la fuente de verdad.
- **`ESTADO-PARALELO.md`**: coordinación de qué agente trabaja en qué.
- **Simbología de estados**: `⬜` sin iniciar, `🟢` disponible, `🔵` en curso, `🔴` en curso con riesgo, `🟡` con dudas, `✅` completado.
- **Reglas**: un módulo por agente, bloqueo por estado, honestidad (un `[?]` vale más que un `[x]` falso), detección de módulos colgados (24 h), QA cruzado entre modelos distintos.
- **Herramientas de automatización**: `scripts/generar_checklist_global.py`, `scripts/verificar_checklist.py`, `scripts/test_scripts.py`.

El módulo 133 debe **adoptar y operativizar** este protocolo: convertirlo en el corazón del ciclo de trabajo diario, no crear uno paralelo.

### 1.4 Herramientas gratuitas de gestión

| Herramienta | Costo | Fortalezas | Debilidades |
|-------------|-------|-----------|-------------|
| **GitHub Projects** (Projects v2: tablero + vista de roadmap) | Gratis | Integrado con el repo (issues, PRs, ramas), vistas kanban y roadmap, filtros por campo | Requiere internet; funcionalidad avanzada limitada en plan gratuito |
| **GitHub Issues + Milestones** | Gratis | Hitos con fechas, issues vinculadas, integración con commits | Sin tablero visual nativo (se combina con Projects) |
| **Trello** (plan gratis) | Gratis | Tablero visual simple, rápido de usar | Fuera del repo; la sincronización con el estado real es manual; límites en plan gratis |
| **Notion** (plan gratuito) | Gratis | Bases de datos, wiki, tableros | Pesado de mantener; fuera del repo; riesgo de quedar desactualizado |
| **Tablero físico / Markdown en repo** | Gratis | Siempre accesible, versionado, offline | Sin automatización visual; menos cómodo en móvil |
| **Obsidian + Git** | Gratis | Wiki local, grafos, plugins | Curva de aprendizaje; single-user por defecto |

**Decisión:** **GitHub Projects (Projects v2)** como tablero principal, con la documentación de estados viviendo **siempre en el repositorio** (`CHECKLIST-GLOBAL.md` como fuente de verdad). El tablero es un espejo operativo de trabajo diario (columnas = estados); los archivos Markdown versionados son la verdad inmutable y el respaldo. Los scripts de la sección 21.9 reconstruyen la tabla global desde los checklists reales, cerrando el ciclo: tablero → estado documentado → verificación automatizada.

### 1.5 Riesgo de abandono (factor crítico del dominio)

El abandono en proyectos indie solitarios se combate con:

1. **Hitos cortos y tangibles**: un vertical slice jugable en el horizonte cercano motiva más que el GDD completo.
2. **Progreso visible**: la tabla global muestra avance real; completar módulos da satisfacción.
3. **Ritmo sostenible**: sin metas diarias imposibles; gestión anti-burnout (coherente con M152).
4. **Comunidad / testers tempranos**: ver a otros jugar el vertical slice renueva la energía.
5. **Plan de pausa**: ausencias planificadas con documentación que permita retomar sin costo.

---

## 2. Alternativas Evaluadas

### A1. Scrum completo con sprints de 2 semanas
- **Favor**: estructura conocida por la industria.
- **Contra**: roles inventados para 1 persona, ceremonias que consumen tiempo real de desarrollo, fechas que generan culpa cuando el dev es también el PO y el tester.
- **Veredicto**: descartado como marco principal.

### A2. Kanban puro sin hitos
- **Favor**: máximo de flexibilidad.
- **Contra**: sin hitos, el proyecto puede "mantenerse ocupado" sin nunca cerrar un vertical slice jugable; el trabajo indefinido desmotiva.
- **Veredicto**: descartado; se adopta Kanban pero **con hitos**.

### A3. Hitos por vertical slice + Kanban (propuesta adoptada)
- **Favor**: juegos siempre jugables, motivación por entregas, tablero para el flujo diario.
- **Contra**: requiere madurez para desglosar hitos en módulos/tareas.
- **Veredicto**: **DECISIÓN ADOPTADA** (A3).

### A4. Gestión sin tablero (solo Markdown en repo)
- **Favor**: cero herramientas externas.
- **Contra**: sin vista visual, el seguimiento diario es tedioso y se abandona.
- **Veredicto**: se usa como **contingencia offline**, no como herramienta principal.

### A5. Tablero externo desvinculado del repo (Trello/Notion)
- **Favor**: simples de usar.
- **Contra**: duplican el estado (tablero vs. tabla global) y la duplicación genera desactualización.
- **Veredicto**: descartado; solo GitHub Projects por su integración nativa con el repo.

### A6. Gestión de agentes sin protocolo (mensajes sueltos)
- **Favor**: nada que aprender.
- **Contra**: sin `CHECKLIST-GLOBAL.md` los agentes pisan archivos, inflan progreso y el estado muere.
- **Veredicto**: descartado; el protocolo de la sección 21 de `AGENTS.md` es obligatorio.

---

## 3. Decisiones Tomadas

| # | Decisión | Justificación |
|---|----------|---------------|
| D1 | Metodología: **Kanban liviano + hitos por vertical slice** | Equilibrio óptimo estructura/flexibilidad para 1 persona + agentes |
| D2 | Tablero: **GitHub Projects v2** | Integración nativa con el repo, gratuita, vistas kanban y roadmap |
| D3 | Fuente de verdad: **`CHECKLIST-GLOBAL.md` + `05-Checklist.md` por módulo** | El estado vive en el repo, versionado y verificable con scripts |
| D4 | Coordinación de agentes: **protocolo sección 21 de `AGENTS.md` + `ESTADO-PARALELO.md`** | Ya probado en el proyecto; este módulo lo operativiza |
| D5 | Hito maestro inicial: **vertical slice (M138)** | Primer entregable jugable; objetivo motivador común a toda la gestión |
| D6 | Iteraciones: **bloques de trabajo por hito** con planificación al inicio y retrospectiva al cierre | Ceremonias mínimas pero presentes |
| D7 | Registro de decisiones: **ADRs en Markdown** dentro de `DOCUMENTACION/` | Trazabilidad barata y versionada |
| D8 | Anti-abandono: **política activa con señales de alerta y plan de pausa** | El riesgo #1 del dominio recibe mitigación explícita |
| D9 | Contingencia: **proceso offline con Markdown local** | El desarrollo no se detiene sin internet |
| D10 | DoD: **5 criterios obligatorios por módulo/hito** (código, docs, tests, log, firma) | Definido en la sección 21.6 de `AGENTS.md`; se adopta tal cual |

---

## 4. Riesgos del Módulo (gestión)

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|-----------|
| La gestión se vuelve burocracia vacía | Media | Alto | DoD exige documentación útil, no voluminosa; retrospectivas evalúan el proceso |
| El tablero se desincroniza de la tabla global | Media | Alto | Estados viven en el repo; scripts verifican consistencia |
| Agentes marcan `[x]` sin cumplir DoD | Media | Alto | QA cruzado entre modelos distintos (sección 21.8) |
| El fundador abandona el proceso | Alta | Crítico | Política anti-abandono del diseño D8 |
| Pérdida de histórico de decisiones | Baja | Medio | ADRs versionados en git + backups (M107) |