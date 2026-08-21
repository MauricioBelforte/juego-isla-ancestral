# Módulo 132: Producción del Equipo — Diseño

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:30:00

## 1. Estructura Organizativa

### Diagrama de Roles

```
┌─────────────────────────────────────────────┐
│           GAME DIRECTOR / PO                │
│    Visión, prioridades, decisiones finales  │
└──────────────────┬──────────────────────────┘
                   │
    ┌──────────────┼──────────────┐
    │              │              │
┌───▼───┐    ┌────▼────┐   ┌────▼────┐
│ TECH  │    │  ART    │   │PRODUCER │
│ LEAD  │    │  LEAD   │   │  / SM   │
└───┬───┘    └────┬────┘   └────┬────┘
    │              │              │
┌───▼───┐    ┌────▼────┐   ┌────▼────┐
│ Devs  │    │ Artists │   │   QA    │
│ Tools │    │  2D/3D  │   │  CM     │
└───────┘    └─────────┘   └─────────┘
```

### Tabla RACI (Responsable, Accountable, Consulted, Informed)

| Decisión | R | A | C | I |
|----------|---|---|---|---|
| Visión del juego | Game Director | Game Director | Lead Programmer, Lead Artist, Designer | Todo el equipo |
| Arquitectura técnica | Lead Programmer | Lead Programmer | Game Director, devs | Todo el equipo |
| Dirección artística | Lead Artist | Lead Artist | Game Director, artists | Todo el equipo |
| Mecánicas de juego | Game Designer | Game Director | Lead Programmer, Lead Artist | Todo el equipo |
| Presupuesto | Producer | Game Director | Leads | — |
| Schedule | Producer | Game Director | Leads | Todo el equipo |
| Cambios de alcance | Game Director | Game Director | Producer, Leads | Todo el equipo |

## 2. Protocolo de Comunicación

### Canales

| Canal | Propósito | Frecuencia |
|-------|-----------|------------|
| **#general** | Anuncios generales | Diario |
| **#dev-programming** | Discusión técnica | Diario |
| **#dev-art** | Discusión de arte | Diario |
| **#dev-design** | Discusión de diseño | Diario |
| **#production** | Updates de progreso | Diario |
| **#random** | Off-topic | Libre |
| **@urgent** | Bloqueos críticos | Cuando sea necesario |

### Reuniones

| Reunión | Frecuencia | Duración | Participantes |
|---------|------------|----------|---------------|
| **Daily Standup** | Diaria | 15 min | Todo el equipo |
| **Sprint Review** | Semanal | 1 hora | Todo el equipo |
| **Retrospective** | Quincenal | 1 hora | Todo el equipo |
| **Planning** | Mensual | 2 horas | Leads + Producer |
| **1:1** | Quincenal | 30 min | Cada persona + Game Director |
| **All Hands** | Mensual | 1 hora | Todo el equipo |

## 3. Gestión de Tareas

### Pipeline de Tareas

```
[Backlog] ──► [To Do] ──► [In Progress] ──► [Review] ──► [Done]
                                        │
                                        ▼
                                   [Blocked]
```

### Priorización

| Prioridad | Descripción | SLA |
|-----------|-------------|-----|
| **P0 - Crítico** | Bloquea el juego, no hay workaround | 24h |
| **P1 - Alto** | Importante, tiene workaround parcial | 3 días |
| **P2 - Medio** | Mejora significativa, no urgente | 1 semana |
| **P3 - Bajo** | Nice-to-have, cuando haya tiempo | Flexible |

### Formato de Tarea

```
## [Título de la Tarea]

**Prioridad:** P0/P1/P2/P3
**Asignado a:** [Nombre]
**Estimación:** [Horas/días]
**Dependencias:** [Otras tareas]
**Contexto:** [Descripción del problema/feature]
**Criterios de aceptación:**
- [ ] Criterio 1
- [ ] Criterio 2
**Notas:**
- Información adicional
```

## 4. Resolución de Conflictos

### Proceso

```
[Conflicto] ──► [Discusión directa entre involucrados]
                      │
                 [¿Resuelto?]
                      │
              SÍ ──► [Documentar acuerdo]
              NO ──► [Escalar a Lead]
                      │
                 [Lead media]
                      │
                 [¿Resuelto?]
                      │
              SÍ ──► [Documentar acuerdo]
              NO ──► [Escalar a Game Director]
                      │
                 [Game Director decide]
                      │
                 [Documentar decisión]
```

## 5. Onboarding

### Checklist de Onboarding (Semana 1)

- [ ] Acceso a repositorio de código
- [ ] Acceso a repositorio de documentación
- [ ] Acceso a Discord y canales relevantes
- [ ] Acceso a herramientas de diseño (Figma, etc.)
- [ ] Revisión de AGENTS.md y convenciones
- [ ] Revisión de arquitectura general (M07)
- [ ] Revisión de documentación del proyecto (M02)
- [ ] Reunión 1:1 con Game Director
- [ ] Reunión 1:1 con Lead del área
- [ ] Primera tarea simple para familiarizarse
