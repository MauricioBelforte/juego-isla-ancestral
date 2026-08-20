**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 144: Después del Lanzamiento

## 1. Problema
El día 1 del lanzamiento (M143) no termina el trabajo: el juego necesita una **estrategia post-lanzamiento** para revisar reviews/bugs/rendimiento/economía/dificultad, iterar (parches, mejoras, contenido si corresponde), mantener backups/soporte/documentación y leccionar sobre lo que la telemetría dice (M105) para la retención a largo plazo (M94) y los hitos de V2 (M136).

## 2. Objetivo del módulo
Documentar el **plan post-lanzamiento**: revisión de reviews, bugs, rendimiento, economía, dificultad, tutorial/onboarding, retención, contenido más jugado/ignorado; creación de parches (M142 hotfix + updates), mejoras, contenido (DLC M120 si corresponde); mantenimiento de backups (M107), soporte (M121) y documentación; con cadencia y responsables y el calendario de hitos.

## 3. Alcance (derivado del plan maestro: sección 143 "DESPUÉS DEL LANZAMIENTO")
1. **Revisar reviews** — monitoreo (Steam/EGS/social), clasificación, respuestas (M100).
2. **Revisar bugs** — triaje continuo (M102/M143) con severidad.
3. **Revisar rendimiento** — telemetría (M105/M104) + perf de parches.
4. **Revisar economía** — balance del mercado (M38) post-release.
5. **Revisar dificultad** — curvas reale vs diseño (M93).
6. **Revisar tutorial** — retención de las primeras horas (M92).
7. **Revisar onboarding** — conversión de los primeros 30 min.
8. **Revisar retención** — curvas D1/D7/D30 (M94/M105).
9. **Revisar contenido más jugado** — qué sistema triunfa (M105).
10. **Revisar contenido ignorado** — qué no se usa (M105) → decisión.
11. **Crear parches** — hotfixes (M142) + patches programados con cadencia.
12. **Crear mejoras** — mejoras de sistemas según telemetría/reviews.
13. **Añadir contenido si corresponde** — DLC/expansiones (M120) con GATE.
14. **Mantener backups** — backup de datos de servicio y saves (M107).
15. **Mantener soporte** — continuidad del soporte (M121) con SLA.
16. **Mantener documentación** — wiki/FAQ/notas de parche actuales (M100/M99).

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Tablero post-lanzamiento con 9 métricas semanales (reviews, bugs, perf, economía, dificultad, tutorial, onboarding, retención, contenido) |
| RF2 | Revisión semanal de reviews y triaje de bugs con severidad |
| RF3 | Parches: hotfix < 72 h (M142), patch mensual; changelog público |
| RF4 | Mejoras priorizadas por evidencia (telemetría + reviews) |
| RF5 | GATE de contenido nuevo (DLC M120) con criterios de base/nivel |
| RF6 | Backups operativos (M107) con RPO 24 h en servicio |
| RF7 | Soporte continuo (M121) con SLA y base de conocimientos |
| RF8 | Documentación viva: notas de parche, FAQ, wiki |
| RF9 | Reportes mensuales a M136 (roadmap) para V2 |
| RF10 | Mono-canal: decisiones basadas en evidencia (nada de "la IA me dijo") |

## 5. Criterios de aceptación (DoD del módulo)
1. Los 16 puntos del maestro documentados con cadencia y responsables.
2. Tablero semanal de post-lanzamiento definido (9 métricas).
3. Flujo de parches (hotfix + mensual) con proceso de changelog.
4. GATE de DLC/expansión documentado (M120).
5. Backups y soporte con SLA claros.
6. Documentación viva con cadencia de actualización.
7. Reporte mensual al roadmap (M136).

## 6. Restricciones
- **Aplican:** M143 (lanzamiento), M142 (RC/hotfix), M120 (DLC), M121 (soporte), M100 (comunidad), M105 (telemetría), M102 (bugs), M93 (balance), M92 (tutorial), M94 (retención), M107 (backups), M95 (monetización — precios/descuentos).
- La cadencia post-launch se define por fases: D1-D7 (caliente), semanas 1-4, trimestres 1-2 (hasta V2 GATE).
- Sin promesas públicas de fechas de parches que no estén en el roadmap (M136).