# 380 — Cierre administrativo Tier E (M18), cierre Tier F (M50), y corrección del falso E-64

- **Fecha:** 2026-09-01 12:20 (hora local real del sistema)
- **Agente:** MiniMax-M3 · WorkBuddy AI · Windows
- **Módulos tocados:** M18 Casas, M50 Vegetación
- **Estado final:** Tier E 100% · Tier F 100% · Import Godot 198/198

---

## 1. Resumen ejecutivo

Se cerró el **Tier E (M18 Casas)** en su totalidad — no solo la autoría, sino la
administración: variantes MEDIA/BAJA, export de 33 GLB e import en Godot. Se cerró
el **Tier F (M50 Vegetación)** con 3 assets reales (el backlog mentía: decía 5, dos
eran duplicados rancios). En el camino aparecieron **4 errores nuevos documentados**
(E-62, E-63, E-64, E-65), dos de los cuales eran bugs reales del pipeline y dos son
correcciones a diagnósticos míos equivocados.

**Lo más importante de esta sesión:** el E-64 que publiqué a las 05:00 era
**FALSO** y lo corregí a las 12:20. Nunca hubo un import bloqueado. Ver §4.

---

## 2. Tier E (M18 Casas) — cierre administrativo

Con Blender GUI abierto se desbloqueó **E-56** (`generar_variante.py` exige socket),
lo que permitió derivar las variantes que faltaban de los 11 assets.

| Métrica | MEDIA | BAJA | Presupuesto M166 §3.3 |
|---|---|---|---|
| Objetos | ≤6 | ≤6 | ≤8 / ≤6 |
| Triángulos | ≤212 | ≤144 | ≤1500 / ≤700 |
| Materiales | ≤6 | ≤4 | ≤8 / ≤4 |

Resultado: **33 GLB** en `assets/3d/{alta,media,baja}/18-Casas_*.glb` y **33
`.import`** generados por Godot a las 21:02.

### E-62 — `generar_variante.py` re-asentaba INCONDICIONALMENTE

- El script calculaba `delta = Z_APOYO - z_min` y lo aplicaba sin más.
- Para `techo_dos_aguas` (que por **E-60** se apoya sobre las PAREDES, no sobre la
  arena) eso daba `delta = 0.045 − 2.645 = −2.600` → **hundía el techo 2.6 m**.
- **Fix:** umbral `UMBRAL_REASENTADO = 0.25`. Si `|delta|` lo excede, se omite el
  re-asentado y se avisa. 0.25 m es generoso para un mal apoyo y está a años luz de
  2.6 m.
- **Verificación:** `techo_dos_aguas` alta/media/baja, las tres en `z_min 2.6450`
  → sin salto de LOD (**E-48**) y sin entierro.
- Es la contrapartida exacta de E-60: arreglar uno sin el otro hace reaparecer el
  bug en el eslabón que quedó.

### E-63 — `exportar_godot.py` tiene whitelist de módulos

- `MODULOS = (...)` es una **whitelist**. Un módulo nuevo que no esté en la tupla
  **nunca se escanea**, y el resumen dice `{"exportados": 0, "saltados": 0,
  "errores": 0}` sin un solo warning.
- `18-Casas` no estaba. Se agregó.
- **Defensa adoptada como obligatoria:** `EXPORT_DRY=1` siempre antes del export
  real, comparando contra `assets × 3 variantes`.

---

## 3. Tier F (M50 Vegetación) — 3 assets

El backlog decía 5 pendientes. **2 eran duplicados rancios** (`Hongo luminoso`,
`Flor de isla`, ya marcados `[x]` más abajo en la misma lista). Pendientes reales: **3**.

| Asset | obj/tris/mats | z_min | Huella (toca) | bbox | M166 |
|---|---|---|---|---|---|
| `arbol_frutal` | 15 / 464 / 4 | 0.0450 | 0.68×0.72 (10) | 2.10×1.82×3.88 | OK ALTA |
| `musgo_roca` | 9 / 204 / 4 | 0.0450 | 1.00×1.00 (12) | 1.04×1.00×0.42 | OK ALTA |
| `raices_expuestas` | 6 / 106 / 2 | 0.0450 | 0.57×0.60 (15) | 1.32×1.99×0.24 | OK ALTA+MEDIA+BAJA |

Los 3 auditados con `chk_asset.py`, 6 capturas orbitales c/u (**E-13**), aprobados
por visión, variantes derivadas, 9 GLB exportados y 9 `.import` generados a las 21:16.

### Decisiones de diseño

- **`arbol_frutal`:** el lore no fija especie (`33-Agricultura` `is_tree` solo dice
  "perenne") y el coco ya lo cubre la palmera → **frutal de copa ancha con fruto
  tropical genérico**, silueta complementaria a la palmera. Faldón cónico
  (R 0.36→0.19, H 0.34) + 4 raíces acostadas + tronco 2.30 m + 3 ico-esferas de
  copa + 6 frutos ovalados.
- **`musgo_roca`:** descriptor dice "placa decorativa" → cilindro bajo de 12 lados
  (R 0.50, H 0.35) con jitter determinista en los vértices superiores (`seed(7)`).
- **`raices_expuestas`:** tocón cilíndrico + 5 raíces cónicas acostadas en abanico
  de 150°. **Única pieza del Tier F que cumple ALTA+MEDIA+BAJA sin merge.**

### El guard E-50 volvió a pagar la apuesta

Los 3 assets fallaron en su **v1** por apoyo puntual, y el assert los atrapó:

1. `arbol_frutal`: raíces inclinadas 62° bajaban a −0.0807 → el re-asentado
   levantaba todo +0.1257 y dejaba el tronco flotando. → rediseñadas acostadas.
2. `musgo_roca`: ico-esfera achatada → 1 solo polo sur tocando. → cilindro.
3. `raices_expuestas`: nudo como ico-esfera achatada → 6 verts tocando (<8). →
   cilindro (un tocón cortado ES naturalmente cilíndrico).

Guard canónico (mide en vértices reales, **E-24**, y exige huella, **E-50**):

```python
TOL = 0.005
pts = [o.matrix_world @ v.co for o in piezas for v in o.data.vertices
       if abs((o.matrix_world @ v.co).z - Z_APOYO) < TOL]
assert len(pts) >= 8,          'apoyo puntual: solo %d verts tocan (E-50)' % len(pts)
assert min(fp_x, fp_y) > 0.30, 'huella demasiado chica (E-50)'
```

---

## 4. E-64 / E-65 — el falso bloqueo del import (CORRECCIÓN)

### Lo que publiqué a las 05:00 y era falso

Vi 4 `ERROR:` de la GDExtension de voxel durante el `--headless --import`:

```
ERROR: Failed to open '.../bin/~libvoxel.windows.editor.x86_64.dll'.
ERROR: Error copying library: .../libvoxel.windows.editor.x86_64.dll
ERROR: Can't open GDExtension dynamic library: 'res://addons/zylann.voxel/voxel.gdextension'.
ERROR: Error loading extension: 'res://addons/zylann.voxel/voxel.gdextension'.
```

y concluí: *"el editor lockea la DLL → la GDExtension no carga → el import se
aborta → hay que cerrar el editor"*. **Falso.**

### E-64 (reformulado) — esos ERROR son RUIDO BENIGNO

- El editor abierto sí tiene tomada la DLL y la GDExtension de voxel sí falla al
  cargar, pero **importar un `.glb` no depende de la GDExtension**. El import se
  completa igual.
- **Evidencia:** con el editor abierto (PID 3672, 1.6 GB) entraron los **33 GLB de
  M18 a las 21:02** y los **9 de M50 a las 21:16** — 20 segundos después de cada
  export.
- **Consecuencia operativa: NO cerrar el editor del usuario para "desbloquear" el
  import.** Es pérdida de tiempo y una molestia injustificada.

### E-65 — la causa raíz de mi error

El sidecar de Godot se llama **`<asset>.glb.import`**, no `<asset>.import`. Mi
verificación fue:

```bash
ls 50-Vegetacion_*.import | wc -l     # → 0   ... porque el glob no matchea
```

Un glob `<modulo>_<asset>.import` **nunca matchea**. De ahí el "0 `.import`".

**Verificación correcta (incorporada a la guía):**

```bash
cd game/isla-ancestral/assets/3d
for v in alta media baja; do
  echo "$v: glb=$(ls $v/*.glb | wc -l)  import=$(ls $v/*.import | wc -l)"
done
# y por mtime: el .import tiene que ser POSTERIOR al .glb
date -r alta/50-Vegetacion_arbol_frutal.glb        '+%m-%d %H:%M:%S'
date -r alta/50-Vegetacion_arbol_frutal.glb.import '+%m-%d %H:%M:%S'
# y de humo: 3 .scn por asset en .godot/imported/
ls ../../.godot/imported/50-Vegetacion_arbol_frutal.glb-*.scn | wc -l   # → 3
```

### Verificación final del import

| Variante | GLB | `.import` |
|---|---|---|
| alta | 66 | 66 |
| media | 66 | 66 |
| baja | 66 | 66 |
| **Total** | **198** | **198** |

**Cobertura 100%. Cero pendientes de import.**

Triple confirmación independiente: **198 GLB / 198 `.import` / 198 `.scn`** en
`.godot/imported/` (3 `.scn` por asset, uno por variante: `arbol_frutal` 3,
`musgo_roca` 3, `raices_expuestas` 3, `techo_dos_aguas` 3).

Distribución de mtimes de los `.import`: 129 (Aug 30 00:1x), 15 (Aug 30 23:3x),
6 (Aug 31 03:3x), 6 (Aug 31 04:0x), **33 (Aug 31 21:02 = M18)**,
**9 (Aug 31 21:16 = M50)**.

---

## 5. Deudas residuales (no bloqueantes)

- **11 temporales `~libvoxel.windows.editor.x86_64.dll~RF<hex>.TMP`** en
  `addons/zylann.voxel/bin/`, **82 MB** acumulados desde el 26-ago. Son basura, no
  bloquean nada. Borrar con el editor cerrado, cuando sea conveniente.
- **`cristal_ancestral` MEDIA:** el GLB tiene 72 vértices degenerados en (0,0,0).
  Defecto del export, ALTA está OK. Sin resolver.
- **Working tree:** hay 335 cambios de otro modelo. **No se tocaron.** Commit y push
  deben ser selectivos.

## 6. Backlog restante

48 pendientes. Módulos libres: **M36 Fauna (9)**, **M45 Arte-3D (5)**,
**M27 Landmarks (5)**. M16/M40/M33/M25/M34 (31 obj) siguen en "esperar, no tocar".

---

## 7. Archivos modificados en esta sesión

**Scripts (reutilizables):**
- `tools/mcp/blender-mcp/scripts-reutilizables/chk_asset.py` — **creado** (promovido
  desde `_chk_asset_tmp.py`). Auditoría headless: triángulos reales vía
  `calc_loop_triangles()`, materiales por CARAS (**E-42**), `zmin_real()` (**E-24**).
- `tools/mcp/blender-mcp/scripts-reutilizables/generar_variante.py` — fix E-62.
- `tools/mcp/blender-mcp/scripts-reutilizables/exportar_godot.py` — fix E-63.

**Assets (nuevos):**
- `tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_arbol_frutal_lowpoly.py`
- `tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_musgo_roca_lowpoly.py`
- `tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_raices_expuestas_lowpoly.py`

**Documentación:**
- `DOCUMENTACION/09-GUIA-BLENDER.md` — E-62, E-63, E-64 (corregido), E-65, 4 ítems
  nuevos de checklist, pie actualizado.

**Checklists:**
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` — 3 items `[x]`, contadores
  114/66/48, Tier F cerrado, falso E-64 revertido, pie 2026-09-01 12:20.
- `CHECKLIST-GLOBAL.md` — filas M18 y M50 actualizadas, M50 liberado (sin agente).

**Generados:** 9 GLB + 9 `.import` (M50) · 33 GLB + 33 `.import` (M18).

