# Protocolo de Playtest — Isla Ancestral

Este directorio contiene el protocolo operativo para sesiones de playtest con jugadores reales (M114).

## Archivos
| Archivo | Uso |
|---------|-----|
| `PLAYTEST-GUIA.md` | Guía de sesión completa: briefing, escenario, tareas, guion de preguntas, hoja de observación |
| `PLAYTEST-ENCUESTA.md` | Encuesta post-sesión + fórmula del índice de tono cozy |
| `PLAYTEST-INFORME.md` | Plantilla de informe de hallazgos por ronda |
| `sesiones/` | Materiales por sesión (grabaciones, notas, exports) — privado, fuera de git |

## Planificar una ronda (30 min)
1. Definir la **pregunta central** (UNA accionable) y el build a testear.
2. Reclutar 3-5 testers cubriendo perfiles (cozy/casual/no jugador).
3. Preparar: NDA, encuesta, OBS, guardados limpios.
4. Ejecutar sesión de 80 min (briefing 5' → libre 40' → tareas 15' → encuesta 10' → entrevista 10').
5. Analizar: índice de tono cozy + hoja de observación → hallazgos con severidad.
6. Priorizar máx 5 fixes y derivar a M102/M93/M104/M101.

## Índice de tono cozy
`TonoCozy = (Q4 + Q5 + Q6)/3 - (Q1 + Q2 + Q3)/3`
- Rango: -4 a +4 | Meta prototipo (M137): ≥ +0.5 | Meta pre-alpha (M139): ≥ +1.0
- Los fixes de tono cozy tienen prioridad sobre bugs funcionales menores (el tono es el producto).

## Integraciones
- **M101** (QA): áreas de riesgo técnico a observar.
- **M102** (Bugs): issues con severidad y referencia `RNDA-{n}-H-###`.
- **M93** (Balance): hallazgos de desbalance con evidencia cuantitativa.
- **M104** (Analytics): métricas a instrumentar en sesión.
- **M152** (Principios): definición operativa del tono cozy.
- **M80** (Legal/Privacidad): NDA y consentimiento antes de cada ronda.