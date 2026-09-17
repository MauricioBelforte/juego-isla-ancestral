**Modelo:** glm-5.3-flash
**Plataforma:** Cline

# BACKLOG MASTER — glm-5.3-flash

> Backlog personal según `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`. Fuente: columna **Recom** de `CHECKLIST-GLOBAL.md` (patrón `GLM-5.3 Flash`), ítems pendientes `[ ]`/`[?]` de los `05-Checklist.md`.

**Módulos asignados:** 22  |  **Tareas pendientes totales:** 2009

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.) RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver AGENTS.md seccion 28 paradetalles y herramientas de reparacion.

## Orden de trabajo (v2 — curado 2026-09-15, glm-5.3-flash / Cline)

> **Curación v2:** conteos re-verificados contra los `05-Checklist.md` reales (regex `^- \[ \]` / `^- \[\?\]`) tras la auditoría global que revirtió varios módulos y el regenerado de CHECKLIST-GLOBAL (`generar_checklist_global.py`, con backup). **Resueltos y cerrados por otros agentes:** 32-Clima (0/0, auditoría agnes 13/09), 38-Economia (0/0), 93-Balance (134/134), 145 (0/0), 146 (0/0), 65-Animales-IA (0/0). **149-Nombres:** reservado por otro agente (checklist regenerado) — fuera de mi cola. **Conflictos:** 66-Anti-Softlock (Log 701 declara 117/117 pero el checklist real tiene 117 `[ ]` post-reversión) → tareas en `[→]` pendiente de reconciliación. **31/34/64:** re-clasificados a `[?]` con dueño por otros — no accionables ahora.

| # | ID | Módulo | Pendientes reales (05-Checklist) | Notas | Subcarpeta |
|---|----|--------|----------------------------------|-------|------------|
| 1 | 92 | 92-Tutorial | 83 (82 ab + 1 ?) | Alta · iter.3 lógica completa (Log 914, 90/185): interruptores/consejos/P2-P15/S5-S9 · falta UI M53 + guiones .tres + RF11-RF18 | `92-Tutorial/checklist.md` |
| 2 | 39 | 39-Tiendas | 100 | Media · núcleo datos | `39-Tiendas/checklist.md` |
| 3 | 158 | 158-Herramientas-Y-Desbloqueo-De-Zonas | 87 | 🟢 0→87 hecho por otro; núcleo a retomar | `158-Herramientas-Y-Desbloqueo-De-Zonas/checklist.md` |
| 4 | 19 | 19-NPC-Y-Vecinos | 83 | Alta · núcleo iter. 3 (Log 553) | `19-NPC-Y-Vecinos/checklist.md` |
| 5 | 25 | 25-Ruinas | 84 | Media · kit modular | `25-Ruinas/checklist.md` |
| 6 | 33 | 33-Agricultura | 86 | Media · núcleo + clima | `33-Agricultura/checklist.md` |
| 7 | 37 | 37-Museos-Y-Colecciones | 112 | 🟢 Media | `37-Museos-Y-Colecciones/checklist.md` |
| 8 | 28 | 28-Viajes | 80 | 🟢 Media · núcleo V0 (Log 371) | `28-Viajes/checklist.md` |
| 9 | 35 | 35-Mineria | 82 (69 ab + 13 ?) | Media · núcleo + QA | `35-Mineria/checklist.md` |
| 10 | 77 | 77-Online-Y-Red | 126 | 🟢 Media · sin núcleo aún | `77-Online-Y-Red/checklist.md` |
| 11 | 153 | 153-Objetivo-Final | ~130 (regenerado) | Alta · mis 10 tareas vuelven a estar abiertas | `153-Objetivo-Final/checklist.md` |
| — | 31 | 31-Ciclo-Dia-Noche | 54 `[?]` | no accionable ahora (dueños) | `31-Ciclo-Dia-Noche/checklist.md` |
| — | 34 | 34-Pesca | 69 `[?]` | no accionable ahora | `34-Pesca/checklist.md` |
| — | 64 | 64-IA-De-NPC | 49 `[?]` | no accionable ahora | `64-IA-De-NPC/checklist.md` |
| — | 66 | 66-Anti-Softlock | 7 `[?]` (87 `[x]`) | ✅ RECONCILIADO 2026-09-15 (Log 913): restauración verificada 110/117; los 7 `[ ]` restantes tienen dueño externo (M27/M64/M22/M26) | `66-Anti-Softlock/checklist.md` |

**Pendiente real accionable: ~860** (de 2.007 al inicio de la curación; baja 110 al reconciliar M66 y ~51 en la iter. 3 de M92). Resueltos/conflictos/no-accionables documentados arriba y en los checklists personales.

## Reglas de sincronización (al completar una T-###)

1. Marcar `[x]` en esta checklist personal (con evidencia: log + test).
2. Marcar el ítem correspondiente en el `05-Checklist.md` del módulo.
3. Actualizar la fila del módulo en `CHECKLIST-GLOBAL.md` (progreso).

