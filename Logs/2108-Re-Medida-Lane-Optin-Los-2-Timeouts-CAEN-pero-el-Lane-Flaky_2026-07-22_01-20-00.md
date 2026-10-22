# Log 2108: re-medida de la lane opt-in — los 2 timeouts CAEN, pero el lane resulta FLAKY (no sirve como gate tal cual)

**Fecha:** 2026-07-22
**Hora:** 01:20 (local; reloj real del sistema)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Lo que se midio (corrida opt-in con los fixes de photo_service ya aplicados)

```
[EVIDENCIA] suites descubiertas: 436 (432 SceneTree + 4 GdUnit4)
[POOL] 354 suite(s) en paralelo (max 6 workers)
[LANE SERIE EXPLICITA] 2 suite(s) frame-heavy fuera del pool
[LANE VOXEL] 21 suite(s) EN SERIE
[EVIDENCIA] suites OK: 423/436 ejecutables
[EVIDENCIA] checks SceneTree: 12482 · test cases GdUnit4: 21 · tests totales: 12503
[EVIDENCIA] tiempo total de suite: 1860.4 s (31.01 min) · presupuesto 600 s · EXCEDE
RESULTADO: FALLO — 423 suites OK de 436 · 12503 tests · 13 con fallo(s)
```

## 1. LO QUE SE PEDIA: los 2 timeouts CAEN (sin maquillar)

| Suite | Antes | Ahora |
|---|---|---|
| `scripts/vehiculos/test_vehiculos.gd` | TIMEOUT >300 s | **ya no falla** (lane serie explicita) |
| `tests/unit/ui/test_inventory_unificado.gd` | TIMEOUT >300 s | **ya no falla** (lane serie explicita) |
| `tests/test_m56_tomar_foto.gd` | rc=1 (1 check rojo) | **ya no falla** (fix de parseo de photo_service) |

## 2. HALLAZGO IMPORTANTE: el lane opt-in es FLAKY, no un gate

Aparecen **3 timeouts nuevos** (`scripts/player/test_player_cableado_m11.gd`,
`scripts/playtest/test_playtest_m114.gd`, `tests/unit/time/test_time_calendar.gd`), **los tres en el POOL**.
Aislados **pasan en ~3 s cada uno** (rc=0). Y lo decisivo: **la composicion de los 13 fallos es
DISTINTA entre las dos corridas** del mismo lane:

| Corrida | Fallos |
|---|---|
| opt-in #1 (Log 2102) | balance_m93, polish_m21, event_manager_pure, farm, photo_service, amistad_rf48, vfx_director, m53_wcag, generacion_m10, m56_tomar_foto, flujo_xp_m71, regresion_templos + 2 timeouts |
| opt-in #2 (este) | build_m117, pagejump_m21, capitulos_m74, eventos_relativos_m74, motivacion_m94, vfx_catalog, version_control_m06, m89_menus, generacion_m10, time_calendar, fixtures_smoke + 3 timeouts |

Casi **no se repiten** (solo `generacion_m10_atria`). O sea: **con 6 workers el pool satura la maquina**
(6 procesos Godot x 116 autoloads) y las suites se quedan sin CPU: las que caen son las que toca, no las
que estan rotas. **Consecuencia: el lane opt-in sirve como RADAR (dice "algo esta mal aqui") pero NO puede
ser un gate** (daria verde/rojo segun la carga, no segun la realidad).

## 3. Bugs reales que SI aparecieron (no son flapping)

- `tests/integration/test_fixtures_smoke.gd` -> **rc=-1073741795 = ACCESS VIOLATION (crash nativo)**: un
  fallo de C++ real, no un timeout. Derivado a su dueno.
- `tests/test_m56_tomar_foto.gd` -> arreglado por el fix de parseo (Log 2104).

## 4. Recomendacion

1. **El lane opt-in se queda como radar**, no como gate: informativo, con la advertencia de que su lista
   de fallos **cambia entre corridas** (no usarla para sellar nada sin re-medir 2 veces).
2. Si se quiere un gate determinista: **bajar el pool de la lane opt-in a 3 workers** (menos contencion) y
   medir dos veces seguidas para comprobar que la lista de fallos se estabiliza. Con 6 workers el
   tiempo total es 31 min y el resultado es ruido.
3. La lane por defecto (49 suites, 6 workers, 530.6 s) **si es estable y verde** (49/49, 0 timeouts) ->
   esa es la que puede seguir siendo el gate del CI.

## Archivos

- Creado: este log + el acuse 036 del canal
- Modificado: `BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`
- Sin push ni commits. No se toco codigo de suites ajenas.
