**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Componente:** 133-Gestion-Del-Proyecto
**Estado:** Documentación inicial (plan original)

---

# 01-Requerimientos.md — Módulo 133: Gestión del Proyecto

## 1. Problema

El proyecto *Isla Ancestral* (mundo voxel cozy ambientado en la isla Aurora, desarrollado en Godot 4.x con Voxel Tools y GDScript) es un proyecto indie autofinanciado, dirigido por un fundador que trabaja solo o con un equipo muy pequeño y presupuesto cero. El plan maestro desglosa el desarrollo en 150+ módulos documentados, gestionados mediante un protocolo multiagente con `CHECKLIST-GLOBAL.md` como fuente de verdad.

El problema central es **administrativo, no técnico**: cómo organizar, planificar, ejecutar y hacer seguimiento de un proyecto de esta envergadura con recursos humanos y económicos mínimos, sin que el trabajo se desorganice, sin que la documentación quede obsoleta y, sobre todo, sin que el proyecto muera por **abandono** — el riesgo más frecuente y mortal en proyectos indie desarrollados por una sola persona.

### Contexto del problema

- Equipo reducido (idealmente 1 persona + agentes de IA como fuerza de trabajo auxiliar).
- Presupuesto cero: todas las herramientas de gestión deben ser gratuitas.
- El proyecto ya funciona con un protocolo multiagente: `CHECKLIST-GLOBAL.md` (tabla resumen de módulos), `Mensajes entre modelos/ESTADO-PARALELO.md` (coordinación de agentes) y reglas de la sección 21 de `AGENTS.md`.
- Se necesita compatibilidad con el resto del plan maestro: M01 (Fundamentos del Proyecto, ya documentado), M135 (Riesgos del Proyecto), M136 (Roadmap), M137 (Prototipo) y M138 (Vertical Slice), siendo este último el primer gran hito jugable de la gestión.
- La metodología debe ser ligera: un proceso burocrático pesado en un equipo de 1-2 personas consume más tiempo del que ahorra.

---

## 2. Objetivos

### 2.1 Objetivo General

Definir un **sistema de gestión del proyecto** simple, gratuito y sostenible que permita planificar el desarrollo de *Isla Ancestral* por hitos, coordinar el trabajo humano y de agentes IA, mantener la fuente de verdad del estado del proyecto siempre actualizada y minimizar el riesgo de abandono, hasta alcanzar la v1.0.

### 2.2 Objetivos Específicos

| # | Objetivo | Criterio de éxito |
|---|----------|-------------------|
| 1 | Metodología liviana definida | Proceso documentado que demande ≤ 10% del tiempo de desarrollo en administración |
| 2 | Seguimiento por hitos | Hitos definidos con criterios de entrada y salida, culminando en el vertical slice (M138) |
| 3 | Coordinación humano + agentes IA | Reglas de reclamo, bloqueo, liberación y QA cruzado operativas y respetadas |
| 4 | Fuente de verdad confiable | `CHECKLIST-GLOBAL.md` refleja el estado real de cada módulo (verificable con los scripts de la sección 21.9) |
| 5 | Riesgo de abandono gestionado | Mitigaciones documentadas y aplicadas (hitos cortos, celebración de logros, anti-burnout) |
| 6 | Herramientas 100% gratuitas | Tablero, repositorio y documentos sin costo recurrente |
| 7 | Contextualizado a Godot 4.x | El proceso respeta el stack real del proyecto (GDScript, Voxel Tools, git) |

---

## 3. Alcance

### 3.1 Dentro del alcance (ESTE COMPONENTE)

- Metodología de gestión: ciclo de trabajo, ceremonias, hitos, flujo de estado de módulos.
- Roles y responsabilidades (fundador, agentes IA, QA cruzado).
- Definición de listo (DoD) aplicable a módulos e hitos.
- Flujo de trabajo con `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` como herramientas operativas.
- Selección de herramientas gratuitas de gestión (tablero, repositorio, documentación).
- Políticas de repositorio: ramas, commits, push, revisión.
- Plan de continuidad ante ausencia del fundador y riesgo de abandono.
- Registro de decisiones (ADRs) y actas de reuniones.
- Plantillas y guías de gestión (hitos, sprints/iteraciones, reportes).

### 3.2 Fuera del alcance (otros módulos)

- Riesgos del proyecto en detalle → M135 (Riesgos del Proyecto).
- Roadmap de largo plazo → M136 (Roadmap).
- Presupuesto y costos → M134 (Presupuesto).
- Organización del equipo de producción → M132 (Producción del Equipo).
- Contenido del prototipo y del vertical slice → M137 (Prototipo) y M138 (Vertical Slice).
- Implementación de código de juego (se gestiona, no se desarrolla aquí).

---

## 4. Requerimientos Funcionales (RF)

| ID | Requerimiento | Prioridad | Criterio de aceptación |
|----|---------------|-----------|------------------------|
| RF1 | Mantener `CHECKLIST-GLOBAL.md` como fuente de verdad del estado de todos los módulos | Alta | La tabla global se actualiza al reclamar, bloquear, completar o liberar módulos; el progreso coincide con los `05-Checklist.md` |
| RF2 | Mantener `ESTADO-PARALELO.md` como coordinador de agentes | Alta | Cada agente registra tarea, archivos involucrados, estado y timestamp |
| RF3 | Aplicar reglas de bloqueo: un módulo por agente a la vez | Alta | Ningún módulo queda bloqueado por dos agentes simultáneamente |
| RF4 | Ejecutar QA cruzado entre modelos distintos | Alta | Todo módulo `✅` pasa revisión de un segundo modelo antes de considerarse definitivo |
| RF5 | Organizar el desarrollo por hitos (M1...M5, prototipo M137, vertical slice M138) | Alta | Cada hito tiene objetivo, alcance, entregables y criterios de salida documentados |
| RF6 | Realizar ceremonias de planificación y retrospectiva | Media | Planificación por iteración e inspección periódica del proceso con acta |
| RF7 | Registrar y gestionar deuda técnica | Media | La deuda se registra con prioridad, responsable y plan de pago |
| RF8 | Gestionar cambios de alcance (scope creep) | Alta | Todo cambio de alcance pasa por proceso de renegociación documentado |
| RF9 | Gestionar el riesgo de abandono del fundador | Alta | Plan de continuidad, hitos cortos y señales de alerta definidas |
| RF10 | Registrar decisiones de arquitectura y proceso (ADRs) | Media | Cada decisión relevante queda documentada con contexto, opciones y resultado |
| RF11 | Llevar actas de reuniones | Media | Toda reunión de gestión queda registrada con fecha, temas y acuerdos |
| RF12 | Definir y aplicar política de repositorio (ramas, commits, push) | Alta | Commits en español, tiempo pasado, push solo bajo protocolo de la sección 4 de `AGENTS.md` |
| RF13 | Mantener un plan de continuidad ante ausencias del fundador | Media | La documentación es autoexplicativa y un agente puede retomar sin el fundador |
| RF14 | Generar reportes de avance periódicos | Media | Reporte mensual con módulos completados, en curso y riesgos activos |
| RF15 | Gestionar dependencias entre módulos | Media | Las dependencias de la tabla global se respetan al planificar |
| RF16 | Aplicar la DoD (definición de listo) a cada módulo | Alta | Ningún módulo se marca `[x]`/`✅` sin cumplir los 5 criterios de la DoD |

---

## 5. Requisitos No Funcionales (RN)

| ID | Requisito | Detalle |
|----|-----------|---------|
| RN1 | Idioma | Todo el proceso y la documentación en español |
| RN2 | Formato | Documentación en Markdown con la estructura estándar de `AGENTS.md` |
| RN3 | Presupuesto cero | Solo herramientas gratuitas; ninguna con costo recurrente obligatorio |
| RN4 | Sostenible para 1 persona | Administración ≤ ~10% del tiempo de desarrollo |
| RN5 | Compatible con agentes IA | El proceso es legible y ejecutable por modelos múltiples (secciones 10, 17 y 21 de `AGENTS.md`) |
| RN6 | Trazabilidad | Toda decisión, cambio y log tiene autor, fecha y motivo |
| RN7 | Resiliencia a ausencias | Un agente nuevo (o el fundador tras pausa larga) puede ponerse al día solo con la documentación |
| RN8 | Escalable de 1 a pocas personas | El proceso soporta incorporar 1-3 colaboradores sin rediseño |
| RN9 | Plataforma | Proceso independiente del SO (Windows y nube); encaja con Godot 4.x y git |
| RN10 | Git-friendly | El tablero y los estados viven en el repositorio (o se sincronizan con él) |
| RN11 | Verificable | El estado de la tabla global se valida con los scripts `generar_checklist_global.py` y `verificar_checklist.py` |
| RN12 | Respaldado | La gestión entra en el esquema de backups del proyecto (M107) |
| RN13 | Onboarding ágil | Un documento de arranque (README de gestión) permite incorporar cualquier agente en minutos |
| RN14 | Sin deuda de proceso | Las reglas no se evaden; las excepciones se documentan como desviaciones justificadas |

---

## 6. Restricciones

- **Tecnología del proyecto:** Godot 4.x, GDScript, Voxel Tools; el proceso de gestión debe ser agnóstico al código pero compatible con su repositorio.
- **Equipo:** 1 persona (fundador) + agentes de IA como fuerza auxiliar; sin contrataciones previstas.
- **Presupuesto:** cero; `Steam Direct Fee` (USD 100) como único desembolso previsto fuera del alcance de este módulo (ver M134).
- **Filosofía del juego:** vesión cozy; el proceso debe evitar el burnout, coherente con los Principios Innegociables (M152).
- **Documentación:** los documentos de gestión se ubican en `DOCUMENTACION/` y siguen las reglas de firmas, logs y planes del `AGENTS.md`.
- **Ergonomía:** tablero y checklist accesibles sin conexión (Markdown local) como contingencia.

---

## 7. Criterios de Aceptación del Módulo

- [x] La metodología de gestión está documentada en los 5 archivos del módulo.
- [x] Los roles, ceremonias, hitos y DoD están definidos de forma operable.
- [x] El flujo con `CHECKLIST-GLOBAL.md` y `ESTADO-PARALELO.md` está especificado.
- [x] La herramienta de tablero (GitHub Projects u otra gratuita) está decidida con justificación.
- [x] El riesgo de abandono tiene mitigaciones concretas.
- [x] La integración con M01, M135, M136, M137 y M138 está documentada.
- [x] El checklist del módulo tiene ≥ 120 ítems, todos verificables.

---

## 8. Fuentes del Requerimiento

| Fuente | Archivo / Sección |
|--------|-------------------|
| Reglas globales del proyecto | `AGENTS.md` (secciones 3, 4, 6, 10, 17, 21) |
| Fuente de verdad de módulos | `CHECKLIST-GLOBAL.md` (raíz) |
| Coordinación de agentes | `Mensajes entre modelos/ESTADO-PARALELO.md` |
| Fundamentos del proyecto | `DOCUMENTACION/01-Fundamentos-Del-Proyecto/plan-actual/` |
| Plan maestro | `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md` |
| Plan de producción | `DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md` |

---

## 9. Riesgos Iniciales Identificados

| Riesgo | Nivel | Mitigación inicial |
|--------|-------|--------------------|
| Abandono del proyecto por desmotivación o saturación | Alto | Hitos cortos, foco en vertical slice jugable, celebraciones, variable "diversión" en retrospectivas |
| Deuda de documentación (docs desactualizadas) | Alto | DoD con actualización obligatoria; scripts de verificación |
| Scope creep (alcance gigante del GDD) | Alto | Acotación v1.0 en M01; proceso de renegociación de alcance |
| Dependencia total del fundador | Medio | Plan de continuidad y documentación autoexplicativa |
| Pérdida de datos de gestión | Medio | Repositorio git + backups (M107) |
| Tablero abandonado (herramienta sin mantenimiento) | Bajo | Estados viven en el repo (Markdown); el tablero es espejo opcional |