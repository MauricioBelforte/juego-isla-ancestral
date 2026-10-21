# Log 2088: M112 — correccion de la causa real (deinit del GDExtension de Voxel Tools) + plan de pool paralelo

**Fecha:** 2026-10-21
**Hora:** 22:35
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

Continuacion de P1 (M112). El director aprobo (msg 13) un fix de test "guard headless en data_store" y
derivo a DeepSeek el fix de producto de BUG-141, ambos基于 en mi hipotesis del hilo de guardado. **Sondeando
mas, la hypotese queda desmentida** y lo corrijo antes de que se gaste un ciclo en el fix equivocado.

## Mediciones (sondas propias, ya borradas)

| Sonda | Resultado |
|---|---|
| `DataStore.guardado_en_curso()` durante 120 s con la escena montada | nunca estuvo en curso |
| `remove_child` + `free()` de la escena (16 ms) y luego salir | el proceso igual tarda 67 s |
| **solo `VoxelTerrain.new()` + add_child + quit** | **36.5 s** (control sin escena: 2.8 s) |
| quitar VoxelTerrain/VoxelViewer antes de salir | 66.7 s (sin efecto) |
| bajar `view_distance` a 32 | 96.9 s (sin efecto) |
| `SaveManager._blocked = true` | 62.2 s (sin efecto; slot ya venia -1) |

**Causa real:** el deinit del GDExtension nativo `addons/zylann.voxel` cuando el proceso instancio un
`VoxelTerrain` (~35-100 s por suite). No es el guardado, no es la escena, no son las esperas de frames.

**Efecto sobre BUG-141:** el fix de producto derivado a DeepSeek (data_store) no ataca esta causa; la causa
esta en el modulo voxel (M07/M08/M167), que es nativo.

## Plan (mi alcance, el de test)

Pool de N suites SceneTree en paralelo + las 4 carpetas GdUnit4 en paralelo, con la regla ratificada:
solo se paralelizan suites cuyo codigo no escribe en `user://` ni lanza `OS.execute` (deteccion estatica por
fuente). No se saltea ninguna suite ni se cambian los prints/codigos de salida del runner. Meta 897 s -> ~250-350 s.

## Archivos

- Creado: `Logs/2088-M112-Causa-Real-Deinit-Voxel-Tools-y-Plan-Pool-Paralelo_2026-10-21_22-35-00.md` (este log)
- Creado: `Mensajes entre modelos/MiniMax-M3.1-Flash/014-2026-10-21_22-35-00-minimax-a-glm-5-3-director-p1-correccion-causa-real.md`
- Borrado (sondas propias, por nombre exacto): `game/isla-ancestral/tests/_sonda_mmia_save.gd`, `_sonda_mmia_voxel.gd`
