**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 144: Después del Lanzamiento (110 ítems)

## Convención
- `[x]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Revisar reviews (1º)

- [x] Definir monitoreo de reviews en Steam/EGS/GOG (M97) [M]
- [x] Definir clasificación de reviews por tema (bug, balance, UX, request) [M]
- [x] Definir respuesta a reviews < 48 h (M100) [M]
- [x] Definir seguimiento de la evolución de rating semanal [S]
- [x] Definir pull de reviews al tablero de M144 [S]
- [x] Definir detección de review bombing [S]
- [x] Definir plantillas de respuesta revisadas (M126) [S]
- [x] Definir escalamiento de reviews críticas a hotfix [M]

## 2. Revisar bugs (2º)

- [x] Definir triaje continuo post-lanzamiento (M102) [M]
- [x] Definir severidades y SLA por severidad [M]
- [x] Definir regresión por parche (M112) [M]
- [x] Definir label "post-launch" en el tracker [S]
- [x] Definir informe semanal de bugs abiertos/cerrados [S]
- [x] Definir correlación de bugs con reviews [M]
- [x] Definir priorización P0-P3 tras lanzamiento [M]

## 3. Revisar rendimiento (3º)

- [x] Definir telemetría de FPS p50/p95 post-lanzamiento (M105) [M]
- [x] Definir monitoreo de crashes (M122) [M]
- [x] Definir análisis de perf por hardware (M96) [M]
- [x] Definir comparación de perf entre parches [M]
- [x] Definir reporte de memoria en sesiones largas (M62) [S]
- [x] Definir gate de perf para parches (M61) [M]

## 4. Revisar economía (4º)

- [x] Definir telemetría de economía (M38/M105) [M]
- [x] Definir detección de exploits de dinero [M]
- [x] Definir análisis de inflación/precios [M]
- [x] Definir comparación con el balance de diseño (M93) [M]
- [x] Definir hotfix de exploit en < 72 h [M]
- [x] Definir parche de balance económico mensual [M]

## 5. Revisar dificultad (5º)

- [x] Definir metrica de abandono por sistema (M105) [M]
- [x] Definir análisis de curvas de dificultad reales (M93) [M]
- [x] Definir decisiones de cambio con condiciones de diseño [M]
- [x] Definir simulación de ajustes antes de parchear (M113) [M]
- [x] Definir opciones de dificultad sin romper balance (M58) [M]

## 6. Revisar tutorial (6º)

- [x] Definir métrica de completado del tutorial (M92) [M]
- [x] Definir análisis de abandonos en tutorial [M]
- [x] Definir test de tutorial con nuevos usuarios (M114) [M]
- [x] Definir mejoras de tutorial en patch mensual [M]
- [x] Definir etelemetría de saltar tutorial [S]

## 7. Revisar onboarding (7º)

- [x] Definir conversión de los primeros 30 min (M105) [M]
- [x] Definir playtest de onboarding recurrentes (M114) [M]
- [x] Definir análisis de primera sesión (D1) [M]
- [x] Definir mejoras de onboarding por evidencia [M]
- [x] Definir test A/B de onboarding (M105) [C]

## 8. Revisar retención (8º)

- [x] Definir curvas D1/D7/D30 (M105/M94) [M]
- [x] Definir cohortes por fecha de compra [M]
- [x] Definir análisis de retención por plataforma (M96) [M]
- [x] Definir campañas de re-enganche (M100) [M]
- [x] Definir horario de sesión por región [S]
- [x] Definir comparación con benchmarks del género cosy [S]

## 9. Revisar contenido más jugado (9º)

- [x] Definir ranking de sistemas por uso (M105) [M]
- [x] Definir horas por sistema (pesca, construcción, templos) [M]
- [x] Definir cruce con reviews (qué se pide) [M]
- [x] Definir priorización de mejoras a lo más jugado [S]
- [x] Definir contenido de DLC alineado a lo más jugado (M120) [M]

## 10. Revisar contenido ignorado (10º)

- [x] Definir umbral de contenido ignorado (< 10% uso) [M]
- [x] Definir diagnóstico de causas (telemetría+soporte) [M]
- [x] Definir decisión: mejorar (target 3 meses) o archivar [M]
- [x] Definir archivar con nota pública (M100) [S]
- [x] Definir reporte mensual de contenido procesado [S]

## 11. Crear parches (11º)

- [x] Definir hotfix P0/P1 < 72 h (M142/M143) [C]
- [x] Definir patch mensual con balance/mejoras [M]
- [x] Definir changelog público en cada parche [M]
- [x] Definir pipeline de parche = M117 (gates) [M]
- [x] Definir regresión completa por patch (M112) [M]
- [x] Definir rollback plan por parche (M107/M117) [M]
- [x] Definir prueba de actualización de parche (M116) [M]
- [x] Definir hotfix sin features (solo fixes) [S]
- [x] Definir compatibilidad de saves entre parches (M59) [M]

## 12. Crear mejoras (12º)

- [x] Definir backlog de mejoras con evidencia (M105/reviews) [M]
- [x] Definir priorización semanal con datos [M]
- [x] Definir impacto medible por mejora (target) [M]
- [x] Definir mejoras de accesibilidad post-lanzamiento (M58) [M]
- [x] Definir mejoras de localización según quejas (M87) [M]

## 13. Añadir contenido si corresponde (13º)

- [x] Definir GATE de contenido nuevo (M120) [M]
- [x] Definir evaluación mensual del GATE [M]
- [x] Definir contenido-lite en parches (eventos M74, items M95) [M]
- [x] Definir DLC/expansión con su propio plan si GATE pasa [C]
- [x] Definir no contenido gratuito que canibalice V2 sin roadmap [S]
- [x] Definir alineación con el roadmap público (M136) [M]

## 14. Mantener backups (14º)

- [x] Definir backups de servicio (RPO 24 h) (M107) [M]
- [x] Definir backup de bases de datos trimestrales [S]
- [x] Definir restauración probada trimestral [S]
- [x] Definir retención de backups 90 días [S]
- [x] Definir respaldo de builds de lanzamiento (M143) [S]
- [x] Definir disaster recovery plan post-lanzamiento [M]

## 15. Mantener soporte (15º)

- [x] Definir SLA de primera respuesta ≤ 72 h (M121) [M]
- [x] Definir base de conocimientos actualizada [M]
- [x] Definir plantillas de respuestas (M126 legal) [M]
- [x] Definir escalamiento de soporte a bugs P0/P1 [M]
- [x] Definir canal de sugerencias oficial (M100) [S]
- [x] Definir reporte mensual de tickets [S]

## 16. Mantener documentación (16º)

- [x] Definir notas de parche público (Steam/web) [M]
- [x] Definir wiki del juego actualizada (M100) [M]
- [x] Definir FAQ viva por tema recurrente [M]
- [x] Definir documentación interna de cambios (Logs/) [S]
- [x] Definir plantilla única de changelog [S]
- [x] Definir versionado de la documentación con cada parche [S]

## 17. Cadencias, responsables y cierre

- [x] Definir tablero semanal de 9 métricas (M105) [C]
- [x] Definir reunión semanal de 30 min de post-launch [S]
- [x] Definir fases: D1-D7 / semanas 1-4 / meses 2-6 / trimestres [M]
- [x] Definir roles: dev/CM/QA/DATA/OPS (M143) [M]
- [x] Definir reporte mensual a M136 (roadmap) [M]
- [x] Definir decisiones solo con evidencia (no intuición) [S]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]
- [x] Definir feed del tablero al GATE de M120 [S]

## Totales

**Total de ítems:** 105
**Ítems resueltos por documentación:** 105 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)