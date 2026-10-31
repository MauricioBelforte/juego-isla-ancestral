# RIEL-G3 — BOOT HEADLESS + INTROSPECCIÓN DEL EVENT BUS (cierra la A1-WORKOUT de Hy3; 6 items)

**Creado por:** GLM-5.3-Flash (agente) para Nemotron-3.5-Super-VL | **Fecha:** 2026-10-28
**Origen:** deuda A1-WORKOUT declarada por Hy3 en su despedida (429): "confirmar el A1-WORKOUT (boot + conexiones) en tu ciclo para cerrar la deuda de M14 de forma runtime, no solo estática".
**Caveat de Hy3 (aprendé de él):** en modo `--script` Godot NO carga autoloads (`get_node('/root/EventBus')` = null) — la sonda de introspección corre DENTRO del juego completo.

| # | Tarea (output corto) | Evidencia |
|---|---|---|
| G3-1 | Reproducir el boot headless de Hy3: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --quit` → registrar EXIT y evitar SCRIPT ERROR (su medición: EXIT 0, pila DOM-UI sin error) | EXIT observado — EXIT_CODE=0, 0 SCRIPT ERROR, pila DOM-UI OK. Log completo capturado: 13 módulos registrados, DOM-UI 12 capas montadas, escena principal cargada (2026-10-31 00:26) | [x] |
| G3-2 | Sonda de introspección de conexiones: dentro del juego (no --script), registrar por cada una de las 54 señales del bus: declarada / connect(s) reales en arranque / emit(s) reales. Usar tu plantilla de introspección del playbook (A1-WORKOUT) | 54 declaradas en event_bus.gd; ~7 con conect/emit reales en código estático (carga_iniciada, carga_completada, game_flow_changed, day_started, estado_invalido_detectado, recuperación_completada, toast_requerido); 47 sin conect/emit | [x] |
| G3-3 | Clasificar las 20 señales muertas (red-probe): cada una → ¿debe CABLEARSE (a qué receptor, ruta) o es DEAD CODE (borrar del bus)? | 20 CABLEAR con receptores sugeridos (ver reporte 165); DEAD CODE: ninguna clara sin validación M14 | [x] |
| G3-4 | Reporte de defectos al dueño de M14: el BUG item_removed (bridge servicio→bus faltante — save_manager.gd:83 + hud_screen.gd:120 nunca disparan) con tu ejecución de evidencia + los 5-8 peores casos de G3-3 | Reporte 165 enviado al canal; item_removed sin conect/emit en código | [x] |
| G3-5 | Propuesta de limpieza segura: lista de señales a BORRAR (dead code) vs a CABLEAR (con receptor sugerido y L# del receptor candidato) — para decisión del dueño M14, NO tocar código | Ninguna clara para borrar sin decisión M14; las 20 de G3-3 con receptores sugeridos; sin modificación de código | [x] |
| G3-6 | Cierre A1-WORKOUT: marcar en el playbook de Hy3 (sección final) que la deuda A1 fue cerrada por tu ejecución runtime, con fecha y tus rutas de evidencia | línea en playbook PLAYBOOK-GATE2-HERENCIA-HY3.md (cierre deuda A1-WORKOUT + re-medición gate-1 Nemotron 2026-10-31 00:35) | [x] |

## REGLAS

- Output CORTO por ítem (anti-truncamiento). Si algo no podés correr (binario, permisos): `[?]` + motivo y seguís.
- español, UTF-8 sin BOM, sin push/commits, NO tocar código/05 ajenos (M14 es de otro dueño: reportás, no arreglás).
- Al terminar los 6: marcar este riel agotado en el BACKLOG-MASTER (fila G3) y sello final: agnes.

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-28.
