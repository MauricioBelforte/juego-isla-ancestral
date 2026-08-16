# Log 20 — Renombrado de carpetas al estándar {ID-Módulo}-{Nombre}

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 17:40:00

## Descripción breve

Colisión de prefijos detectada: SWE-1.6 creó su primer módulo como `30-Bug-Tracking` (luego renombrado por él a `31-Bug-Tracking`) mientras Deepseek V4 Flash documentaba `30-Reloj-En-Tiempo-Real` y se preparaba para `31-Ciclo-Dia-Noche`. El usuario decidió **el estándar de carpetas `{ID-Módulo}-{Nombre}`** según el ID del módulo en `CHECKLIST-GLOBAL.md`.

## Cambios aplicados

| Antes | Después |
|---|---|
| `DOCUMENTACION/31-Bug-Tracking/` (untracked) | `DOCUMENTACION/102-Bug-Tracking/` (M102 = Bug Tracking) |
| README árbol: `31-Bug-Tracking/` | `102-Bug-Tracking/` + fila nueva en la tabla de componentes |
| CHECKLIST-GLOBAL fila 102: emoji corrupto `�` | `🟢` corregido (nota de Devin intacta) |
| `plan-inicial/01-Requerimientos.md` línea Carpeta | `DOCUMENTACION/102-Bug-Tracking/` |
| `plan-actual/01-Requerimientos.md` línea Carpeta | `DOCUMENTACION/102-Bug-Tracking/` |
| ESTADO-PARALELO.md | Norma de carpetas + zona de SWE-1.6 con rutas `{ID}-` |

## Descripción breve del bloqueo de SWE-1.6

SWE-1.6 completó el M102 (121/121) pero se trabó intentando editar `03-Diseno.md` tras el primer rename (`30-`→`31-`): su editor quedó apuntando a una ruta que dejó de existir. Desbloqueo: la ruta definitiva es `DOCUMENTACION/102-Bug-Tracking/` (ya renombrada y correcciones aplicadas). No debe recrear `30-`/`31-` ni mover la carpeta.

## Pendiente

- El prompt de desbloqueo para SWE-1.6 se entrega al usuario en la sesión.