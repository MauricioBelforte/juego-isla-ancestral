# 302 — M166 QA Visual: Fix E-50 (apoyo puntual en domo) — veta_hierro + veta_oro

**Fecha:** 2026-08-31 03:00–03:30 (GMT-3)
**Módulo:** M166 (QA Visual de assets 3D)
**Trigger:** El usuario reabrió Blender → socket 9876 vivo → pude retomar el pendiente del log 301 (fix E-50 sobre `veta_hierro`).

## DIAGNÓSTICO

Re-corrí `diag_apoyo.py` (E-24: vértices reales, no bound_box) sobre los 3 .blend de `veta_hierro` y `piedra_afilar`:

### piedra_afilar — FALSA ALARMA E-31
Numericamente OK y visualmente OK. La losa es un prisma plano 0.187 × 0.085 × 0.041 con `toca=2, footprint=0.187×0.034`. Mi veredicto previo en el log 278 ("flotando") fue erróneo — había confundido la sombra del capturador orbital con un gap. Aprendizaje: **E-37 también aplica al diagnóstico visual, no solo al fix**. Piedra aprobada, no se toca.

### veta_hierro — E-50 (apoyo puntual en domo)
Dump con `dump_anillos.py` (BFS sobre aristas, anillos topológicos) reveló la estructura real:

| anillo | z típico | r_xy típico |
|--------|----------|-------------|
| 0 (punta abajo) | 0.045 | 0.053 |
| 1 | 0.105-0.138 | 0.61-0.70 |
| 2 | 0.284-0.356 | 0.94-1.19 |
| 3 (ecuador) | 0.565-0.595 | 1.11-1.29 |
| 4 | 0.827-0.883 | 0.97-1.15 |
| 5 | 1.044-1.075 | 0.58-0.69 |
| 6 (punta arriba) | 1.124 | 0.050 |

**La roca es un HUSO** (punta abajo r=0.05, punta arriba r=0.05, ecuador a z=0.58). El vértice más bajo toca z=0.045, pero el ecuador (la parte más ancha, r=1.29) está a 58 cm de altura → la roca flota visiblemente aunque el test numérico pase.

## FIX

### Primer intento (XY, fallido)
`aplanar_dome.py` con selección por distancia XY eligió vértices del **techo** del huso (anillos 5-6), porque comparten centro XY con el vértice inferior. Aplanarlos habría colapsado todo el modelo. **Descubierto E-51**: vecindario por TOPOLOGÍA DE ARISTAS (BFS), no distancia euclidiana.

### Segundo intento (BFS topológico, exitoso)
Reescribí el script con BFS sobre `o.data.edges`:

```python
ady = {}
for e in o.data.edges:
    a, b = e.vertices[0], e.vertices[1]
    ady.setdefault(a, set()).add(b)
    ady.setdefault(b, set()).add(a)

seleccion = {imin}
frontera = [imin]
for _ in range(K):
    sig = [v for n in frontera for v in ady.get(n, ()) if v not in seleccion]
    seleccion.update(sig)
    frontera = sig
```

Con K=2: aplanar el vértice más bajo + 2 anillos topológicos (16 vértices). El resultado:
- Base hexagonal de ~2.31×2.00 m a z=0.0450
- 16 vértices tocando (footprint plano)
- El resto del huso (anillos 3-6, z=0.57-1.12) se conserva intacto
- La roca pasa de huso a "roca achatada con base hexagonal plana" — lee correctamente como boulder

### E-45 segundo tropiezo
`bpy.ops.object.mode_set(mode='EDIT')` y `bpy.ops.mesh.normals_make_consistent()` fallaron en el primer intento (`Context missing active object` — E-45, el socket restringe `bpy.context`). Reescribí sin operadores: solo `o.data.vertices[i].co = local` + `o.data.update()` + `bpy.context.view_layer.update()`. Aplanar vértices no cambia winding de caras, así que las normales se conservan.

## APLICACIÓN

```
aplanar_dome.py 15-Recursos veta_hierro_lowpoly Roca 0.045 2 --variantes source
aplanar_dome.py 15-Recursos veta_hierro_lowpoly Roca 0.045 2 --variantes media,baja
aplanar_dome.py 15-Recursos veta_oro_lowpoly Roca 0.045 2 (todas las variantes en una corrida)
```

Resultados:

| asset | variante | pre→post toca | pre→post footprint | z_min |
|-------|----------|----------------|---------------------|-------|
| veta_hierro | source | 1 → 16 | 0.000×0.000 → 2.31×2.00 | 0.0450 |
| veta_hierro | _media | 1 → 16 | 0.000×0.000 → 2.31×2.00 | 0.0450 |
| veta_hierro | _baja | 1 → 21 | 0.000×0.000 → 2.50×2.23 | 0.0450 |
| veta_oro | source | 1 → 16 | 0.000×0.000 → 1.84×1.95 | 0.0450 |
| veta_oro | _media | 1 → 16 | 0.000×0.000 → 1.84×1.95 | 0.0450 |
| veta_oro | _baja | 1 → 16 | 0.000×0.000 → 1.84×1.95 | 0.0450 |

### Capturas post-fix (verificadas visualmente)

- **veta_hierro_lowpoly (fuente)** `_hoja_cap_15_veta_hierro_lowpoly_03-17-01.jpg`: roca sentada con base hexagonal clara, cristales visibles como puntos oscuros. APROBADO.
- **veta_hierro_lowpoly_media** `_hoja_cap_15_veta_hierro_lowpoly_media_03-18-00.jpg`: misma base hexagonal, 3 cristales visibles al ras del suelo. APROBADO.
- **veta_hierro_lowpoly_baja** `_hoja_cap_15_veta_hierro_lowpoly_baja_03-18-17.jpg`: base un poco más ancha (decimate más agresivo generó más verts en el ecuador), silueta tipo "roca achatada". APROBADO.
- **veta_oro_lowpoly_baja** `_hoja_cap_15_veta_oro_lowpoly_baja_03-21-37.jpg`: roca achatada con pequeñas pepitas amarillas asomando del top. La base se ve claramente plana. APROBADO.

## RE-EXPORT A GODOT

`exportar_godot.py` con `EXPORT_MODULOS=15-Recursos EXPORT_FORZAR=1` en headless (E-45 + E-49):

- 30 GLBs exportadas (10 assets × 3 variantes), 0 errores.
- `15-Recursos_veta_hierro.glb`: alta 27KB 6obj · media 22KB 3obj · baja 18KB 3obj.
- `15-Recursos_veta_oro.glb`: alta 40KB 8obj · media 34KB 3obj · baja 28KB 3obj.
- mtime actualizado en `game/isla-ancestral/assets/3d/{alta,media,baja}/`.

## DECISIONES TOMADAS

- ✅ `veta_hierro` ahora APROBADO visualmente (3 variantes, E-13 6 capturas OK).
- ✅ `veta_oro` también fix por consistencia (misma estructura huso).
- ⏸ `veta_cobre`, `roca_comun`, `roca_pedernal` también tienen E-50 latente (toca=1, fp=0) pero **NO se les aplica el fix** porque:
  - Todos tienen un **anillo ecuatorial plano** (todos los vértices al mismo z, p.ej. veta_cobre anillo 3 todo a z=0.5903).
  - Ese flat-top hace que el ojo lea el disco de arriba y apruebe el apoyo en single vertex.
  - El cambio rompe working assets sin ganancia visual clara.
- ⏸ `veta_cobre` futura ALTA: si se re-diseña, planear base hexagonal desde el origen (no esperar al fix posterior).

## DOCUMENTACIÓN ACTUALIZADA

- **`DOCUMENTACION/09-GUIA-BLENDER.md`** — agregados E-46 (auditor desincronizados, ya documentado en memoria pero faltaba en guía), E-47 (nombre de fuente `N_lowpoly.blend`), E-48 (re-asentado derivados), E-49 (mtime-skip miente), E-50 (apoyo puntual en domo), E-51 (vecindario por BFS, no XY). Changelog 03:25 agregado al final. Fecha de última actualización movida a 2026-08-31 03:25.
- **`tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`** — entrada de `veta_hierro` con v3 (fix E-50) y `veta_oro` con v3 (idem).
- **`.workbuddy-ai/memory/MEMORY.md`** — ya tenía E-50 desde la sesión 01:00, ahora agregados E-47/48/49/51.

## PENDIENTE PRÓXIMO ARRANQUE

- **QA visual MEDIA** (41 assets) — `qa_lote.py [modulos...] --variante media --angulos 6`. Sin esto no se cierra M166.
- **QA visual ALTA** (17 assets) — `qa_lote.py --variante alta --angulos 6`. Son las pasadas artísticas pendientes (M166 §3.3).
- **`auditar_desincronizados.py`** confirma 0 desincronizadas (corrida a 03:23: `Assets auditados : 69 · Variantes desincronizadas : 0`).
- Eliminar temporales que ya no se usan: `dump_anillos.py` (sí usado en diagnóstico, **puede quedarse**), `diag_apoyo.py` (útil para futuro, **renombrar a `diag_apoyo.py`**), `aplanar_dome.py` (útil, **renombrar a `aplanar_dome.py`**).