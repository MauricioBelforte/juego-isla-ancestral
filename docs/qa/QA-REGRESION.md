# QA-REGRESION.md — Guía de Regresión por Dependencias (Módulo 101)

## Cuándo correr regresión
- Cada vez que se modifica un módulo con dependencias activas.
- Antes de marcar un hito como listo (M137/M139).
- Al integrar un sistema nuevo que toca contratos existentes (M59, M60, ServiceRegistry).

## Cómo convertir hallazgos a M112 (testing automático)
1. Identificar el ítem que falló en la regresión.
2. Crear un test headless en `scripts/<modulo>/test_*.gd` (patrón SceneTree).
3. Ejecutar con: `Godot --headless --path game/isla-ancestral --script res://scripts/<modulo>/test_*.gd`
4. Registrar el test en el runner de M112 con su criterio de éxito.
5. Documentar en el 05-Checklist del módulo.

## Áreas críticas de regresión (por dependencia)
| Módulo modificado | Áreas QA a re-testear | Prioridad |
|---|---|---|
| M59/M60 (guardado/datos) | 6 Inventario, 10 Guardado, 22 Progresión | Alta |
| M40 (infraestructura) | 1 Mundo, 15 UI/UX, 20 Rendimiento | Alta |
| M61/M62/M63 (rendimiento/memoria/streaming) | 1 Mundo, 20 Rendimiento | Media |
| M41-44 (audio) | 12 Música, 13 Ambiente, 14 Efectos | Baja |
| M57/M58 (control/config) | 18 Control, 19 Config | Media |
| M32 (clima) | 24 Clima, 25 Calendario | Baja |
| M08/M09/M10 (voxel) | 1 Mundo, 9 Minería | Alta |

## Protocolo de regresión
1. Correr smoke test (QA-SMOKE.md).
2. Re-testear las áreas críticas de la tabla.
3. Documentar cada hallazgo con: área, ítem, severidad, reproducción.
4. Los bugs → issue M102. Los tests → M112. Los hallazgos de tono → M114 (EA.1/EA.2).