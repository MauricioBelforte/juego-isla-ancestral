# Log 2104: lane serie explicita (frame-heavy) + CI desbloqueado: dos errores de parseo en photo_service que ensuciaban TODAS las corridas

**Fecha:** 2026-07-22
**Hora:** 00:35 (local; reloj real del sistema)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## 1. Lane SERIE EXPLICITA (encargo del director, msg 030, opcion (a))

Las 2 suites que dangaban TIMEOUT en la lane opt-in (Log 2102) son **frame-heavy**, no voxel:
`scripts/vehiculos/test_vehiculos.gd` (`for i in range(200): await process_frame` y 9 bucles mas) y
`tests/unit/ui/test_inventory_unificado.gd` (~60 `await process_frame`). En serie terminan en ~60 s; en el
pool (6 workers) la tasa de frames se desploma y el tope de 300 s se agota.

Implementado como `LANE_SERIE_EXPLICITA` en `tests/run_tests.gd` (const con las 2 rutas medidas y el
motivo escrito). Verificado: el pool paso de **355 -> 353 suites**, parse OK.

## 2. HALLAZGO QUE BLOQUEA EL CI ENTERO: dos errores de parseo en `scripts/foto/photo_service.gd`

**Como lo encontre:** la lane por defecto paso de 49/49 OK a 43/49 con 3 fallos y **0 casos GdUnit4**
(`[FALLO] GdUnit4 (rc=105, tests=0, ...)`). Aislando las 3 suites: 2 pasaban solas (flapping por estado
compartido) y 1 fallaba sola — y en las 3 corria el mismo error:

```
SCRIPT ERROR: Parse Error: There is already a variable named "env" declared in this scope.
```

**El archivo estaba COMMITEADO roto** (lo barrio CRON C de otro agente: commit `452809f` "Se ratifica la
lane serie de MiniMax con correccion de fecha y se deriva urgente los flips ausentes a Beam"). Con el
script sin parsear, **el error salia en CADA corrida del CI** y `test_m56_tomar_foto` fallaba.

**Dos fixes quirurgicos** (M56-Fotografia esta 🟡 Liberado, sin dueno -> no piso a nadie):

1. `env` duplicado en la MISMA funcion `tomar_foto()` (L281 y L335) -> la 2a pasa a `env_restore`.
2. `ms` **usado antes de declararse** (L323 lo usa, L350 lo declara) -> se calcula el elapsed en el
   punto de uso: `Time.get_ticks_msec() - t0`.

**Verificado:** `photo_service.gd` parsea OK y `test_m56_tomar_foto.gd` pasa: **rc=0, 26 checks, 0 fallos**
(antes rc=1 con 1 fallo).

## 3. Lo que queda pendiente de medicion

La corrida de verificacion de la lane opt-in **se lanzo ANTES de estos fixes**, asi que su lista de rojos
incluye los que estos fixes acaban de resolver. La vuelvo a medir en la proxima vuelta (30 min de reloj)
y reporto el numero final.

## Archivos

- Modificado: `game/isla-ancestral/tests/run_tests.gd` (`LANE_SERIE_EXPLICITA`)
- Modificado: `game/isla-ancestral/scripts/foto/photo_service.gd` (2 fixes de parseo; M56, dueno: otro agente)
- Creado: este log + el acuse 032 del canal
- Modificado: `BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`
- Sin push ni commits.
