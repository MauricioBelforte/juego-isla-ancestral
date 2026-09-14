# Log 826: M105-Telemetria-De-Gameplay iter 6 — Auditoría de 33 pendientes + fix de integración de `zone_ignored`

**Fecha:** 2026-09-11
**Hora:** 20:10
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Módulo:** M105-Telemetria-De-Gameplay
**Reserva:** `Logs/reservas/826-DeepSeek-V4.1-Flash-M105.txt`
**Entrada:** M104 (Analytics) ✅ completado 2026-08-29
**Visión:** V0 (módulo de infraestructura, sin recursos visuales)

## Resumen

Iteración 6 de M105. El módulo quedó `🔵 En curso` en iter. 5 (deepseek-v4-flash, Kilo Code, 2026-09-04) con **33 `[ ]`** en su checklist, todos de la fase de diseño del plan original (DEVIN) escritos como "Diseñar método/variable X". La auditoría contra el código real mostró que **la gran mayoría ya estaba implementada** con los nombres reales de la arquitectura (no los del plan DEVIN, que apuntaban a APIs inexistentes). Se cerraron **27 `[x]` con evidencia** y se dejaron **6 `[?]` honestos** con motivo y dueño. Además se encontró y arregló **un bug de integración real** en `zone_ignored`. Resultado: **157/163 `[x]` · 0 `[ ]` · 6 `[?]`** (antes 114/163). Tests: iter6 **11/11** (nuevo) · iter5 10/10 · test_telemetry 16/16.

**Relevo:** el módulo estaba reservado por `deepseek-v4-flash` con "Log reservado: 643" — número que **ya había sido consumido por M49** (`643-M49-FIX-Luz-Invertida-Sol-Invisible_2026-09-04_06-25-00.md`) → **reserva fantasma**; agente estancado 7 días y modelo descatalogado el 2026-09-10. Reclamado por §21.4.7, con justificación en la fila 105 de CHECKLIST-GLOBAL.

## Cambios Realizados

**Auditoría de marcado (27 `[x]` con evidencia de código):**
Los 33 ítems pendientes eran de la fase de diseño y ya estaban satisfechos. Equivalencias clave (nombre del plan → implementación real):

| Plan (DEVIN) | Implementación real |
|---|---|
| `start_session()` | `_iniciar_sesion()` |
| `end_session()` | `_finalizar_sesion()` |
| `set_opt_in(enabled)` | `establecer_opt_in(estado)` |
| `load_opt_in_status()` | `_cargar_opt_in()` |
| `save_opt_in_status()` | `_persistir_opt_in()` |
| `generate_session_id()` / `session_id` | **delegado a M104** por diseño (hash SHA256 rotativo 24 h) |
| `session_start_time` | `_inicio_sesion_ms` |
| `zone_enter_time` (Dictionary) | `_zona_entrada` |
| `zone_check_timer` (Timer) | `_zone_check_timer` |
| `setup_zone_detector()` | `_configurar_timers()` |
| umbral 5 min sin completar | `PUZZLE_ABANDONO_SEGUNDOS := 300.0` |
| umbral 1 min sin explorar | `ZONA_IGNORADA_SEGUNDOS := 60.0` |
| `enter_zone` / `exit_zone` / `_on_zone_check` | implementados con el mismo nombre |
| `cálculo de session_duration` | `_duracion_sesion_seg()` + métrica `session_duration` |
| `registro de zones_ignored` | `_evaluar_zona_ignorada()` + `EVT.ZONE_IGNORED` |
| privacidad (anonimización / sin PII / solo gameplay) | header "Privacy by design" + opt-in OFF por defecto |
| M105 no afecta progresión de M71 | sumidero de solo-escritura hacia M104 |

**Fix del bug de INTEGRACIÓN de `zone_ignored` (`telemetry_director.gd`):**
- **El bug:** el fix de iter. 5 introdujo la dedup `_zona_ignorada_reportada` y movió la emisión a `_on_zone_check`; pero `exit_zone()` **detiene `_zone_check_timer`** al salir de la última zona → en runtime `_on_zone_check` deja de correr y **`zone_ignored` NUNCA se emitía**. El test de iter. 5 no lo detectaba porque llamaba `_on_zone_check()` **a mano** (línea 77), saltándose el timer.
- **El fix:** se extrajo `_evaluar_zona_ignorada(zone_id)` con el cuerpo original intacto y se la invoca **también desde `exit_zone()`**, que es el punto natural de decisión (la zona se "ignoró" cuando el jugador se va).
- **Contrato preservado a propósito:** se limpia el acumulado **solo** al reportar; las zonas con acumulado ≥ umbral **permanecen** (esto está fijado por `test_telemetria_iter5` líneas 108-109 → se respetó exactamente).
- Se reemplazó el literal `"zone_ignored"` por `EVT.ZONE_IGNORED` (consistencia con el resto del archivo).

**Test nuevo `test_telemetria_iter6.gd` (11/11):** reproduce el **camino real** (sin invocar el chequeo a mano) y prueba:
1. `zone_ignored` se emite **al salir**, sin `_on_zone_check()` manual;
2. el timer de zonas queda **detenido** al salir (prueba de que el camino viejo no habría emitido nunca);
3. el acumulado se limpia tras reportar;
4. una segunda visita a la zona ya reportada **no re-emite** (dedup);
5. una zona de 120 s **no** se reporta y **permanece** en el acumulado;
6. `zone_entered` / `zone_exited` (con `zone_id` y `tiempo_seg`) siguen intactos;
7. con opt-out no se emite nada.

## Decisiones

1. **Auditar antes de implementar.** Los 33 `[ ]` parecían trabajo de diseño pendiente; la lectura del código mostró que eran **gap de marcado**, no de implementación. Marcar con evidencia (archivo + símbolo) evita trabajo duplicado.
2. **No tocar `complete_puzzle` → `puzzle_first_completed`.** Parece un error semántico (emite el evento "first" en cada completado), pero `test_telemetry.gd` línea 119 lo **aserta explícitamente** como comportamiento esperado → es decisión del autor original, no un bug. Se documenta como observación en `04-Codigo.md`.
3. **Fix mínimo y con contrato fijado por test.** No se cambió la semántica del acumulado ni la regla de limpieza; solo se agregó el punto de evaluación que faltaba.

## Archivos Modificados/Creados

**Código GDScript:**
- `game/isla-ancestral/scripts/telemetry/telemetry_director.gd` (iter. 6: `_evaluar_zona_ignorada()` extraída + llamada desde `exit_zone()` + `EVT.ZONE_IGNORED` + header)
- `game/isla-ancestral/scripts/telemetry/test_telemetria_iter6.gd` (**NUEVO**, 11 checks)

**Documentación:**
- `DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/05-Checklist.md` (33 ítems auditados con evidencia, reserva cerrada)
- `DOCUMENTACION/105-Telemetria-De-Gameplay/plan-actual/04-Codigo.md` (Notas del Agente iter. 6)
- `CHECKLIST-GLOBAL.md` (fila 105: 🟡 Liberado, 157/163, agente `—`, notas; fila normalizada a 11 celdas)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (registro §17 + reserva actual + estado)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entrada iter. 6 + iter. 5 marcada con log fantasma)
- `Logs/ULTIMO_NUMERO.txt` (resincronizado: había sido truncado a `821`, perdiendo 822-825)
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/105-Telemetria-De-Gameplay/checklist.md` (backlog personal)

## Verificación (QA numérico — Godot 4.7.2 headless)

Binario: `D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`

- `test_telemetria_iter6.gd` (**NUEVO**): **11 checks / 0 fallos** — prueba el camino real.
- `test_telemetria_iter5.gd`: **0 fallos / 10 checks** (regresión verde tras el fix).
- `test_telemetry.gd`: **16 checks / 0 fallos** (regresión verde tras el fix).
- Sin errores de parseo.
- Baseline tomado **antes** de tocar código (iter5 10/0 · test_telemetry 16/0) → los cambios no introdujeron regresiones.

## Pendientes que quedan en M105 (los 6 `[?]`, todos con motivo y dueño)

1. `[?] Usar datos para mejorar diseño` — requiere gameplay real + volumen de datos (fase posterior).
2. `[?] Definir ajuste de balance basado en datos reales` — idem.
3. `[?] Diseñar M22 notificar a M105 cuando se completan capítulos` — hook del lado de **M22**.
4. `[?] Diseñar M105 identificar capítulos donde muchos jugadores se atascan` — requiere agregación multi-jugador.
5. `[?] Diseñar datos de telemetría identificar bugs emergentes` — requiere volumen real (la captura ya existe).
6. `[?] Diseñar M105 generar issues en M102 basados en patrones de datos` — integración con **M102** pendiente.
