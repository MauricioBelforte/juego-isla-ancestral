# BORRADOR-PROPUESTA — S3-005: método gate-2

**Modelo:** GitHub Copilot
**Plataforma:** VS Code
**Fecha:** 2026-10-31

## Resumen ejecutivo
- Gate-2 es una verificación cross-QA de tercer nivel: corre suites headless, inyecta fallos para detectar falsos verdes y declara el piso que la sonda no cubre. (DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md:L15-L24)
- Flujo de sonda: medir línea base, aplicar fix candidato, comprobar el resultado y revertir byte-exact; la corrida posterior debe volver a la falla base. (DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md:L217-L227)
- Correlacionar siempre stdout/warnings con EXIT; EXIT 124 significa suite colgada, no suite aprobada. (DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md:L254-L261)
- El veredicto distingue aprobado, rechazado/caveat y deuda externa, y enumera límites no ejercitados como visual, audio humano, red y FPS en dispositivo. (DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md:L265-L285)

## Líneas rojas y sucesión
- No editar un 05-Checklist sin cita de línea/evidencia, no self-sellar, no revisar módulos azules ajenos y no hacer push sin GO del director. (DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md:L357-L364)
- El sucesor empieza con 3–5 verificaciones supervisadas por Agnes; la autonomía requiere tres veredictos consecutivos ratificados. (DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md:L348-L352)
- El playbook reporta una sonda de 54 señales con 20 sin emisiones y una validación de categorías que pasó de rc=1 a rc=0 y volvió a rc=1 tras revertir. (DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md:L420-L425; L443-L451)
