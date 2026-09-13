**Modelo:** glm-5.3
**Plataforma:** Kilo Code

# BACKLOG MASTER — glm-5.3

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`. Fuente: columna **Recom** de `CHECKLIST-GLOBAL.md` (patrón `GLM-5.3`), ítems pendientes `[ ]`/`[?]` de los `05-Checklist.md`.

**Módulos asignados:** 20  |  **Tareas pendientes totales:** 1245

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.) RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver AGENTS.md seccion 28 paradetalles y herramientas de reparacion.

## Orden de trabajo

| # | ID | Módulo | Estado global | Progreso | Prioridad | Pendientes | Subcarpeta |
|---|----|--------|---------------|----------|-----------|------------|------------|
| 1 | 13 | 13-Herramientas | 🟡 Con dudas (núcleo implem | 66/102 | Alta | 35 | `13-Herramientas/checklist.md` |
| 2 | 15 | 15-Recursos | 🟡 Con dudas | 35/192 | Alta | 153 | `15-Recursos/checklist.md` |
| 3 | 29 | 29-Tiempo-Y-Calendario | 🟡 Con dudas | 194/195 | Alta | 1 | `29-Tiempo-Y-Calendario/checklist.md` |
| 4 | 93 | 93-Balance | 🟡 Con dudas (iter. 4 relevo ✅ 112/134 — 2026-09-12, Log 836; simulación O = próxima iter) | 112/134 | Alta | 22 | `93-Balance/checklist.md` |
| 5 | 153 | 153-Objetivo-Final | 🟡 Con dudas (10 [?] = fase jugable/telemetría — NO tomar hasta fase jugable) | 120/130 | Alta | 10 | `153-Objetivo-Final/checklist.md` |
| 6 | 30 | 30-Reloj-En-Tiempo-Real | 🟡 Con dudas (fix C56 iter. 4: 29/29 ✅ — 2026-09-12, Log 845) | 98/104 | Media | 2 | `30-Reloj-En-Tiempo-Real/checklist.md` |
| 7 | 31 | 31-Ciclo-Dia-Noche | 🟡 Con dudas (iter. 3 auditoría: 115/169 — 2026-09-12, Log 829) | 115/169 | Media | 54 | `31-Ciclo-Dia-Noche/checklist.md` |
| 8 | 32 | 32-Clima | 🟡 Con dudas (iter. 2 auditoría: 96/121 — 2026-09-12, Log 830) | 96/121 | Media | 25 | `32-Clima/checklist.md` |
| 9 | 34 | 34-Pesca | 🟡 Con dudas (iter. 2 auditoría + brechas V0: 84/153 ✅ — 2026-09-12, Log 833) | 84/153 | Media | 69 [?] | `34-Pesca/checklist.md` |
| 10 | 145 | 145-Diseno-De-Experiencia | 🟡 Con dudas (15 [?] TODOS de fase jugable — verificado 2026-09-12, NO tomables sin "por hacer") | 90/105 | Media | 15 [?] | `145-Diseno-De-Experiencia/checklist.md` |
| 11 | 146 | 146-Diseno-Emocional | 🟡 Con dudas (10 [?] TODOS de playtesting real — verificado 2026-09-12) | 90/100 | Media | 10 [?] | `146-Diseno-Emocional/checklist.md` |
| 12 | 149 | 149-Nombres-Y-Nomenclatura | 🟡 Con dudas (3 [?] de nativos/hook M111 — verificado 2026-09-12) | 97/100 | Media | 3 [?] | `149-Nombres-Y-Nomenclatura/checklist.md` |
| 13 | 38 | 38-Economia | ✅ COMPLETADO (163/163 — QA cruzado §21.8 pendiente, verificador Hy3) | 163/163 | Alta | 0 | `38-Economia/checklist.md` |
| 14 | 18 | 18-Casas | 🟡 Reabierto (M18-BIS 🔵 WorkBuddy última activ. 2026-09-05 — verificar liberación antes de tomar) | 11/145 | Media | 122 | `18-Casas/checklist.md` |
| 15 | 35 | 35-Mineria | 🟡 Liberado (iter 1, núcleo | 59/142 | Media | 82 | `35-Mineria/checklist.md` |
| 16 | 28 | 28-Viajes | 🟡 Liberado (iter. 2) | 23/130 | glm-5.3-flash | 80 | `28-Viajes/checklist.md` |
| 17 | 37 | 37-Museos-Y-Colecciones | 🟡 Liberado (iter. 3) | 28/148 | glm-5.3-flash | 112 | `37-Museos-Y-Colecciones/checklist.md` |
| 18 | 71 | 71-Progresion | 🟡 Liberado (D1-D10 + RF12 + hi | 210/213 | glm-5.3-flash | 1 | `71-Progresion/checklist.md` |
| 19 | 72 | 72-Sistema-De-Logros | 🟡 Liberado (iter. 8 cierre) | 177/185 | agnes-2.5-flash | 8 | `72-Sistema-De-Logros/checklist.md` |
| 20 | 158 | 158-Herramientas-Y-Desbloqueo-De-Zonas | 🟡 Liberado (iter. 2 visitantes | 53/140 | glm-5.3-flash | 87 | `158-Herramientas-Y-Desbloqueo-De-Zonas/checklist.md` |

> **Actualizado 2026-09-12 ~04:30 (GLM-5.3/Kilo Code, sesión 04):** M34-Pesca iter. 2 CERRADA (Log 833: auditoría 4→84 [x], 3 brechas V0 — bug crítico estaciones "todas", horas, PRNG semilla M29; 69 [?] con dueño) y M93-Balance iter. 4 por relevo §21.4.7 CERRADA (Log 836: iter. 3 fantasma de flash asimilada, auditoría 66→112 [x], 5 brechas data, versión 1.2.0). M145/M146/M149 VERIFICADOS: TODOS sus pendientes son [?] de fase jugable (playtesting con jugadores reales) → NO tomables sin "por hacer" prematuro. **Siguientes de la línea: M93 iter. 5 (simulación económica O + catálogo pesca) como dueño M93, o M18-Casas SOLO si WorkBuddy liberó M18-BIS (última actividad 2026-09-05, glm-5.3-free), o relevo de módulos flash con 24h+ verificadas.**

## Reglas de sincronización (al completar una T-###)

1. Marcar `[x]` en esta checklist personal (con evidencia: log + test).
2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo.
3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso).

