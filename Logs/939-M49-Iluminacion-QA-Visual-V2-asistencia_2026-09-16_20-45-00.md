# Log 939: M49 Iluminación — QA visual V2-asistencia (visión nativa)

**Fecha:** 2026-09-16
**Hora:** 20:45
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code

## Resumen

Segunda tarea **con visión** de **agnes-3-flash** (QA-asistencia de M49 Iluminación). El usuario confirmó
que el módulo "ya estaba bastante avanzado" (41/143, verificado item a item por mimo-v2.5) y pidió seguir con
la QA visual. Leí 4 capturas del MCP godot y validé el ciclo día/noche. **No reclamo M49**; dejé una nota de
QA-asistencia (aprobación estética final = usuario, M154).

## Lo que hice (con visión)
- **Leí 4 capturas** del MCP godot (`tools/mcp/godot-mcp/capturas/49/`):
  - `franja_1200_final` (mediodía 12:01, **FPS 60**): terreno voxel bien iluminado, luz pareja, cielo claro. Sanos.
  - `franja_0000_final` (noche 00:01, **FPS 60**): muy oscura, terreno casi negro.
  - `atardecer_1800` (**FPS 59**): luz cálida/anaranjada sobre el terreno, cielo azul→cálido.
  - `skyline_montanas_v1` (horizonte, **FPS 60**): playa + mar + colinas/impostor + personaje.
- **Hallazgo / aclaración del usuario:** la **noche oscura es DISEÑO** — "para eso van a estar las antorchas".
  No es un bug; la jugabilidad nocturna depende del sistema de **antorchas/luz del jugador** (pendiente).
- **Global:** ciclo día→atardecer→noche correcto; **FPS ~60 en las 4 franjas**; **sin artefactos visuales**
  (overdraw/z-fight/popin/banding) en estas capturas.

## Cambios / Archivos
- `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md` (nueva sección "QA visual V2-asistencia (agnes-3-flash)")
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/BACKLOG-MASTER.md` (V2 → done)
- `DOCUMENTACION/TAREAS-POR-MODELO/agnes-3-flash/49-Iluminacion-QA/checklist.md` (nota personal, nuevo)

## Observaciones honestas
- V2-**asistencia**: leo/describo y opino; **no apruebo estéticamente** (usuario, M154) y **no genero arte (V5)**.
- **§28:** detecté mojibake preexistente ajeno en las líneas 241/249/256 del 05-Checklist M49
  (`mdh`, `§3.2igured`, `dokumento`) — lo anoté para `scripts/fix_encoding.py` y **no lo toqué** (fuera de mi alcance).
- Flag a M49: si se agregan antorchas, re-verificar V2 que la luz nocturna sea legible (no queme).

## Estado
M49 no lo modifico (pertenece a otros); queda la QA-asistencia documentada. Siguiente en mi cola visual:
V3 (M46 Arte-2D) o V4 (M167 Isla-Raiz).
