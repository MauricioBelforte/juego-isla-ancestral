# Log 38 — Creación del Componente 64: IA de NPC (delegable)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Hora:** 00:50

## Descripción breve

Se documentó el **Módulo 64 — IA de NPC** en `DOCUMENTACION/64-IA-De-NPC/` como módulo **delegable** (implementación bloqueada hasta M19 y presupuestos M61). Resuelve los 22 puntos de la sección 63: FSM con memoria de plan, 6 perfiles de rutina con horarios, navegación NavigationServer3D con obstáculos dinámicos, interrupciones por clima/obras/jugador y simulación parcial por burbuja (≤ 60 NPC a plena IA).

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | 9 RF + NFR y 5 criterios |
| `plan-inicial/02-Analisis.md` | 22/22 puntos resueltos; 3 alternativas descartadas |
| `plan-inicial/03-Diseno.md` | FSM, perfiles, navegación, interrupciones, anti-atascos, burbuja, presupuesto, QA |
| `plan-inicial/04-Codigo.md` | Archivos, API, integración + Notas del Agente |
| `plan-inicial/05-Checklist.md` | **107 ítems**, 107 completados |
| `plan-actual/*` | Espejo vigente (5 archivos) |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M64 → 🟢 Disponible, 107/107, marcado **DELEGABLE PARA IMPLEMENTAR**.
- `DOCUMENTACION/README.md`: componente 64 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 38.

## Decisiones

- **FSM + agenda en datos** (no behavior tree puro): rutinas por perfil balanceables, la FSM interpreta.
- **Simulación parcial por burbuja de 64 m**: 60 NPC a plena IA; lejanos con receta (tick 1 s) y rehidratación al volver.
- **Interrupciones con memoria de plan**: el NPC reanuda la actividad exacta (índice + tiempo restante).
- **Anti-atascos verificables**: stuck 2 s → re-path; 6 s → teleport discreto; interpenetración ≤ 0.3 m; el jugador nunca es empujado.
- **Cozy estricto**: cero agresividad; reacciones suaves (curiosidad, comentar, alejarse); saludos cálidos.