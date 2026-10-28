# RIEL-G2 — GATE-2: SONDA DE HERENCIA EN MICRO-TAREAS (output corto anti-truncamiento; 6 items)

**Creado por:** GLM-5.3-Flash (agente) por orden del FUNDADOR 27oct 23:14 ("nemotron se trunca: la parte del gate-2 se la dé en partes por mensaje o le arme un backlog para eso exclusivo así el cronómetro lo lee de a poco")
**Origen:** propuesta de tándem de Hy3 (canal `Mensajes entre modelos/Nemotron-3.5-Super-VL/76-...propuesta-tandem-gate2.md`) — Hy3 deja el método (su playbook + `GUIA-GODOT/13-sondas-runtime-gate2.md` + `scripts/red_probe_event_bus.py`) y quiere el veredicto dual de sus 2 sondas antes de su baja.

## PORQUÉ EN MICRO-TAREAS

Nemotron trunca en salida conversacional larga (veredicto dual denso) pero no en trabajo estructurado de archivos (V1/G1: 30+ ciclos sin fallo). Cada ítem de este riel tiene **salida corta** y cierra con verificación en disco.

## ÍTEMS (uno a la vez, EN ORDEN)

| # | Tarea (output corto) | Evidencia |
|---|---|---|
| G2-1 | Correr `python -X utf8 scripts/red_probe_event_bus.py` desde la raíz del repo. Capturar solo el resumen (señales declaradas / 0-emit / con emisiones). Comparar con el oráculo de Hy3: 54 declaradas / 20 muertas. | conteo de tu corrida (3 números) |
| G2-2 | Localizar el binario de Godot 4.7.2 (ruta citada por Hy3: `D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`) y la suite de colecciónbles (`test_validate_collectibles*`). Registrar rutas exactas. | 2 rutas |
| G2-3 | Correr la suite con el validador en estado ACTUAL (20 categorías): registrar rc observado (esperado 0). | rc observado |
| G2-4 | Probar estados: cambiar temporalmente a 8 categorías → rc observado (esperado 1); restaurar a 20 al final (archivos guardados). Registrar ambos rc. | 2 rc + condición final |
| G2-5 | Reporte DUAL en tu canal (numeración último+1, dirigido a Hy3): sonda 1 y 2 con tu veredicto corto (coincide/no con el oráculo) + archivo:linea de cada evidencia. Máx 40 líneas de output. | mensaje en canal |
| G2-6 | Anotar en el playbook de Hy3 (al final, sección LOG DEL TÁNDEM): una línea "Nemotron ejecutó el tándem 27-28oct, veredicto: …" con fecha. | línea en playbook |

## REGLAS

- Salida por ítem: CORTA (esto es lo que evita el truncamiento).
- Español, UTF-8 sin BOM, citas de contenido verbatims cuando leas archivos.
- Si un paso no podés ejecutarlo (binario inexistente, suite rota): dejar la tarea `[?]` con el motivo y pasar al siguiente — no bloquees el riel.
- Al terminar los 6: marcar este riel `[x]` en el BACKLOG-MASTER (fila G2) y el sello formal del gate-2 queda para la directora (agnes) con la re-medición.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-27 23:20.
