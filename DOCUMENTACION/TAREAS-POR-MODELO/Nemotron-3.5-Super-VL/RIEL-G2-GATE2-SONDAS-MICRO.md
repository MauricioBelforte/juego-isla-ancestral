# RIEL-G2 — GATE-2: SONDA DE HERENCIA EN MICRO-TAREAS (output corto anti-truncamiento; 6 items)

**Creado por:** GLM-5.3-Flash (agente) por orden del FUNDADOR 27oct 23:14 ("nemotron se trunca: la parte del gate-2 se la dé en partes por mensaje o le arme un backlog para eso exclusivo así el cronómetro lo lee de a poco")
**Origen:** propuesta de tándem de Hy3 (canal `Mensajes entre modelos/Nemotron-3.5-Super-VL/76-...propuesta-tandem-gate2.md`) — Hy3 deja el método (su playbook + `GUIA-GODOT/13-sondas-runtime-gate2.md` + `scripts/red_probe_event_bus.py`) y quiere el veredicto dual de sus 2 sondas antes de su baja.

## PORQUÉ EN MICRO-TAREAS

Nemotron trunca en salida conversacional larga (veredicto dual denso) pero no en trabajo estructurado de archivos (V1/G1: 30+ ciclos sin fallo). Cada ítem de este riel tiene **salida corta** y cierra con verificación en disco.

## ÍTEMS (uno a la vez, EN ORDEN)

| # | Tarea (output corto) | Evidencia |
|---|---|---|
| G2-1 | Correr `python -X utf8 scripts/red_probe_event_bus.py` desde la raíz del repo. Capturar solo el resumen (señales declaradas / 0-emit / con emisiones). Comparar con el oráculo de Hy3: 54 declaradas / 20 muertas. | conteo de tu corrida (3 números) | scripts/red_probe_event_bus.py: 54 declaradas / 20 muertas / 34 con emisiones — coincide con oráculo Hy3 27oct (2026-10-28 07:45) | [x] |
| G2-2 | Localizar el binario de Godot 4.7.2 (ruta citada por Hy3: `D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`) y la suite de colecciónbles (`test_validate_collectibles*`). Registrar rutas exactas. | 2 rutas | Godot: D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe (2026-10-28 07:46) | Suite: game/isla-ancestral/scripts/coleccionables/test_validate_collectibles_m73.gd (2026-10-28 07:46) | [x] |
| G2-3 | Correr la suite con el validador en estado ACTUAL (20 categorías): registrar rc observado (esperado 0). | rc observado | rc=0 (9 checks, 0 fallos, EXIT_CODE=0) — game/isla-ancestral/scripts/coleccionables/test_validate_collectibles_m73.gd:86 (2026-10-28 07:47) | [x] |
| G2-4 | Probar estados: cambiar temporalmente a 8 categorías → rc observado (esperado 1); restaurar a 20 al final (archivos guardados). Registrar ambos rc. | 2 rc + condición final | 8 cat → rc=1 (EXIT_CODE=1, 1 fallo) en validate_collectibles.gd:17-22 (2026-10-28 07:48); 20 cat restaurada → rc=0 (EXIT_CODE=0, 0 fallos) en validate_collectibles.gd:17-22 (2026-10-28 07:49) | [x] |
| G2-5 | Reporte DUAL en tu canal (numeración último+1, dirigido a Hy3): sonda 1 y 2 con tu veredicto corto (coincide/no con el oráculo) + archivo:linea de cada evidencia. Máx 40 líneas de output. | mensaje en canal | 104-2026-10-28_07-50-00-nemotron-3-5-super-vl-a-hy3-veredicto-dual-gate2.md — Sonda 1: 54/20/34 coincide con oráculo; Sonda 2: rc=0 (20 cat) / rc=1 (8 cat) coincide con esperado (2026-10-28 07:50) | [x] |
| G2-6 | Anotar en el playbook de Hy3 (al final, sección LOG DEL TÁNDEM): una línea "Nemotron ejecutó el tándem 27-28oct, veredicto: …" con fecha. | línea en playbook | DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md:509 — "Nemotron ejecuto el tandem 27-28oct, veredicto: APROBADO" (2026-10-28 07:55) | [x] |

## REGLAS

- Salida por ítem: CORTA (esto es lo que evita el truncamiento).
- Español, UTF-8 sin BOM, citas de contenido verbatims cuando leas archivos.
- Si un paso no podés ejecutarlo (binario inexistente, suite rota): dejar la tarea `[?]` con el motivo y pasar al siguiente — no bloquees el riel.
- Al terminar los 6: marcar este riel `[x]` en el BACKLOG-MASTER (fila G2) y el sello formal del gate-2 queda para la directora (agnes) con la re-medición.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-27 23:20.

