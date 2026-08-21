# Módulo 132: Producción del Equipo — Análisis

**Modelo:** Nemotron 3 Ultra
**Plataforma:** OpenCode
**Fecha:** 2026-08-21 01:30:00

## 1. Análisis del Dominio

### Roles Típicos en un Estudio Indie

| Rol | Responsabilidad Principal | Dedicación |
|-----|--------------------------|------------|
| **Game Director** | Visión del juego, decisiones finales | Full-time |
| **Lead Programmer** | Arquitectura, código core, revisión | Full-time |
| **Lead Artist** | Dirección artística, pipeline de assets | Full-time |
| **Game Designer** | Mecánicas, niveles, balance | Full-time |
| **Producer** | Schedule, presupuesto, coordinación | Part-time |
| **Audio Lead** | Dirección de audio, implementación | Part-time |
| **QA Lead** | Testing, calidad, bugs | Part-time |
| **Community Manager** | Comunicación, redes sociales | Part-time |

### Estructura Organizativa para Equipo Pequeño (5-10 personas)

```
[Game Director / Product Owner]
       │
       ├── [Lead Programmer]
       │      ├── Programadores
       │      └── Tools Developer
       │
       ├── [Lead Artist]
       │      ├── 3D Artists
       │      ├── 2D Artists
       │      └── Animators
       │
       ├── [Game Designer]
       │      └── Level Designers
       │
       └── [Producer / Scrum Master]
              ├── QA
              └── Community Manager
```

## 2. Decisiones de Diseño

### Decisión 1: Metodología de Producción

**Opción A:** Scrum completo (sprints, daily, retro)
- Pro: Estructurado, predecible
- Contra: Mucho overhead para equipo pequeño

**Opción B:** Kanban (tablero visual, WIP limits)
- Pro: Flexible, menos overhead
- Contra: Menos predecible

**Decisión:** Kanban como base + review semanal + planning mensual. Scrum solo para milestones críticos.

### Decisión 2: Herramientas de Comunicación

**Opción A:** Todo en un solo lugar (ej: Discord)
- Pro: Centralizado
- Contra: Mezcla de contenido

**Opción B:** Herramientas separadas por tipo
- Pro: Organizado
- Contra: Fragmentación

**Decisión:** Discord para chat síncrono + Notion/Linear para documentación/tareas + GitHub para código.

### Decisión 3: Toma de Decisiones

**Opción A:** Game Director decide todo
- Pro: Rápido, coherente
- Contra: Bottleneck, desmotivación

**Opción B:** Consenso del equipo
- Pro: Inclusivo, mejor calidad
- Contra: Lento

**Decisión:** Modelo RACI: Game Director decide, equipo aconseja. Decisiones técnicas: Lead Programmer. Artísticas: Lead Artist. De producto: Game Director.

## 3. Análisis de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Comunicación deficiente | Alta | Alto | Canales claros, reuniones regulares |
| Burnout del equipo | Media | Crítico | Límites de horas, días libres |
| Conflictos no resueltos | Media | Alto | Proceso de resolución documentado
| Alcance creep | Alta | Alto | Proceso de change request |
| Pérdida de miembro clave | Media | Crítico | Documentación completa, cross-training |
