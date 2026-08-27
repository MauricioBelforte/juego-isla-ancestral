# Log 174: Implementación del GameClock (M29 Tiempo y Calendario)

**Fecha:** 2026-08-26
**Modelo:** ox-alpha (Cline)

## Resumen
Se implementó el núcleo del M29 (Tiempo y Calendario): el GameClock automático como autoload, servicio temporal puro del mundo Aurora que emite sobre el EventBus M07 y que varios módulos consumidores (M39, M20, M38, M31) esperaban. Sin visión (V0).

## Cambios Realizados

### Código creado (game/isla-ancestral/scripts/time/)
- **`game_clock.gd`** — autoload `GameTime`: calendario Aurora (día 24 min reales, 1 s real = 1 min de juego, semana 7 días, mes 28 días, año 336 días, 4 estaciones de 3 meses), tick automático por acumulador anti-drift, pausa/resume, `avanzar_hasta(hora)` (dormir). Emite sobre EventBus M07 calendar (`day_started`, `season_changed`) y señales propias (`dia_cambio`, `hora_cambio`, `estacion_cambio`). ISaveProvider (M59) sección `time`. Regla cozy: no retrocede, no corre offline.
- **`test_calendario.gd`** — suite de validación (13 checks).

### Registro
- Autoload `GameTime` agregado en `project.godot`.
- `CHECKLIST-GLOBAL.md` fila 29 → 🟡 39/104 (núcleo reloj hecho).

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/time/game_clock.gd` (nuevo)
- `game/isla-ancestral/scripts/time/test_calendario.gd` (nuevo)
- `game/isla-ancestral/project.godot`
- `CHECKLIST-GLOBAL.md`

## Verificación
`--headless --script test_calendario.gd` → **13/13 checks OK, exit 0** + boot del proyecto limpio (autoload cargó sin errores de scripts).

## Pendientes honestos (`[?]`)
- Gradientes de amanecer/atardecer (M31).
- Knobs de duración en `data/time/*.tres` y festivales en data.
- Rutinas NPC por hora (M19/M64) y tiendas con horario (domingos cerrados).
- Semilla de tiempo por partida.