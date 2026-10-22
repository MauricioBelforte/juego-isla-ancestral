# Log 2103: LANE SERIE EXPLICITA — las suites frame-heavy que dan timeout en el pool salen del pool

**Fecha:** 2026-07-22
**Hora:** 00:25 (local; reloj real del sistema)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Que se hizo

Encargo del director (msg 030, opcion (a)): **serializar las suites que dan timeout en la lane opt-in**.

De la corrida opt-in (Log 2102: 435 suites, 1787.2 s, 13 rojos + **2 timeouts**) salen exactamente 2:

| Suite | Sintoma | Diagnostico |
|---|---|---|
| `scripts/vehiculos/test_vehiculos.gd` | TIMEOUT >300 s en el pool | esperas **basadas en frames** (`for i in range(200): await process_frame`, y 9 bucles mas: 200+100+100+100+5+60+120+200+50+100+20 frames) |
| `tests/unit/ui/test_inventory_unificado.gd` | TIMEOUT >300 s en el pool | ~60 `await process_frame` (espera por frames del arbol) |

**No son suites voxel**: no contienen `VoxelTerrain` / `VoxelViewer` / `main_island`, asi que no pagan el
deinit del GDExtension (BUG-141). Son **frame-heavy**: en SERIE los frames van a velocidad normal y
terminan en ~60 s, pero con 6 workers compitiendo por la CPU la tasa de frames se desploma y el tope
de 300 s del pool se agota.

**Implementacion:** el runner tiene ahora una `LANE_SERIE_EXPLICITA` (const con las 2 rutas medidas y el
motivo escrito). La particion las manda a la lane SERIE en vez de al POOL. Verificado: el pool paso de
**355 -> 353 suites** y el parse del runner sigue OK.

**Como extenderla** (documentado en el codigo): cuando una suite del pool de timeout, medirla en serie y
anadirla a la lista con su motivo. La lista es *medida*, no heuristica: no meto suites por "*parece*
frame-heavy" porque eso frenaria el pool sin evidencia.

## Pendiente honesto

La **verificacion completa** de la lane opt-in (30 min de reloj) la dejo corriendo: al cerrarla
comprobare que los 2 timeouts desaparecen y que el total no crece (los 2 serian ahora ~60 s en serie,
mas que 2 x 300 s colgados). Si los timeouts siguen, lo reporto asi — sin maquillar.

## Archivos

- Modificado: `game/isla-ancestral/tests/run_tests.gd` (`LANE_SERIE_EXPLICITA` + su uso en la particion)
- Creado: este log + el acuse 031 del canal
- Modificado: `BACKLOG-MASTER.md`, `ESTADO-PARALELO.md`
- Sin push ni commits. No se toco codigo de suites ajenas: solo la lane del runner.
