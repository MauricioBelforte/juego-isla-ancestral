**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 142: Release Candidate

## 1. Problema
Beta (M141) entregó una build estable con contenido 100%, cero bugs P0/P1 y materiales comerciales aprobados. El RC convierte esa build en **la build de lanzamiento**: congelada (features, contenido, solo correcciones críticas), limpia (build/instalación/actualización), con saves/cloud/logros verificados, rendimiento y crash rate medidos, certificación y legal cerradas, y el **plan de lanzamiento** ejecutable listo.

## 2. Objetivo del módulo
Producir y validar el **Release Candidate final**: la build exacta que se publica el día de lanzamiento (M143), garantizando que nada del pipeline de certificación, legal, marketing o soporte pueda frenar el release.

## 3. Alcance (derivado del plan maestro: sección 141 "RELEASE CANDIDATE")
1. **Freeze de features** — cero features nuevas desde el cierre de Beta.
2. **Freeze de contenido** — el inventario de Beta queda inamovible (manifest).
3. **Solo correcciones críticas** — hotfixes P0/P1 que bloquean la certificación o el lanzamiento.
4. **Build limpia** — build final de producción sin contenido de dev, sin asserts, con símbolos mínimos.
5. **Instalación limpia** — instalación desde cero verificada en las plataformas objetivo.
6. **Actualización funcional** — migración desde builds Beta (y previas) sin pérdidas.
7. **Saves compatibles** — los saves Beta y RC comparten versión; migración v3.x verificada.
8. **Cloud saves** — sincronización cloud estable con conflicto resuelto (M60).
9. **Logros** — todos los logros desbloqueables y registrados (M59).
10. **Idiomas** — 6 idiomas verificados en la build final (M87).
11. **Rendimiento** — presupuestos M61-M63 medidos en build final.
12. **Crash rate** — crash rate aceptable (objetivo < 0.5% de sesiones) con monitorización.
13. **Certificación** — checklist de plataforma aprobado (M149).
14. **Legal** — términos, política de privacidad, atribuciones, clasificación etaria (M149).
15. **Marketing** — store page, tráiler, comunicado de lanzamiento listos (M149).
16. **Soporte** — canales, FAQ, acumulación de reportes activos (M152).
17. **Plan de lanzamiento** — cronograma día 0, personas, responsables, runbook día del lanzamiento.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Freeze firme: features y contenido congelados; solo hotfixes críticos autorizados por comité de release |
| RF2 | Build final limpia: sin logs de dev, sin debug, con crash handler y telemetría (M104/M105) |
| RF3 | Instalación limpia y actualización funcional verificadas en todas las plataformas |
| RF4 | Saves compatibles: Beta→RC sin pérdida; migración de saves v3.x sin datos rotos |
| RF5 | Cloud saves funcionando con resolución de conflictos y validación de integridad |
| RF6 | Logros alcanzables y persistentes en las 6 plataformas objetivo |
| RF7 | Los 6 idiomas (M87) verificados en la build RC |
| RF8 | Rendimiento dentro de presupuesto (M61-M63) en hardware mínimo y recomendado |
| RF9 | Crash rate < 0.5% sesiones en pilotaje; handler de crashes sube stacktraces |
| RF10 | Certificación aprobada por cada plataforma objetivo (M149) |
| RF11 | Legal completo: términos, privacidad, atribuciones, clasificación etaria aprobados |
| RF12 | Marketing listo: store publicado-ready, tráiler, comunicado, kits de prensa |
| RF13 | Soporte activo: canales, FAQ, proceso de reportes, tiempo de respuesta definido |
| RF14 | Plan de lanzamiento aprobado con runbook día 0 y responsables |

## 5. Criterios de aceptación (DoD del módulo)
1. Build RC publicada como `release-candidate-1` (build ID) y congelada; cualquier cambio requiere hotfix con revisión.
2. Instalaciones limpias y actualizaciones verificadas en 100% de plataformas objetivo.
3. Saves Beta→RC verificados; cloud sin pérdida en 30 ciclos de sincronización.
4. Logros 100% desbloqueables (matriz de hitos) sin dependencia de red.
5. Rendimiento en presupuesto y crash rate < 0.5% en 1000 sesiones de pilotaje.
6. Certificación y legal aprobados por escrito/checklist firmado.
7. Marketing y soporte operativos 1 semana antes del día 0.
8. Plan de lanzamiento (M143) aprobado y runbook completo.
9. Documentación plan-actual actualizada (142-Release-Candidate) firmada.

## 6. Restricciones
- **Aplican:** M61-M63 (rendimiento), M59/M60 (logros/cloud), M87 (idiomas), M101/M102 (bugs), M112 (tests), M149 (plataforma/legal/marketing), M152 (soporte/UX), M104/M105 (telemetría/crash), M147 (biblia canon).
- La política es **no-touch** al código salvo hotfix P0/P1 aprobado; todo hotfix exige test de regresión (M112).
- El RC es una única build por plataforma; si un hotfix la invalida, se re-etiqueta como `rc-2` y se revalida el checklist completo.

## 7. Dependencias
- M141 (Beta ✅): build estable, cero P0/P1, materiales de comercial.
- M149 (Plataformas/Marketing), M152 (Manual/UX), M59/M60 (Saves/Cloud), M87 (Localización), M93 (Balance final), M101/M102 (QA/Tracking), M104/M105 (Telemetría), M112 (Tests), M147 (Biblia).
- M143 (Lanzamiento): recibe el RC aprobado y publica.

## 8. Entregables del módulo
1. Build RC por plataforma (etiquetada y hashada).
2. Checklist de validación RC firmado (17 frentes).
3. Informe de certificación y legal aprobado.
4. Runbook y plan de lanzamiento aprobados (para M143).
5. Backlog de soporte inicial (FAQ + procesos).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M141** — Beta | RC sobre beta |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M120** — DLC y Expansiones | Usado por dlc y expansiones |
| **M121** — Soporte Post-Lanzamiento | Usado por soporte post-lanzamiento |
| **M129** — Merchandising | Usado por merchandising |
| **M131** — Créditos | Usado por créditos |
| **M143** — Lanzamiento | Lanzamiento |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M120** — DLC y Expansiones | Este módulo lo necesita |
| **M121** — Soporte Post-Lanzamiento | Este módulo lo necesita |
| **M129** — Merchandising | Este módulo lo necesita |
| **M131** — Créditos | Este módulo lo necesita |
| **M141** — Beta | Depende de este módulo |
| **M143** — Lanzamiento | Este módulo lo necesita |

