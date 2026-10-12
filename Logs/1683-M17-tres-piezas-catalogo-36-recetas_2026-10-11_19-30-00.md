# Log 1683: M17 - 3 piezas de catalogo creadas (33 -> 36 recetas) + falsa alarma T-19

**Fecha:** 2026-10-11
**Hora:** 19:30
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

El director acepto el batch (msg 136, cuerpo que se escribio mientras yo lo leia:
**race condition**, mi reporte T-19 de "mensaje caido" fue una **falsa alarma** que
quedo registrada y corregida). De sus 4 decisiones, la 4 era crear las 3 piezas de
catalogo faltantes y despues flippear los items.

## Cambios Realizados

### Assets nuevos (decision 4 del director)

| Archivo | Familia | Costo | Detalle |
|---|---|---|---|
| `data/construccion/piezas/puente_3.tres` | puente | `planks: 9` | `tamano 3x1`, `sobre_agua`, `superficie_ok=[agua]`, `soportes_minimos=0`, `bloque 8` |
| `data/construccion/piezas/camino_cesped.tres` | camino | `grass: 2` | `altura 0.1`, `superficie_ok=[terreno]`, `bloque 24` (item `grass` real de M14) |
| `data/construccion/piezas/cerca_bambu.tres` | cerca | `wood: 2` | `altura 0.7`, `superficie_ofrecida=aire`, `bloque 8`, malla real `50-Vegetacion_canas_bambu.glb` |

Los 3 respetan el esquema `PlacementRule` y usan ids de item que existen como
recurso real (`res://data/items/planks.tres`, `grass.tres`, `wood.tres`). Sin BOM,
sin mojibake, LF como el resto del directorio.

### Tests actualizados

`test_construccion_iter2.gd` tenia hardcodeado el catalogo viejo de 33 recetas.
Se actualizaron las expectativas a 36 (conteo total, `cantidad()`, familia puente
3->4, `por_modo` 33->36, autoload, carga recursiva, `validar() n`, "tras quitar"
32->35, modo CONSTRUCCION 22->25). No se toco ninguna logica: solo valores
esperados que el catalogo nuevo cambia.

### Checklist

`DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`: **63 -> 66 `[x]`** / 175.
Flipeados los 3 items que estaban bloqueados por estas piezas (puentes 1-2-3-4,
caminos piedra/arena/cesped apisonado, cercas madera/piedra/bambu), cada uno con la
evidencia en la misma linea.

## Verificacion

```
test_construccion.gd       -> 131 checks, 0 fallos
test_construccion_iter2.gd ->  99 checks, 0 fallos   (catalogo: 36 recetas, familia puente = 4)
test_construccion_iter3.gd -> 138 checks, 0 fallos
                              -----
                              368 checks, 0 fallos
```

Los 3 archivos `.tres` cargan sin error y la auditoria de integridad del catalogo
(`validar()`, item_id reales, mesh_path existentes) queda en verde.

## Archivos Modificados/Creados

- `game/isla-ancestral/data/construccion/piezas/puente_3.tres` (nuevo)
- `game/isla-ancestral/data/construccion/piezas/camino_cesped.tres` (nuevo)
- `game/isla-ancestral/data/construccion/piezas/cerca_bambu.tres` (nuevo)
- `game/isla-ancestral/scripts/construccion/test_construccion_iter2.gd` (expectativas 33 -> 36)
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` (3 flips + Totales + nota)

## Leccion

T-19 volvio a morder, pero al reves: el mensaje **no** estaba caido, se estaba
escribiendo. Mi espera fue de ~3 h (lei a las 19:21 un archivo escrito a las 19:20:48).
Ante un "vacio" conviene releer el archivo **inmediatamente antes** de reportar, y
reportar el `mtime` observado para que el emisor pueda refutarlo con facilidad.
