# Log 784: M09 — montañas 90m restauradas + capa verde sobre el agua interior

**Fecha:** 2026-09-07
**Hora:** 04:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Corrección de la restauración (el usuario notó: "antes se veían más altas las montañas, ¿seguro que lo restauraste igual?" — cierto, la restauración del Log 783 bajó max_height a 40 por error, pero el estado aprobado era 90) + implementación de la capa verde impostora SOBRE EL AGUA interior tal como el usuario la describió: "agregarle la capa verde impostora arriba del agua que está entre donde estoy con el personaje y las montañas".

## Cambios Realizados
- `main_island.gd`: `max_height 40 → 90` (montañas altas del estado aprobado restauradas — el chamán spawnea a Y=37, más alto que antes).
- `terreno_horizonte.gd`: **capa verde sobre el agua interior** (NUEVO):
  - Anillo plano VERDE (0.60, 0.76, 0.38) a **y=4.3** — encima del agua voxel (4.0) y del plano de agua animado (4.05), debajo de la orilla real (5.0).
  - Cobertura: anillo r 1100-2100 desde el centro de la isla — la zona acuática ENTRE el jugador (spawn r 1838) y las montañas.
  - Bandas radiales de 500m × 64 segmentos — cada banda un tile con fade independiente.
  - Fade por tile: invisible <700m del player, pleno >1500m — al acercarse al agua se desvanece y aparece el agua/arena reales.
  - `CENTRO_ISLA` const agregada (faltaba en el archivo restaurado — 2 parse errors corregidos).
- El impostor de montañas (Log 781) queda intacto encima.

## Cómo se ve ahora (flujos esperados)
- **Desde el spawn**: la capa verde cubre la laguna interior → orilla verde continua desde tus pies hasta las montañas de 90m → sin "agua cortando el terreno".
- **Al acercarte al agua**: la capa verde se desvanece progresivamente → aparece el agua real y la arena.
- **En el otro lado de la isla**: las montañas reales voxel están ahí (mismo generador), y la capa verde cubre el agua interior de ese lado igual.

## Evidencia
- Boot: `[M09-Horizonte] impostor restaurado (Log 781): 121 tiles — fade 1100-1800m activo + capa verde sobre el agua interior` — 0 errores.
- `[M163] Chaman del Monte spawneado en (2320.0, 37.0, 2300.0)` — montañas altas confirmadas.
- Gaviotas con "caída muy larga → aborto" (reintento — la gaviota elige puntos que aún no terminan de streamear; reintenta, no rompe).

## Calibración disponible (constantes al tope del script)
- `VERDE_ALTURA` (4.3), `VERDE_COLOR`, `VERDE_R_MIN/MAX` (1100-2100), `VERDE_ANCHO` (500), `VERDE_DIST_MIN/MAX` (700-1500).

## Archivos Modificados
- `game/isla-ancestral/scripts/main_island.gd` (max_height 90)
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (capa verde + CENTRO_ISLA)
