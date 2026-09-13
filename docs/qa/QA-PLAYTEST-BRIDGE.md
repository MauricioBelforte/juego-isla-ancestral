# QA-PLAYTEST-BRIDGE.md — Coordinación QA ↔ Playtesting (M101 ↔ M114)

## Objetivo
Puente entre el QA interno (M101) y el playtesting con jugadores reales (M114). Evita duplicar esfuerzos y asegura que los hallazgos fluyan a los sistemas correctos.

## Reglas de puente (EA.1 / EA.2)
- **EA.1:** Los hallazgos de tono cozy detectados en QA se reportan a M114 con la misma severidad de tono (-5..+1) usada en playtesting.
- **EA.2:** Los hallazgos funcionales detectados en playtesting se reportan a M102 (bugs) con severidad S1-S4.

## Flujo de hallazgos
1. **QA interno (M101):** detecta bug → issue M102. Detecta problema de tono → informe a M114.
2. **Playtesting (M114):** detecta fricción de tono → informe con índice de tono cozy. Detecta bug funcional → issue M102.
3. **Ambos:** los hallazgos de balance → M93. Los hallazgos de UX → M53/M89.

## Prioridad conjunta
| Hallazgo | Prioridad | Canal |
|---|---|---|
| Bug S1 (crash, pérdida de save) | Crítica | M102 inmediato |
| Bug S2 (bloqueo parcial) | Alta | M102 |
| Problema de tono (impacto -3..-5) | Alta | M114 + M94/M152 |
| Fricción leve (tono -1..-2) | Media | M114 backlog |
| Bug S3/S4 | Baja | M102 backlog |

## Sesión conjunta (opcional)
Cuando el build lo permita, una sesión de QA + playtest simultánea:
- QA cubre áreas funcionales (checklist).
- Playtest cubre experiencia (sesión guiada M114).
- Al final, se consolidan hallazgos en un solo informe (QA-SESSION + PLAYTEST-INFORME).