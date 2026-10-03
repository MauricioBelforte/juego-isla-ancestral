# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-03

# Manual de Producción — Isla Ancestral (M132)

**Aplicable a:** Equipo de producción del estudio.
**Dependencia:** M134 (Gestión del Proyecto) ✅.

---

## A. Estructura Organizativa

### Roles flexibles (equipo pequeño, ≤5 personas)
En equipos de 1-5 personas, un individuo puede cumplir 2-3 roles simultáneamente
(p. ej. Lead Programmer + Programador + QA). La tabla RACI sigue aplicando:
el rol "decisor" del RACI es el que toma la decisión, no la persona.
Si hay conflicto entre roles, el Game Director desempata.

### Proceso de cambio de roles
1. Propuesta por el Game Director o el Lead afectado.
2. Discusión en All Hands mensual.
3. Documento de transición (quién asume, plazo, conocimiento a transferir).
4. Registro en el changelog de procesos.

## B. Roles y Responsabilidades

### Lead Programmer
- **Arquitectura:** Define y mantiene la arquitectura del proyecto (M04).
- **Código core:** Implementa y revisa los sistemas críticos (EventBus, save, escena principal).
- **Revisión de PRs:** Todo PR requiere aprobación del Lead Programmer antes de merge.
- **Mentoría:** Asesora a programadores en decisiones técnicas.

## C. Comunicación Interna

### Canales de Discord
| Canal | Propósito |
|-------|-----------|
| #general | Anuncios, celebraciones, info general |
| #dev | Discusión técnica, code review, bugs |
| #art | Discusión artística, feedback de assets |
| #design | Discusión de diseño, balance, mecánicas |
| #production | Schedule, bloqueos, gestión |
| #watercooler | Off-topic, memes, social |

### Horarios y overlaps
- **Horario flexible:** 8-12h semanales por persona (según rol).
- **Overlap mínimo:** 2h/día de solape entre áreas (Lead Programmer + Lead Artist al menos).
- **Huso:** Central (GMT-3) por defecto. Los que estén en otro huso comparten overlap.

### Reuniones
| Reunión | Frecuencia | Duración | Participantes |
|---------|-----------|----------|---------------|
| Daily Standup | Diaria | 15 min | Todo el equipo |
| Sprint Review | Semanal | 1h | Leads + Director |
| Retrospective | Quincenal | 1h | Todo el equipo |
| Planning | Mensual | 2h | Leads + Director |
| 1:1 | Quincenal | 30 min | Lead + miembro |
| All Hands | Mensual | 1h | Todo el equipo |

**Template de reunión:** 1) Agenda 2) Updates (3 min por persona en Standup) 3) Discusión 4) Acciones 5) Notas.

### Reglas de respuesta urgentes
- **Urgente (bloquea release):** Responder en 2h.
- **Importante (bloquea tarea):** Responder en 1 día.
- **Normal:** Responder en 2 días.

## D. Gestión de Tareas

### Estado Blocked
- Toda tarea bloqueada debe marcar **causa** (qué bloquea, a quién, desde cuándo).
- Formato: `[BLOCKED: necesita M53 (UI Toolkit) — desde 2026-10-01]`
- Se revisa en Daily Standup. Si lleva > 3 días, escala al Producer.

### WIP limits
| Columna | Límite |
|---------|--------|
| To Do | 15 |
| In Progress | 5 (por persona máx 2) |
| Review | 5 |
| Done | — |

### Estimation
- **Story points:** 1, 2, 3, 5, 8, 13 (Fibonacci). 13 = "grande, dividí en 2".
- **Horas:** Para tasks de producción no técnicas (meetings, docs), usar horas.
- **Calibración:** Tras 3 sprints, comparar estimado vs real y ajustar.

### Dashboard de progreso
- **Herramienta:** GitHub Projects (kanban) + gráfico burndown en README.
- **Actualización:** Daily (In Progress/Review) + Sprint end (Done).

### Proceso de retrospective
1. 3 columnas: "Qué funcionó / Qué no / Qué probar".
2. Votación por puntos (3 por persona, distribución libre).
3. Top 3 acciones → asignadas con dueño + fecha en el siguiente sprint.
4. Registrar en `docs/production/retros/`.

## E. Toma de Decisiones

### Change request para cambios de alcance
1. Documento: qué cambia, por qué, impacto en scope/timeline/costo.
2. Aprobación: Game Director + Producer.
3. Si impacta > 1 sprint: se documenta en M134 (proyecto).
4. Registrar en changelog de procesos.

## F. Resolución de Conflictos

### Nivel 1: Discusión directa
- 30 min, solo los involucrados.
- Objetivo: llegar a acuerdo. Si no, escalar a Nivel 2.
- Documentar: "Intentamos X, Y. No pudimos acordar sobre Z."

### Nivel 2: Media del Lead del área
- Lead escucha a ambos (10 min c/u).
- Propuesta de solución. Si aceptan, cerrar. Si no, Nivel 3.

## G. Onboarding

### Mentor
- Cada nuevo miembro recibe un **mentor** (el Lead del área o un senior próximo).
- 1:1 semanal durante el primer mes.
- El mentor no evalúa, solo guía y responde dudas.

### Primera tarea
- **Semana 1:** Tarea simple y concreta (ej: "corrige 3 typos en la docs", "corre un test y reporta resultado").
- **Objetivo:** Familiarizarse con repo, herramientas y flujo de trabajo.
- **Tiempo estimado:** < 2h.

### Reunión de bienvenida
- **Con Game Director (30 min):** Visión del juego, valores, expectativas.
- **Con Lead del área (30 min):** Stack técnico, conventions, cómo trabajar juntos.

### FAQ para nuevos miembros
- Documentado en `docs/production/faq.md`:
  - Cómo clonar el repo
  - Cómo instalar herramientas
  - Dónde están los docs
  - Cómo pedir ayuda
  - Horarios y reuniones
  - Cómo reportar bugs

### Período de prueba
- **30 días** de prueba inicial (evaluación de fit).
- **90 días** de estabilización (evaluación de producción).
- Feedback en 1:1 al día 30 y al día 90.

## H. Productividad y Bienestar

### Horarios flexibles
- **Núcleo:** 10:00-16:00 (horario de solape obligatorio).
- **Flexibilidad:** El resto del día es flexible (mínimo 8h, máximo 10h).
- **Horas extra:** Solo con aprobación del Producer.

### Límite de horas extras
- **Máximo:** 4h extra/semana.
- **Más de 4h:** Aprobación del Producer + plan de recuperación (jornada reducida al día siguiente).

### Días libres
- **Vacaciones:** 30 días/año (Argentina).
- **Feriados:** Calendario nacional + 2 días de "cierre" por feriado.
- **Días personales:** 2 días/año sin justificación.

### Trabajo remoto
- **100% remoto por defecto.**
- **Encuentros presenciales:** 1-2 veces/año (team building + planning trimestral).
- **Sin requisitos de hardware del estudio** (BYOD).

### Feedback regular
- **1:1 quincenal:** Feedback bilateral (no solo del lead al miembro).
- **Retrospective:** Feedback grupal.
- **Encuesta anual:** Satisfacción, burnout, áreas de mejora.

### Mejora continua
- **Trimestralmente:** Revisar los procesos (¿funcionan?, ¿son ágiles?, ¿generan overhead?).
- **Registro:** Cambios en `docs/production/changelog.md`.
- **Feedback:** Canal #production en Discord para sugerencias.

## I. Documentación y Mantenimiento

### Revisión trimestral
- **Fecha:** Primer lunes de cada trimestre.
- **Responsable:** Producer.
- **Alcance:** Todos los documentos de `docs/production/`.
- **Output:** Actualizaciones + changelog.

### Changelog de procesos
- `docs/production/changelog.md` — cada cambio en procesos se registra:
  ```
  ## 2026-10-03 — M132
  - Se añadió: WIP limits (To Do=15, In Progress=5, Review=5)
  - Se modificó: Retrospective (antes semanal → ahora quincenal)
  - Se eliminó: Reunión de status diaria (reemplazada por Standup)
  ```

### Entrenamiento
- **Onboarding:** Ver sección G.
- **Procesos nuevos:** Se documenta + se explica en la próxima All Hands.
- **Documentación:** Cada proceso nuevo lleva un "cómo usar" en el archivo.

### Evaluación de efectividad
- **Métricas:** Velocity del equipo, tasa de bugs de regresión, satisfacción (encuesta).
- **Revisión:** En cada All Hands trimestral.

### Archivado
- Procesos obsoletos → `docs/production/archive/YYYY/`.
- Mover, no borrar. Referenciar en el changelog.
