**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 144: Después del Lanzamiento (110 ítems)

## Convención
- `[ ]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Revisar reviews (1º)

- [ ] Definir monitoreo de reviews en Steam/EGS/GOG (M97) [M]
- [ ] Definir clasificación de reviews por tema (bug, balance, UX, request) [M]
- [ ] Definir respuesta a reviews < 48 h (M100) [M]
- [ ] Definir seguimiento de la evolución de rating semanal [S]
- [ ] Definir pull de reviews al tablero de M144 [S]
- [ ] Definir detección de review bombing [S]
- [ ] Definir plantillas de respuesta revisadas (M126) [S]
- [ ] Definir escalamiento de reviews críticas a hotfix [M]

## 2. Revisar bugs (2º)

- [ ] Definir triaje continuo post-lanzamiento (M102) [M]
- [ ] Definir severidades y SLA por severidad [M]
- [ ] Definir regresión por parche (M112) [M]
- [ ] Definir label "post-launch" en el tracker [S]
- [ ] Definir informe semanal de bugs abiertos/cerrados [S]
- [ ] Definir correlación de bugs con reviews [M]
- [ ] Definir priorización P0-P3 tras lanzamiento [M]

## 3. Revisar rendimiento (3º)

- [ ] Definir telemetría de FPS p50/p95 post-lanzamiento (M105) [M]
- [ ] Definir monitoreo de crashes (M122) [M]
- [ ] Definir análisis de perf por hardware (M96) [M]
- [ ] Definir comparación de perf entre parches [M]
- [ ] Definir reporte de memoria en sesiones largas (M62) [S]
- [ ] Definir gate de perf para parches (M61) [M]

## 4. Revisar economía (4º)

- [ ] Definir telemetría de economía (M38/M105) [M]
- [ ] Definir detección de exploits de dinero [M]
- [ ] Definir análisis de inflación/precios [M]
- [ ] Definir comparación con el balance de diseño (M93) [M]
- [ ] Definir hotfix de exploit en < 72 h [M]
- [ ] Definir parche de balance económico mensual [M]

## 5. Revisar dificultad (5º)

- [ ] Definir metrica de abandono por sistema (M105) [M]
- [ ] Definir análisis de curvas de dificultad reales (M93) [M]
- [ ] Definir decisiones de cambio con condiciones de diseño [M]
- [ ] Definir simulación de ajustes antes de parchear (M113) [M]
- [ ] Definir opciones de dificultad sin romper balance (M58) [M]

## 6. Revisar tutorial (6º)

- [ ] Definir métrica de completado del tutorial (M92) [M]
- [ ] Definir análisis de abandonos en tutorial [M]
- [ ] Definir test de tutorial con nuevos usuarios (M114) [M]
- [ ] Definir mejoras de tutorial en patch mensual [M]
- [ ] Definir etelemetría de saltar tutorial [S]

## 7. Revisar onboarding (7º)

- [ ] Definir conversión de los primeros 30 min (M105) [M]
- [ ] Definir playtest de onboarding recurrentes (M114) [M]
- [ ] Definir análisis de primera sesión (D1) [M]
- [ ] Definir mejoras de onboarding por evidencia [M]
- [ ] Definir test A/B de onboarding (M105) [C]

## 8. Revisar retención (8º)

- [ ] Definir curvas D1/D7/D30 (M105/M94) [M]
- [ ] Definir cohortes por fecha de compra [M]
- [ ] Definir análisis de retención por plataforma (M96) [M]
- [ ] Definir campañas de re-enganche (M100) [M]
- [ ] Definir horario de sesión por región [S]
- [ ] Definir comparación con benchmarks del género cosy [S]

## 9. Revisar contenido más jugado (9º)

- [ ] Definir ranking de sistemas por uso (M105) [M]
- [ ] Definir horas por sistema (pesca, construcción, templos) [M]
- [ ] Definir cruce con reviews (qué se pide) [M]
- [ ] Definir priorización de mejoras a lo más jugado [S]
- [ ] Definir contenido de DLC alineado a lo más jugado (M120) [M]

## 10. Revisar contenido ignorado (10º)

- [ ] Definir umbral de contenido ignorado (< 10% uso) [M]
- [ ] Definir diagnóstico de causas (telemetría+soporte) [M]
- [ ] Definir decisión: mejorar (target 3 meses) o archivar [M]
- [ ] Definir archivar con nota pública (M100) [S]
- [ ] Definir reporte mensual de contenido procesado [S]

## 11. Crear parches (11º)

- [ ] Definir hotfix P0/P1 < 72 h (M142/M143) [C]
- [ ] Definir patch mensual con balance/mejoras [M]
- [ ] Definir changelog público en cada parche [M]
- [ ] Definir pipeline de parche = M117 (gates) [M]
- [ ] Definir regresión completa por patch (M112) [M]
- [ ] Definir rollback plan por parche (M107/M117) [M]
- [ ] Definir prueba de actualización de parche (M116) [M]
- [ ] Definir hotfix sin features (solo fixes) [S]
- [ ] Definir compatibilidad de saves entre parches (M59) [M]

## 12. Crear mejoras (12º)

- [ ] Definir backlog de mejoras con evidencia (M105/reviews) [M]
- [ ] Definir priorización semanal con datos [M]
- [ ] Definir impacto medible por mejora (target) [M]
- [ ] Definir mejoras de accesibilidad post-lanzamiento (M58) [M]
- [ ] Definir mejoras de localización según quejas (M87) [M]

## 13. Añadir contenido si corresponde (13º)

- [ ] Definir GATE de contenido nuevo (M120) [M]
- [ ] Definir evaluación mensual del GATE [M]
- [ ] Definir contenido-lite en parches (eventos M74, items M95) [M]
- [ ] Definir DLC/expansión con su propio plan si GATE pasa [C]
- [ ] Definir no contenido gratuito que canibalice V2 sin roadmap [S]
- [ ] Definir alineación con el roadmap público (M136) [M]

## 14. Mantener backups (14º)

- [ ] Definir backups de servicio (RPO 24 h) (M107) [M]
- [ ] Definir backup de bases de datos trimestrales [S]
- [ ] Definir restauración probada trimestral [S]
- [ ] Definir retención de backups 90 días [S]
- [ ] Definir respaldo de builds de lanzamiento (M143) [S]
- [ ] Definir disaster recovery plan post-lanzamiento [M]

## 15. Mantener soporte (15º)

- [ ] Definir SLA de primera respuesta ≤ 72 h (M121) [M]
- [ ] Definir base de conocimientos actualizada [M]
- [ ] Definir plantillas de respuestas (M126 legal) [M]
- [ ] Definir escalamiento de soporte a bugs P0/P1 [M]
- [ ] Definir canal de sugerencias oficial (M100) [S]
- [ ] Definir reporte mensual de tickets [S]

## 16. Mantener documentación (16º)

- [ ] Definir notas de parche público (Steam/web) [M]
- [ ] Definir wiki del juego actualizada (M100) [M]
- [ ] Definir FAQ viva por tema recurrente [M]
- [ ] Definir documentación interna de cambios (Logs/) [S]
- [ ] Definir plantilla única de changelog [S]
- [ ] Definir versionado de la documentación con cada parche [S]

## 17. Cadencias, responsables y cierre

- [ ] Definir tablero semanal de 9 métricas (M105) [C]
- [ ] Definir reunión semanal de 30 min de post-launch [S]
- [ ] Definir fases: D1-D7 / semanas 1-4 / meses 2-6 / trimestres [M]
- [ ] Definir roles: dev/CM/QA/DATA/OPS (M143) [M]
- [ ] Definir reporte mensual a M136 (roadmap) [M]
- [ ] Definir decisiones solo con evidencia (no intuición) [S]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [ ] Definir log del módulo en Logs/ [S]
- [ ] Definir feed del tablero al GATE de M120 [S]

## Totales

**Total de ítems:** 105
**Ítems resueltos por documentación:** 105 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)