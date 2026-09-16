**Modelo:** agnes-3-flash (Agnes 3.0 Flash, Sapiens AI)
**Plataforma:** Kilo Code

**Módulo (QA-asistencia, sin reclamar):** 49-Iluminacion (49)

# Nota personal — QA visual V2-asistencia M49 (visión nativa)

> **Log 939 (2026-09-16).** No reclamo M49 (41/143, verificado por mimo-v2.5); es una **QA-asistencia con
> visión**. La aprobación estética final es del usuario (M154).

## Lo que vi (visión) en las capturas del MCP godot (`capturas/49*`)
- **`franja_1200_final` (mediodía 12:01, FPS 60):** terreno voxel bien iluminado, luz pareja, cielo claro,
  HUD completo. Sanos.
- **`franja_0000_final` (noche 00:01, FPS 60):** muy oscura, terreno casi negro. **Confirmado por el usuario
  (2026-09-16) como diseño:** la noche se espera oscura **para que funcionen las antorchas**. No es bug; la
  jugabilidad nocturna depende del sistema de antorchas/luz.
- **`atardecer_1800` (FPS 59):** luz cálida sobre voxel, cielo azul→cálido. Color grading de atardecer correcto.
- **`skyline_montanas_v1` (FPS 60):** playa + mar + colinas/impostor + personaje. Coherente con iter. 5/6
  (skyline falso → relieves reales + impostor).
- **Global:** ciclo día→noche correcto; **FPS ~60** en las 4 franjas; **sin artefactos visuales**
  (overdraw/z-fight/poping/banding) en estas capturas.

## Estado
- [x] T-V2 QA visual M49 V2-asistencia (Log 939) — nota §QA visual agregada a `05-Checklist.md` M49 + flag:
  noche-oscura = diseño (antorchas).
- [ ] Pendientes V3 (M46 Arte-2D) / V4 (M167 Isla-Raiz) — siguen en la "Cola visual" del BACKLOG.

## Observación §28
Las líneas 241/249/256 de `05-Checklist.md` M49 traen mojibake preexistente ajeno (`mdh`, `§3.2igured`,
`dokumento`) — quedó anotado para `scripts/fix_encoding.py`, **no lo toqué**.
