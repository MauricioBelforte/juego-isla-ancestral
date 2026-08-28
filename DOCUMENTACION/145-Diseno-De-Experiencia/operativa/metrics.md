**Modelo:** GLM
**Plataforma:** Kilo
**Fecha:** 2026-08-28
**Componente:** 145-Diseno-De-Experiencia
**Estado:** Implementación operativa (entregable M145)

---

# Métricas de Experiencia (`metrics`) — Módulo 145

> Qué medir, cómo y qué se hace con los datos. Recolección: **M105 (telemetría)** sobre infraestructura M104 (analytics, opt-out según M80). Esta capa define las métricas **de experiencia** y su ciclo de mejora; nunca incluye datos personales (M80/M106).

## 1. Métricas de onboarding

| Métrica | Definición | Objetivo |
|---|---|---|
| Tasa de completado de onboarding | % de partidas nuevas con onboarding orgánico completado | ≥ 90 % |
| Tiempo hasta primer objetivo | Mediana de minutos hasta cumplir el primer objetivo | ≤ 10 min |
| Abandono por evento guiado | % de sesiones que terminan ≤ 5 min después de cada evento | < 3 % |
| % de salto de tutorial | % que oculta los eventos guiados | informativo |

## 2. Métricas de retención (con lente cozy, sin FOMO)

| Métrica | Definición | Referencia saludable |
|---|---|---|
| D1 / D7 / D30 | % de jugadores que vuelven a 1/7/30 días | indie cozy típico: 40/20/8 % (referencia, no contrato) |
| Sesiones por semana activa | Mediana | 3-5 |
| Duración media de sesión | Minutos | 30-90 (cozy: sesiones cortas frecuentes son buenas) |
| % de jugadores en postgame (≥5 h) | Profundidad de retención voluntaria | ≥ 30 % en 3 meses |

Regla M94: las métricas de retención **no se optimizan con mecánicas de FOMO** (streaks, expiración, exclusividad); se optimizan con contenido que respeta al jugador.

## 3. Métricas de satisfacción

| Fuente | Métrica | Meta |
|---|---|---|
| Reviews de Steam | % positivas | ≥ 90 % (M143/M144) |
| Encuestas in-game (opcional, 1 pregunta) | Satisfacción 1-5 | ≥ 4/5 con ≥ 10 respuestas (M151) |
| Playtests (M114) | Nota de diversión del hito | ≥ 4/5 |
| Tickets de soporte (M121) | Quejas recurrentes de UX | 0 temas top-3 repetidos entre parches |

## 4. Dashboard y proceso

- **Dashboard:** pestaña Google Sheets (patrón de M134) con las tablas anteriores + tendencias semanales; fuente de datos: exportes de M105 (agregados, anónimos).
- **Recolección:** eventos de gameplay definidos por M105; opt-out del jugador (M80); sin recolección en modo offline salvo cola local que el jugador aprueba.
- **Análisis:** revisión mensual integrada al ciclo de M133 (cierre de bloque/reporte mensual); trimestral con informe a M144.
- **Alertas de anomalías:** caída > 20 % semana a semana en D7 · abandono de onboarding > 10 % en un evento · picos de quejas de un mismo tema.
- **Ciclo de mejora:** alerta → hipótesis → cambio acotado (un sistema) → medir 2 semanas → confirmar o revertir. Todo cambio con log.
- **Revisión mensual:** comienza cuando exista telemetría activa (post-M105, lanzamiento/beta); antes de eso, las métricas de playtest (M114) sustituyen a las automáticas.

**Firma del último agente que modificó este documento:**

**Modelo:** GLM
**Plataforma:** Kilo
