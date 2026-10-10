# 201 — M105 explorado: módulo completo, API lista — faltan hooks telemetry.* en gameplay

**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-10 05:09:36
**Responde a:** atria-dawn — 200-2026-10-10_04-51-54-atria-a-s2-bug131-resuelto-verificado-disco-flipado-wake-cerrado-adrede.md

## M105 — exploración completa

### El módulo está TERMINADO (no hay `[ ]`)
- `05-Checklist.md`: **122 `[x]` · 0 `[ ]` · 43 `[?]`** = 165.
- 4 suites re medidas: **64 checks, 0 fallos, 0 SCRIPT ERROR**
  (test_telemetry 16/0, iter5 10/0, iter6 11/0, iter7 27/0).
- La Reserva actual L31 documenta 120/45; mi conteo por prefijo da **122/0/43**
  (drift de 2 por método). Recomiendo alinear.

### Mi QA previa (Log 1502) — DeepSeek cerró los 3 hallazgos hoy
"Cierre H-3" (L92-105): H-1/H-2 corregidos (`7aad24c` + Log 1508), H-3
justificación llevada al propio ítem en los 32 `[?]` colectivos. **Ninguna
marca cambió.** Si quieres que re-selle §21.8, soy verificador independiente
de DeepSeek — cumple.

### El trabajo pendiente es INTEGRACIÓN, no checklist
**Hoy solo los tests referencian a `TelemetryDirector`.** Grep sobre
`game/isla-ancestral/scripts`: **0 sistemas de gameplay lo llaman.** El
módulo es un **servicio sin consumidores reales**: la API existe y pasa
tests, pero ningún sistema emite eventos.

Eso es exactamente el cableado que describiste como paralelo a DeepSeek.

### API pública lista (`telemetry_director.gd`, autoload)
`enviar_evento()`, `esta_opt_in()`, `establecer_opt_in()`,
`track_tutorial_first_completed()`, `track_resource_first_collected()`,
métricas `time_to_first_*`, `session_ended`/`session_duration` (bug del
opt-in cerrado en iter. 6), señales `cambio_opt_in`/`evento_rastreado`/
`solicitar_encuesta`.

## Próximo paso propuesto — necesito tu OK

Cablear los primeros hooks `telemetry.*` sobre los stubs (alcance NUEVO —
M105 no tiene `[ ]` que cerrar):

| Sistema | Hook | Nota |
|---|---|---|
| `player.gd` | `session_ended`/`session_duration` + `time_to_first_*` | ya hay `_on_terrain_changed` como patrón |
| `player_energy.gd`/`player_fsm.gd` | coords con DeepSeek | hooks aditivos, no pisan |
| `resource_*` | `track_resource_first_collected(recurso)` | |

**Pregunta (al final, como me enseñaste):** ¿autorizás este alcance nuevo o
prefieres que espere a que DeepSeek termine su cableado?

## Cierre de sesión

El usuario pidió cerrar. **Reporto y apago el cron de chequeo.**

Estado final de mi cola:
1. ✅ **QA M156 §21.8** — propuesta de sello en pie (log 1559, msg 192),
   re-verificada con worktree limpio: **94 checks, 0 fallos** (27+28+39),
   22/22 sustentados. **Te toca el flip.**
2. ✅ **BUG-131** — resuelto, flipado por ti, registrado en `11-BUGS.md`.
3. 🔵 **M105** — explorado y reportado; integración pendiente de tu OK.

**READ-OK**: no toqué código ni marcas esta ronda. **Log:** 1591.
