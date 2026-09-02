# Log 318: M30 Reloj iter. 2 — hover D70, suite bloque E, config .tres y scan anti-reloj-SO

**Fecha:** 2026-09-01
**Hora:** 01:10
**Modelo:** glm-5.3
**Plataforma:** Cline

> Nota de numeración: los números 309-317 fueron tomados en paralelo por otros agentes mientras esta tarea estaba en curso (carrera del contador de `ULTIMO_NUMERO.txt`); se tomó el primer número libre (318) según §6.1.
>
> **Nota de atribución (auditoría, Log 320):** PARTE 2 de la suite (`caso_reloj_tests.gd`) y las capturas in-engine fueron completadas por **glm-5.3-flash (Cline)** tras el bloqueo sin visión de glm-5.3; el cierre documental y la auditoría posterior fueron de glm-5.3.

## Resumen
Iteración 2 del M30 (Reloj en Tiempo Real): se implementó el hover/desplegable D70 (tooltip vía TooltipService de M53), la configuración data-driven `data/ui/w_reloj.tres` (F100/F107/F101), la suite headless completa del bloque E (10 casos de límites + widget + hover + config + formato) y el scan estático anti-reloj-SO (C56/E89/E90). El módulo pasa de 10/104 a **98/104** y queda liberado en 🟡 (5 pendientes con dueño externo + 1 `[?]`).

## Cambios Realizados
- **D70 hover:** `w_reloj.gd` detecta el cursor por rect global en `_process` (sin `MOUSE_FILTER_STOP` → D78 "no bloquea clicks" intacto) y muestra tooltip por `TooltipService.show_tooltip()` con formato M88 ("Fecha y hora|detalle con fecha completa, sesión, estación y próximos eventos"). Verificado visualmente: captura `cap_30_2026-08-31_23-30-00_02_hover.png`.
- **F100/F107 config:** nuevo `scripts/clock/w_reloj_config.gd` (clase `WRelojConfig`) + `data/ui/w_reloj.tres` + carga con fallback a defaults (`_cargar_config`) + seam `config_inyectada` para tests.
- **F101:** formato 12h/24h real vía `RelojHud.formatear_hora` estático + flag del config.
- **Bloque E:** nueva suite `scripts/clock/caso_reloj_tests.gd` → **29 checks, 0 fallos** (corrida: `godot --headless --path game/isla-ancestral -s res://scripts/clock/caso_reloj_tests.gd`). Casos 8/9 verificados ESTRUCTURALMENTE por el scan (0 gameplay lee APIs de reloj del SO en 240 archivos; no se muta el reloj real de la máquina del usuario).
- **C56/E89/E90:** scan estático integrado en la suite con whitelist documentada (logging/analytics/telemetry/performance/saving/editor — timestamps de diagnóstico) y auto-exclusión del propio test.
- **E93:** escenario `scenes/caso_reloj.tscn` + `scripts/clock/caso_reloj.gd` (CanvasLayer layer 0, bajo el TooltipService layer 1).
- **Preview iter. 2:** 3.ª captura in-engine con tooltip del hover forzado (`demo_cursor_dentro`).
- **Backup §5:** `scripts/clock/Obsoletos/2026-08-31_23-05-00_w_reloj.gd`.
- **Checklist:** relevo honesto completo → 98 `[x]`, 1 `[?]` (D67 ícono M45/M46), 5 `[ ]` con dueño externo (D74 M64, C58/G113 M74/M28/M36, F105 M59, F106 M57).
- **Contrato corregido** en 04-Codigo §2: la API real de M29 son señales propias de GameClock + EventBus.calendar; `EventBus.time` solo expone `fase_cambio` (M31).
- ⚠️ **HALLAZGO CROSS-MODULE (dueño M53/M88):** el theme global aplica una fuente ausente (`FreeType: Error loading font: ''`) → TODOS los Labels del juego renderizan sin texto. Confirmado comparando la captura de M30 del 26/08 (texto visible) contra la del 01/09 (texto invisible). El tooltip del hover SÍ se ve porque TooltipService no usa el theme. Documentado en `07-GUIA-GODOT.md` §9.53 (numerada §9.50 en el cierre; renumerada en auditoría, Log 320). **URGENTE para M53/M88.**

## Verificación
- Suite headless: `=== Resumen: 29 checks, 0 fallos ===` (29/29 OK).
- Capturas: `tools/mcp/godot-mcp/capturas/30-Reloj-En-Tiempo-Real/cap_30_2026-08-31_23-30-00_{00,01,02}_hover.png` (iter. 1 del 26/08 conservada como comparativa).
- Nota: el exit code 1 de los headless actuales proviene del autoload `interacciones` (M17 🔵 qwen, errores de parseo ajenos a M30).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/clock/w_reloj.gd` (modificado — hover + config + formato)
- `game/isla-ancestral/scripts/clock/w_reloj_config.gd` (nuevo)
- `game/isla-ancestral/scripts/clock/caso_reloj.gd` (nuevo)
- `game/isla-ancestral/scripts/clock/caso_reloj_tests.gd` (nuevo)
- `game/isla-ancestral/scripts/clock/preview_reloj.gd` (modificado — demo hover)
- `game/isla-ancestral/scripts/clock/Obsoletos/2026-08-31_23-05-00_w_reloj.gd` (backup)
- `game/isla-ancestral/data/ui/w_reloj.tres` (nuevo)
- `game/isla-ancestral/scenes/caso_reloj.tscn` (nuevo)
- `tools/mcp/godot-mcp/capturas/30-Reloj-En-Tiempo-Real/cap_30_2026-08-31_23-30-00_{00,01,02}_hover.png` (capturas)
- `DOCUMENTACION/30-Reloj-En-Tiempo-Real/plan-actual/{04-Codigo,05-Checklist}.md` (actualizados + firmados)
- `CHECKLIST-GLOBAL.md` (fila 30: 10/104 → 98/104, liberada 🟡)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (M30 liberado)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (reserva M30 cerrada + firma)
- `DOCUMENTACION/07-GUIA-GODOT.md` (§9.53 nuevo — renumerada de §9.50 duplicado en auditoría, Log 320)
- `DOCUMENTACION/README.md` (estado M30)
- `Logs/ULTIMO_NUMERO.txt` (→ 318)