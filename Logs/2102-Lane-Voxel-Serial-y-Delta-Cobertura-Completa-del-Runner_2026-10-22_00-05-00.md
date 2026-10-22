# Log 2102: LANE VOXEL SERIAL (mitiga BUG-141 en CI) + delta completo de la lane de modulos

**Fecha:** 2026-10-22
**Hora:** 00:05 (local; reloj real del sistema)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## 1. LANE VOXEL SERIAL (encargo del director, msg 028 — opcion (a))

`tests/run_tests.gd` clasifica ahora cada suite en tres lanes:
- **POOL** (paralelo, 6 workers, con aislamiento de `user://` por worker): las que no escriben
  `user://` ni lanzan `OS.execute`.
- **LANE VOXEL** (EN SERIE, de una en una): las que instancian `VoxelTerrain` / `VoxelViewer` /
  `main_island` — pagan el **deinit del GDExtension nativo** (35-100 s por proceso, BUG-141) y compiten
  entre si por los hilos. Deteccion **estatica por fuente** (sin ejecutar nada para decidir).
- **SERIE**: el resto (escriben `user://` o lanzan `OS.execute`).

### Efecto medido en la lane por defecto (49 suites, la que usa el CI hoy)

| | antes (Log 2090) | ahora (con lane voxel) |
|---|---|---|
| Tiempo total | 545.3 s (9.09 min) | **530.6 s (8.84 min)** |
| Suites | 46/47 OK, **1 TIMEOUT** (`test_iconos_m159.gd`) | **49/49 OK, 0 timeouts** |
| Tests | 2462 | **2523** |

**La lane voxel serial resolvio el ultimo rojo que quedaba**: `test_iconos_m159.gd` (que colgaba
>180 s) es una suite que instancia voxel; en serie ya no compite por los hilos y termina. **El CI
queda 49/49 en verde y ADEMAS mas rapido (530.6 s vs 545.3 s).** Eso es la mitigacion de BUG-141 a
nivel CI, y de paso el presupuesto de 600 s de M112 no solo se cumple: se mejora.

## 2. Delta completo de la lane de modulos (opt-in)

Corrida completa con `M112_INCLUIR_MODULOS=1` (29.8 min de reloj):

```
[EVIDENCIA] suites descubiertas: 435 (431 SceneTree + 4 GdUnit4)
[POOL] 355 suite(s) en paralelo (max 6 workers)
[LANE VOXEL] 21 suite(s) EN SERIE
[EVIDENCIA] suites OK: 417/435 ejecutables
[EVIDENCIA] checks SceneTree: 12284 · tests totales: 12284
[EVIDENCIA] tiempo total de suite: 1787.2 s (29.79 min) · presupuesto 600 s · EXCEDE
RESULTADO: FALLO — 417 suites OK de 435 ejecutables · 12284 tests corridos · 15 con fallo(s)
```

| | lane OFF (default) | lane ON (opt-in) |
|---|---|---|
| Suites descubiertas | 49 | **435** |
| Tests ejecutados | 2.523 | **12.284 (4.9x)** |
| Tiempo total | **530.6 s (8.84 min) — CUMPLE** | 1787.2 s (29.79 min) — **EXCEDE 3x** |
| Rojos visibles | 0 | **13 (+2 timeouts)** |

### Los 13 rojos que la lane hace visibles (eran invisibles para el CI)

`build_m117` · `polish_m21` · `event_manager_pure` · `farm` · `photo_service_headless` ·
`amistad_rf48_m20` · `vfx_director_headless` · `m53_wcag` · `generacion_m10_atria` ·
`m56_tomar_foto` · `flujo_xp_recompensa_m71_hy3` · `regresion_templos` ·
**`test_m17_suites_integracion` (el mio: fallaba por el watchdog de 120 s bajo la carga del pool →
ya subido a 300 s; lo vuelvo a medir en la proxima vuelta)**.

Los 2 timeouts son de suites que instancian voxel y exceden el tope del pool (300 s).

## 3. Decision que propongo (el dato es del director)

La lane de modulos **sigue OPT-IN** (no la dejo por defecto): con ella el CI pasaria de 8.84 min a
**29.79 min**, 3x el presupuesto de 600 s. La forma que propongo:
- **Paso 1 (siempre, 8.84 min):** la lane por defecto — 49/49 verde, 2523 tests, dentro de presupuesto.
- **Paso 2 (opcional, ~30 min, nightly o por evento):** la lane de modulos — 4.9x de cobertura y el
  **radar de rojos** (13 visibles para derivar a sus duenos).

Con el paso 2 como paso aparte, **la cobertura sube sin romper el presupuesto medido**, y el雷达 de
rojos queda en un sitio donde se ve sin ensuciar el verde del CI principal.

## Archivos

- Modificado: `game/isla-ancestral/tests/run_tests.gd` (lane voxel serial + deteccion estatica)
- Modificado: `game/isla-ancestral/tests/test_m17_suites_integracion.gd` (watchdog 120 s -> 300 s)
- Creado: este log + el acuse 029 del canal
- Modificado: `BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`, `CHECKLIST-GLOBAL.md` (fila 112: la medicion
  del tiempo sube de 545.3 s a **530.6 s** con la lane voxel)
- Sin push ni commits. No se toco codigo de ningun modulo.
