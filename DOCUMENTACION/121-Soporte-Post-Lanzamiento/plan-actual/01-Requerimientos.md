**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 01-Requerimientos.md — Módulo 121: Soporte Post-Lanzamiento

## ID del Módulo
- **Código:** M121 (plan maestro: sección 120 — Soporte Post-Lanzamiento)
- **Carpeta:** `DOCUMENTACION/121-Soporte-Post-Lanzamiento/`
- **Dependencias:** M102 (Bug Tracking), M122 (Crash Reporting), M61 (Rendimiento), M100 (Community Management), M107 (Backups)
- **Carácter:** Módulo de soporte post-lanzamiento para mantenimiento del juego

## 1. Problema

El proyecto necesita un sistema de **soporte post-lanzamiento** para mantener el juego después del lanzamiento. Debe incluir canal de soporte, FAQ, sistema de tickets, seguimiento de errores, seguimiento de crashes, seguimiento de rendimiento, seguimiento de reviews, hotfixes, parches, actualizaciones, recuperación de saves, comunicación de incidencias, roadmap, community updates, backups, monitorización y plan de abandono del servicio si existe online.

## 2. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Canal de soporte | Canal de soporte para jugadores (email, Discord, Steam forums) |
| RF2 | FAQ | FAQ documentada y accesible para preguntas frecuentes |
| RF3 | Sistema de tickets | Sistema de tickets para reportar problemas y solicitar ayuda |
| RF4 | Seguimiento de errores | Seguimiento de errores reportados por jugadores |
| RF5 | Seguimiento de crashes | Seguimiento de crashes reportados por crash reporting |
| RF6 | Seguimiento de rendimiento | Seguimiento de problemas de rendimiento reportados |
| RF7 | Seguimiento de reviews | Seguimiento de reviews de Steam y otros canales |
| RF8 | Hotfixes | Proceso de hotfixes para bugs críticos |
| RF9 | Parches | Proceso de parches para bugs no críticos |
| RF10 | Actualizaciones | Proceso de actualizaciones para new features |
| RF11 | Recuperación de saves | Proceso de recuperación de savegames corruptos |
| RF12 | Comunicación de incidencias | Comunicación de incidencias a la comunidad |
| RF13 | Roadmap | Roadmap público de actualizaciones futuras |
| RF14 | Community updates | Actualizaciones de la comunidad sobre estado del desarrollo |
| RF15 | Backups | Backups automáticos de datos críticos (integración con M107) |
| RF16 | Monitorización | Monitorización de servicios online (si aplica) |
| RF17 | Plan de abandono del servicio | Plan de abandono del servicio si existe online |

## 3. Requisitos No Funcionales

- Soporte debe ser accesible y amigable (tono cozy)
- Respuesta oportuna a tickets de soporte (SLA de 24-48 horas)
- Comunicación transparente sobre incidencias y retrasos
- Hotfixes priorizados para bugs críticos
- Parches regulares para bugs no críticos
- Actualizaciones con changelog visible
- Recuperación de saves con backup automático
- Monitorización 24/7 de servicios online (si aplica)
- Plan de abandono documentado si hay componentes online

## 4. Criterios de Aceptación

1. Los 17 puntos de la sección 120 del plan maestro resueltos.
2. Canal de soporte configurado (email, Discord, Steam forums).
3. FAQ documentada y accesible (sitio web, Steam, Discord).
4. Sistema de tickets configurado (Steam Support, sistema propio).
5. Seguimiento de errores integrado con M102 (Bug Tracking).
6. Seguimiento de crashes integrado con M122 (Crash Reporting).
7. Seguimiento de rendimiento integrado con M61 (Rendimiento).
8. Seguimiento de reviews (Steam, Reddit, etc.).
9. Proceso de hotfixes definido (bugs críticos).
10. Proceso de parches definido (bugs no críticos).
11. Proceso de actualizaciones definido (new features).
12. Proceso de recuperación de saves definido (backup automático).
13. Comunicación de incidencias definida (transparente y oportuna).
14. Roadmap público actualizado regularmente.
15. Community updates regulares (Twitter/X, Discord, Reddit).
16. Backups automáticos configurados (integración con M107).
17. Monitorización de servicios online configurada (si aplica).
18. Plan de abandono del servicio documentado (si hay componentes online).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M142** — Release Candidate | Base para release candidate |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M142** — Release Candidate | Depende de este módulo |

