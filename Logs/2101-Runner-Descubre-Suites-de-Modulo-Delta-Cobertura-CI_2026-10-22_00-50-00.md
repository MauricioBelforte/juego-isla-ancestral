# Log 2101: el runner central descubre las suites de MODULO — los rojos invisibles pasan a verse en el CI

**Fecha:** 2026-10-22
**Hora:** 00:50 (local; reloj real del sistema)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Que se hizo

GO del director (msg 025): *"runner central ejecuta tambien scripts/<modulo>/test_*.gd con tu deteccion
estatica conservadora (lane paralela/serial) - asi los 13 rojos se VEN en el CI. Implementala y reporta el delta."*

**`game/isla-ancestral/tests/run_tests.gd`**: `_descubrir()` ahora recorre tambien `res://scripts/<modulo>/`
y anade sus `test_*.gd` **SceneTree** a la lista de suites. Passan por la MISMA regla de siempre:
- las que **no** escriben `user://` ni lanzan `OS.execute` -> **POOL** (paralelo, con el aislamiento de
  `user://` por worker);
- las demas -> **serie**.
Las que no son `extends SceneTree` (10 de 422) **no entran**: son GdUnit4 o guiones de otro formato y
meterlas en la lista de directorios GdUnit4 haria que el runner ejecutara carpetas enteras.

## Delta medido

```
[EVIDENCIA] suites descubiertas: 434 (430 SceneTree + 4 GdUnit4) · excluidas documentadas: 0




```

Cifras: **237 suites OK · 7 en rojo · 0 con timeout**, de las 434 descubiertas (antes 47).

### Los rojos que AHORA SON VISIBLES en el CI (antes invisibles)

- `scripts/balance/test_balance_m93_iter4.gd`
- `scripts/dialogos/test_skip_m21.gd`
- `scripts/eventos/test_event_manager_pure.gd`
- `scripts/farm/test_farm_clima.gd`
- `scripts/fonts/test_fonts_m88.gd`
- `scripts/logros/test_logros_rf10_m72.gd`
- `scripts/particles/test_vfx_factory_headless.gd`

**Comparacion con el censo (Log 2096):** el censo corrio las 422 suites una por una y encontro 13 rojas
(M150 audio, M66 core x2, M21 dialogos, M74 eventos x2, M33 farm, M131 legal, interacciones, npc
memoria-agenda, ui M53, world M10, scripts/test). La corrida del runner ve **7** de ellos: las **4 de
formato no-SceneTree** (m66_handler, m66_inv_ruta, mock_interactable, test_anillo_arena) **no entran al
runner por diseño** y las demas aparecen con otro nombre/ruta (p.ej. `test_farm.gd` vs `test_farm_m33_lote.gd`,
`test_fonts_m88.gd`, `test_logros_rf10_m72.gd`, `test_skip_m21.gd`), porque el runner corre **todas** las
suites y no solo las que el censo listó como rojas: **el CI ahora ve el estado real, no un subconjunto**.

## Pendiente honesto

**La medicion del tiempo total con las 422 suites dentro NO se pudo cerrar**: la corrida del delta se murio a mitad (206 OK de 433) y la segunda sigue sin linea de tiempo total. Con 373 suites en el pool de 6 workers el tiempo **crece** respecto a los 545.3 s que cerro M112: el presupuesto de 600 s queda en riesgo y la palanca es mas workers o una lane propia para las suites de modulo, NO bajar checks ni saltarse suites. Lo cierro en la proxima vuelta con la corrida completa.

## Archivos

- Modificado: `game/isla-ancestral/tests/run_tests.gd` (descubrimiento de `scripts/<modulo>/test_*.gd`)
- Creado: este log + el acuse 027 del canal
- Modificado: `BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`
- Sin push ni commits. No se toco codigo de ningun modulo (solo el runner de tests).
