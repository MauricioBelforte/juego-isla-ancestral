# QA-SESSION.md — Plantilla de Sesión de QA (Módulo 101)

**Sesión QA #XX — Hito M137 (Prototipo) / M139 (Pre-Alpha)**
**Fecha:** YYYY-MM-DD HH:MM
**Build:** commit abc1234 — 0.1.0-dev
**Tester:** [modelo] / [plataforma]
**Semilla del mundo (M10):** 42
**Versión Godot:** 4.x
**Áreas cubiertas:** 1 (Mundo voxel), 3 (Jugador), 5 (Herramientas), 6 (Inventario)
**Smoke test (QA-SMOKE.md):** Aprobado / No aplica

## Resultados por ítem
| ID | Área | Resultado | Bug (issue M102) | Notas |
|----|------|-----------|------------------|-------|
| 1.01 | Mundo | [x] | — | Generación sin errores en consola |
| 3.02 | Jugador | [x] | — | Movimiento fluido; sin atascos |
| 5.01 | Herramientas | [ ] | #12 (Alta) | Pico no extrae roca en altura Y>100 |
| 6.03 | Inventario | [x] | — | Separación de stacks OK |
| 10.01 | Guardado | [x] | — | Guardado manual sin errores |

## Bugs encontrados
| Issue | Severidad | Categoría | Reproducible | Estado |
|-------|-----------|-----------|--------------|--------|
| #12 | Alta | Herramientas | Sí (2/2 intentos) | Abierto |

## Conclusión
- DoD de QA del hito: CUMPLE / NO CUMPLE
- Bloqueos para el siguiente hito: [fix de #12 y re-sesión del área 5]
- Métricas: [N] áreas cubiertas, [N] bugs reportados, [N] regresiones convertidas a M112
- Reglas EA.1/EA.2 (M114): hallazgos de tono con prioridad sobre bugs funcionales menores