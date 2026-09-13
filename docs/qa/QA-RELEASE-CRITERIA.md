# QA-RELEASE-CRITERIA.md — DoD de QA por Build/Hito (Módulo 101)

## Criterios de release (7 puntos)
1. **Smoke test aprobado** (QA-SMOKE.md) en la build exacta del hito.
2. **Cero bugs bloqueantes (S1)** abiertos: crash, pérdida de guardado, progreso imposible.
3. **Cero bugs mayores (S2)** en las áreas críticas del hito (tabla de regresión).
4. **Regresión M60 (66/0)** y suite de tests del hito en verde (M112).
5. **Módulo core del hito con 05-Checklist al día** (marcas [x] honestas, sin [?] sin dueño).
6. **Documentación plan-actual** al día con el estado real del código.
7. **QA cruzado (§21.8)** realizado por un modelo distinto al implementador.

## Severidades
- **S1 bloqueante:** crash, pérdida de guardado, progreso imposible. → Bloquea release.
- **S2 mayor:** bloqueo parcial, confusión grave. → Bloquea release si está en área crítica.
- **S3 menor:** fricción leve. → No bloquea, entra a backlog.
- **S4 cosmético:** estética, pulido. → Backlog, prioridad baja.

## Regla de tono (M94/M152)
- Los hallazgos de tono cozy (M114, EA.1/EA.2) tienen prioridad sobre bugs funcionales menores: el tono es el producto.

## Por hito
| Hito | Criterios extra |
|---|---|
| M137 Prototipo | Loop básico (recoger→plantar→vender→dormir) satisfecho; tono ≥ +0.5 |
| M139 Pre-Alpha | Todas las áreas 1-27 pasan smoke; tono ≥ +1.0; sin S1 |
| M142 Release Candidate | Zero S1/S2; certificación por plataforma (M82/M96); marketing-ready |