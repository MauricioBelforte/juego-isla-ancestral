# Log 2057: Tanda 86 - Item 131 (chunks vs presupuesto voxel)

**Fecha:** 2026-10-21
**Hora:** 01:31
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** OpenCode

## Resumen

Se cerro el item 131 del BACKLOG (L217 de M62): "Test Play Mode: maximo de chunks cargados sin superar
el presupuesto voxel [M]".

**Resultado: `[x]`.** `test_m62_chunks_presupuesto.gd` paso **6 checks / 0 fallos / EXIT 0** con el
presupuesto REAL (`budgets.json` via `MemoryBudgetRegistry`, preset media, voxel 650 MB) y el tope REAL
de StreamManager. Coste medido con 512 `VoxelBuffer` de 16^3: **8.4 KB/chunk**. Maximos por presupuesto:
baja 500 MB = **60.952**, media 650 MB = **79.238**, alta 800 MB = **97.523** chunks. El tope de produccion
es **4.096 chunks = 34 MB** de datos, muy por debajo del presupuesto. Con 20.100 registrados y tope
20.000, `aplicar_tope()` deja **20.000**; 20.008 liberados; **0 recursos vivos (WeakRef)**; 0 huerfanos.
La **sonda roja** `M62_SIN_TOPE=1` deja 20.100 y falla el check del tope, **EXIT 1**.

## Evidencia

- `out/tanda86/chunks_presupuesto.log` - sha256 `284802310F955DADEDB6C7602E837C8DE347A29A6DCF646B9EAC58151B98D75E`.
- `out/tanda86/chunks_presupuesto_rojo.log` - sha256 `AFFFA5EB3D88F7FC0B8118084D6E12DFF939B13363BD8F68D8E3E7D91D597C47`.
- Verde: `=== Resumen M62 chunks vs presupuesto voxel: 6 checks, 0 fallos ===`.
- Rojo: `6 checks, 1 fallos`, `[FALLO] el LRU deja exactamente el tope (20000)`, EXIT 1.

## Alcance declarado

- Coste de **DATOS** (VoxelBuffer 16^3), no mallas/colliders por chunk (headless no crea renderer).
- El VoxelTerrain headless reporta 0 bloques actualizados: no hay streaming real.
- **No es el Play Mode del editor**: es un `SceneTree --script` headless.
- No se toco produccion; el arnes ya existia y se ejecuto con su sonda roja.

## Cambios Realizados

- `05-Checklist.md` M62: L217 `[x]`; Totales **143/4/3**; seccion Tanda 86.
- `04-Codigo.md` M62: seccion Tanda 86.
- `07-Resultados-Testings.md` M62: seccion 37.
- BACKLOG: 131 `[x]` y duplicado 26.
- Log 2057; informe 182; cron fila 80; tracker 182.

## Archivos Modificados/Creados

- `DOCUMENTACION/62-Memoria/plan-actual/04-Codigo.md`
- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md`
- `DOCUMENTACION/62-Memoria/plan-actual/07-Resultados-Testings.md`
- `DOCUMENTACION/TAREAS-POR-MODELO/DS-V4.1-Flash-Opencode/BACKLOG-MASTER.md`
- `out/tanda86/chunks_presupuesto.log`, `out/tanda86/chunks_presupuesto_rojo.log` (evidencia)

**Firma:** DeepSeek-V4.1-Flash / OpenCode - Tanda 86 - 2026-10-21 01:31
