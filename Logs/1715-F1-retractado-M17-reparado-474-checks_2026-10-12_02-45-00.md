# Log 1715: F1 retractado - M17 reparado (autoload por path, invariante de puentes, 474 checks)

**Fecha:** 2026-10-12
**Hora:** 02:45
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

El estratega retracto el encargo F1 (msg 160): Hy3 lo habia cerrado (Log 1681) y M166
quedo sellado 112/112. **No hay codigo de F1 que revertir.** Aproveche la vuelta para
dejar M17 (mi modulo) con las 6 suites en verde: **474 checks, 0 fallos**.

## Cambios en M17

1. **`build_ghost.gd`**: `AssetProfile.ruta(...)` se usaba por **identificador**. Los
   autoloads no son identificadores globales en GDScript y eso rompia la compilacion de
   `test_construccion_iter2.gd` e `iter3` ("Identifier not found: AssetProfile").
   Ahora se resuelve con `get_node_or_null("/root/AssetProfile")` y, si no esta, se usa
   la ruta base tal cual (fallback documentado).
2. **`data/construccion/piezas/muelle_madera.tres`**: la receta de la tanda de heroes
   tenia `familia = puente` pero sin `sobre_agua`, sin `superficie_ok: agua` y con el
   `soportes_minimos` por defecto (1). Un muelle va sobre agua y no exige soporte:
   agregados los tres campos.
3. **`test_construccion_iter2.gd`**: esperados 36 -> **46** recetas (el catalogo crecio
   con las 10 recetas de heroes), familia puente 4 -> 5, decor 11 -> 21, "tras quitar"
   35 -> 45.
4. **`test_construccion_iter3.gd`**: el chequeo de `mesh_path` ahora acepta las dos
   formas validas (ruta completa `res://assets/3d/...glb` y base sin perfil `x.glb`,
   que resuelve `AssetProfile.ruta()`), porque `alfombra.tres` usa la forma base.

## Verificacion (una suite por vez, el lote excede el timeout)

```
test_construccion.gd        131 checks, 0 fallos
test_construccion_iter2.gd   99 checks, 0 fallos
test_construccion_iter3.gd  138 checks, 0 fallos
test_construccion_iter4.gd   45 checks, 0 fallos
test_construccion_iter5.gd   39 checks, 0 fallos
test_construccion_iter6.gd   22 checks, 0 fallos
                             ---
                             474 checks, 0 fallos
```

## Nota de coordinacion

Mi reserva de mensaje **160** (informe del barrido de M27) fue consumida por el mensaje
del estratega con el mismo numero: el informe de M27 quedo sin entregar. Se reenviara
con numero nuevo.

## Archivos Modificados

- `game/isla-ancestral/scripts/construccion/build_ghost.gd`
- `game/isla-ancestral/data/construccion/piezas/muelle_madera.tres`
- `game/isla-ancestral/scripts/construccion/test_construccion_iter2.gd`
- `game/isla-ancestral/scripts/construccion/test_construccion_iter3.gd`
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md`
