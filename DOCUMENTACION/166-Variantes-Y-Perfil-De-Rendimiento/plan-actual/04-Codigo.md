# 04-Codigo — M166 · Variantes de Assets por Perfil de Rendimiento

**Módulo:** 166 · **Estado:** plan-actual · **Piloto:** cofre ancestral aprobado · **Fecha:** 2026-08-28

## Concepto clave: dos ejes, no uno

El módulo tiene **dos ejes independientes** y confundirlos es el error de la primera versión:

| Eje | Qué cambia | Quién lo hace | Se ve | Se mide |
|---|---|---|---|---|
| **Nivel de detalle** (variante) | Triángulos, suavidad, piezas modeladas | **Hand-authored**: MEDIA = asset actual, ALTA = pasada futura, BAJA = MEDIA + poda/decimate | ✅ Sí | Triángulos |
| **Draw calls** (exportación) | Cantidad de mallas separadas | **Automático, gratis**: `merge por material` se aplica a las 3 variantes | ❌ No | FPS, draw calls |

El merge por material es una **etapa de exportación** que se aplica a las 3 variantes. No es una variante. Por eso `stats_asset.py` corre con la malla ya mergeada, y el límite de objetos se evalúa después del merge.

## Archivos involucrados

### Scripts nuevos (M166)
- `tools/mcp/blender-mcp/scripts-reutilizables/stats_asset.py` — Mide obj / tris / verts / mats y compara contra el presupuesto M166 (tabla corregida: ALTA ≤16/≤6000/≤12, MEDIA ≤8/≤1500/≤8, BAJA ≤6/≤700/≤4).
- `tools/mcp/blender-mcp/scripts-reutilizables/generar_variante.py` — Genera MEDIA y BAJA desde un .blend source. Sub-comandos `--media` y `--baja`.
- `tools/mcp/blender-mcp/scripts-reutilizables/abrir_blend.py` — Abre un .blend en la sesión activa de Blender vía el socket MCP.

### Script modificado (M166)
- `tools/mcp/blender-mcp/scripts-reutilizables/capturar_angulos.py` — Activa `eevee.use_ssr`, `use_ssr_refraction` y `use_raytracing` antes de cada `bpy.ops.render.render()` (E-20). Sin esto, los materiales con metallic/coat se ven planos y el QA falla.

## Variantes según el modelo corregido

### MEDIA = asset actual + merge
- **Source**: el .blend del asset actual (ej. `cofre_ancestral_lowpoly.blend` con 33 objetos / 784 tris).
- **Operación**: solo `merge por material`. La imagen es idéntica al source; los draw calls bajan 82%.
- **Output verificado** (cofre): **6 obj / 784 tris / 6 mats** (vs 33 obj source).
- **z_min**: 0.045 (sin flotación, re-asentado automático).

### BAJA = asset actual + poda + decimate + merge
- **Source**: el mismo .blend del asset actual.
- **Operaciones**:
  1. Poda de piezas con bbox < 1e-4 m³ (≈ cubo 4.6 cm): glifos, tirador, etc.
  2. Merge por material sobre lo que queda.
  3. DECIMATE ratio 0.7 sobre las mallas fundidas (no sobre el source).
- **Output verificado** (cofre): **6 obj / 571 tris / 6 mats**.
- **z_min**: 0.045.

### ALTA = pasada artística futura + merge (NUNCA generada por script)
- La ALTA **no se deriva**: se modela a mano como una mejora del asset.
- Se espera ~80 objetos / ~4.000 tris en el .blend source.
- Al exportar, se le aplica el mismo merge por material → ~12 obj.
- Por qué existe el veredicto ALTA en `stats_asset.py`: si la ALTA mergeada da OK en el perfil MEDIA, **la pasada artística no agregó suficiente detalle y hay que seguir trabajando** (03-Diseno.md §3.3).

## Funciones clave de `generar_variante.py`

### Constantes calibradas sobre el cofre ancestral

```python
PROTEGIDAS = ('Pie', 'Base', 'Soporte', 'Tronco', 'Poste', 'Cuerpo', 'Tapa')
# Piezas estructurales que NUNCA se podan aunque sean chicas.

CRITICAS_NO_FUNDIR = ()
# Por defecto VACÍA. En la primera versión del módulo se usó para excluir
# costillas/cerradura/gema del merge, pero descubrimos que con DECIMATE 0.7
# (no 0.5) y merge por material (lossless), esas piezas sobreviven bien y
# excluirlas costaba 8 draw calls extra. Esta lista queda como override por
# asset: si un asset específico tiene piezas que sí se rompen, agregarlas acá.

UMBRAL_PODA = 1e-4
# Volumen de bbox en m³ por debajo del cual una pieza se considera "detalle
# prescindible" en BAJA. 1e-4 m³ ≈ cubo de 4.6 cm. Calibrado sobre el cofre.

DECIMATE_RATIO = 0.7
# 0.5 es demasiado agresivo sobre mallas planas (cajas de 6 caras): las rompe.
# 0.7 mantiene ~550-600 tris sin destruir la silueta ni los paneles planos.
```

### Pipeline de 4 fases (orden estricto)

1. **FASE 0 — PODA (solo BAJA, ANTES del merge)**
   - Filtra `SM_*` no críticos, no protegidos, con `volumen_bbox < UMBRAL`.
   - Borra con `bpy.data.objects.remove(o, do_unlink=True)`.
   - **Orden importa**: si se poda después del merge, las piezas ya no existen como objetos separados y no hay forma de filtrarlas.

2. **FASE 1 — MERGE POR MATERIAL (MEDIA y BAJA)**
   - Agrupa los `SM_*` por la tupla de sus materiales.
   - Para cada grupo, crea un `bmesh`, copia los vértices en coords de mundo (`mw @ v.co`), recrea las caras preservando `material_index`.
   - Bakes a `location = (0, 0, 0)` y `scale = (1, 1, 1)` (E-18 a favor).
   - Libera hijos antes de borrar padres (huérfanos).
   - Output: `MERGE: 33 objetos -> 6 mallas`.

3. **FASE 2 — DECIMATE (solo BAJA, sobre mallas fundidas)**
   - DECIMATE ratio 0.7, `use_dissolve_boundaries = False`.
   - Aplica por depsgraph, no por `bpy.ops` (E-22: `poll() failed` por socket).
   - Reasigna materiales y limpia modifiers.
   - Output: `DECIMATE BAJA: ratio 0.70 aplicado a 6 mallas fundidas`.

4. **FASE 3 — RE-ASENTADO (E-12)**
   - `shade_flat()` sobre todos los `SM_*`.
   - Mide `z_min` global; traslada los sin padre a `Z_APOYO = 0.045`.
   - Output: `RE-ASENTADO: z_min 0.045 -> 0.045 (delta -0.000)`.

5. **FASE 4 — GUARDADO**
   - `os.remove(RUTA_SALIDA + '@')` si existe (E-21).
   - `bpy.ops.wm.save_as_mainfile(filepath=RUTA_SALIDA)`.

## Tabla de presupuestos M166 (en `stats_asset.py`)

```python
PRESUPUESTO = {
    'ALTA':  {'objetos': 16, 'tris': 6000, 'materiales': 12},
    'MEDIA': {'objetos': 8,  'tris': 1500, 'materiales': 8},
    'BAJA':  {'objetos': 6,  'tris': 700,  'materiales': 4},
}
```

Si un asset ALTA mergeado da **OK en el perfil MEDIA**, la pasada artística no agregó suficiente detalle (criterio 03-Diseno.md §3.3).

## Datos verificados del piloto (cofre ancestral)

| Variante | Objetos | Triángulos | Materiales | z_min | Estado |
|---|---|---|---|---|---|
| Source (asset actual) | 33 | 784 | 6 | 0.045 | Hand-authored |
| MEDIA (merge) | 6 | 784 | 6 | 0.045 | ✅ OK MEDIA |
| BAJA (poda + merge + decimate) | 6 | 571 | 6 | 0.045 | ✅ OK BAJA |
| ALTA (futura) | ~12 (tras merge) | ~4.000 | ~12 | 0.045 | Pendiente pasada |

Capturas de QA: `tools/mcp/blender-mcp/25-Ruinas-Templos/capturas/cap_25_cofre_{MEDIA,BAJA}_21-50-00_az*.png`.

## Logs relacionados

- `Logs/273-M166-Modulo-Variantes-Perfil-Rendimiento-2026-08-28_21-30-00.md` — Creación del módulo + iteración correctiva.
- `Logs/207-M25-Cofre-Ancestral-v2-Detalles-Brillo-2026-08-28_20-30-00.md` — Iteración del cofre v2.0→v2.2 (33 piezas con materiales emisivos), fuente del asset piloto.

## E-22 — `bpy.ops.object.modifier_apply.poll()` falla por socket MCP

**Síntoma**: `Operator bpy.ops.object.modifier_apply.poll() failed, context is incorrect`.

**Causa**: `bpy.ops.object.*` requiere un contexto activo (viewport, objeto activo) que el socket no provee.

**Solución**: aplicar el modificador evaluando el depsgraph y reasignando la malla:
```python
dg = bpy.context.evaluated_depsgraph_get()
me_eval = bpy.data.meshes.new_from_object(o.evaluated_get(dg))
mats = [m for m in o.data.materials if m is not None]
o.data = me_eval
for m in mats:
    o.data.materials.append(m)
o.modifiers.clear()
```

## E-23 — Decimate agresivo (ratio 0.5) destruye mallas planas lowpoly

**Síntoma**: tras `DECIMATE ratio=0.5` sobre mallas con cajas de 6 caras, las caras quedan como triángulos grandes rotos.

**Causa**: `DECIMATE` colapsa vértices sin respetar aristas duras. Las cajas grandes se deforman.

**Solución**:
1. Subir el ratio a 0.7.
2. (Opcional) `CRITICAS_NO_FUNDIR` para piezas que aún así se rompen en algún asset.

## E-20 refinado — SSR en el script de captura

**Síntoma**: variantes con menos objetos se ven planas (sin highlights).

**Causa**: `capturar_angulos.py` no activaba SSR/raytracing.

**Solución**: bloque try/except antes de `bpy.ops.render.render()`:
```python
try:
    escena.eevee.use_ssr = True
    escena.eevee.use_ssr_refraction = True
    escena.eevee.use_raytracing = True
except Exception:
    pass
```

## Comandos de uso

```bash
cd tools/mcp/blender-mcp/scripts-reutilizables

# 1) Verificar coste del source (asset actual, antes de merge)
python stats_asset.py SM_Cofre_ ../25-Ruinas-Templos/cofre_ancestral_lowpoly

# 2) Generar variantes
python generar_variante.py 25-Ruinas-Templos cofre_ancestral_lowpoly --media --baja

# 3) QA visual de MEDIA
python abrir_blend.py 25-Ruinas-Templos cofre_ancestral_lowpoly_media
python stats_asset.py SM_Cofre_                        # debe dar OK MEDIA
python capturar_angulos.py SM_Cofre_ ../25-Ruinas-Templos/capturas/cap_25_cofre_MEDIA.png 6

# 4) QA visual de BAJA (mismo flujo)
```


## Notas del Agente

**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-18 20:55
**Estado:** Parcial (parte de copyright verificada y documentada; H12 sigue pendiente del dueño)

### Lo que hice (Log 1035)
- Auditoría empírica .glb por .glb de la deuda de copyright M127 (Log 1022): **0 de 694 .glb
  versionados tiene atribución por-archivo** (sidecars, extras GLB, catálogos data/legal).
  Scope del claim: **434 en assets/3d = 418 activos + 16 respaldos media/Obsoletos/** —
  el crecido 418→434 no son assets nuevos. Origen de los 694: propio (Blender MCP,
  generator Khronos I/O 4.2.83, commits pipeline). Herramientas: scripts/auditar_copyright_glb.py
  y scripts/auditar_flotacion_glb.py + JSONs en tools/legal/.
- QA visual V2-asistencia de capturas orbitales M16/M19/M25/M33/M51: 7 artefactos
  V-1..V-7 (BUG-053), el destacado: antorcha_pared flota 30 cm (único glb con cota
  positiva del repo).

### Lo que NO hice (honestidad obligatoria)
- H12 (pasada ALTA 15 héroes): requiere V5/Blender — sigue con mimo-v2.5/Hy4.
- No toqué los 4 scripts de variantes ni mallas/GLB.
- Fix del pipeline de exportación (embeber asset.copyright) NO lo ejecuté: es trabajo de
  pipeline (dueño M166/M09) y fuera de mi alcance (EVITAR: no modificar GLB).

### Recomendaciones para el próximo agente
1. Fix BUG-052 (dueño pipeline M166/M09): agregar asset.copyright/license al exportador
   glTF y re-exportar los 418 activos; dejar el techo 418 en asset_metadata_scope.json
   (los 16 Obsoletos ya quedan excluidos por el scan).
2. V-3 (BUG-053): decidir el destino de antorcha_pared — sacarla de assets/3d (librería
   de suelo) o montar runtime sobre pared (E-80, Empty de referencia).
3. V-1: re-derivar hacha_piedra media/baja en la pasada H12 (verificar blend-mode/decimate).

## Notas del Agente — H12 + des-inflado F1/F4 (2026-10-11)

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 21:30:00
**Estado:** H12 completado; F1 y F4 des-inflados a [?]

### Lo que hice
- **Verifique la pasada ALTA en disco:** los 17 `_alta.blend` existen en `tools/mcp/blender-mcp/<modulo>/` y los 17 GLB estan exportados en `game/isla-ancestral/assets/3d/alta/`. La parte Blender de H12 (que el checklist reclamaba para Hy4) ya estaba completa — era evidencia faltante, no trabajo faltante.
- **Agregue los 3 campos M166 a `game/isla-ancestral/scripts/data/item_data.gd`:** `modelo_id` (String), `usa_multimesh` (bool), `variantes_disponibles` (PackedStringArray, default `["media","baja"]` segun H10/D9 — el relleno sin ALTA no es un hueco).
- **Declare los 3 heroes con match inequivoco** en sus `.tres`: `ancient_crystal.tres` y `item_obj_art_003.tres` (`cristal_ancestral`), `item_obj_her_002.tres` (`pico_hierro`), `item_obj_ext_002.tres` (`farola_fuego`) — todos con `variantes_disponibles = ["alta","media","baja"]` y `modelo_id` seteado.
- **Test headless nuevo:** `game/isla-ancestral/tests/test_m166_h12_variantes.gd` — 253 checks / 0 fallos / EXIT 0 con Godot 4.7.2 real. Verifica: campos existen, default correcto, heroes declaran ALTA, los 3 GLB existen en `assets/3d/alta/`, y ningun item de relleno declara ALTA sin `modelo_id`.

### Lo que NO hice (honestidad obligatoria)
- **No implemente el autoload `AssetProfile` (F1).** Esta des-inflado: el checklist lo tenia `[x]` pero NO hay script ni entrada en `project.godot`. Solo existe el diseño en `03-Diseno.md` §4 (deteccion hardware, `ruta()`, `cargar()`, `cambiar_perfil()`, degradacion graceful). Es trabajo de integracion runtime — mejor perfil DeepSeek/Step 5 que el mio.
- **No mapee los 14 heroes restantes.** La mayoria son props del mundo (totem_isla, monolito_glifos, altar_ritual, anillo_piedras_ritual, puerta_templo, bote_pesca, muelle_madera, concha_mar, palanca_madera, pico_piedra, antorcha_mano, hacha_piedra, lingote_metal, cofre_ancestral) que NO tienen item de inventario M159 — setearles `variantes_disponibles` requiere decidir primero donde viven (catalogo de props vs M159), y eso es decision del director, no mia.
- **No toque los 4 scripts Python** del modulo (stats_asset, generar_variante, capturar_angulos, abrir_blend) — intactos.

### Intentos fallidos / decisiones
- Mi primera estimacion ("3 cambios de codigo puro") fue incompleta: confie en los `[x]` del checklist sin verificar disco. Al investigar encontre F1 y F4 inflados. Correccion: verifique antes de prometer (regla §21.8.2.b — muestrear [x] contra artefactos).
- El test fallo 2 veces antes de pasar: (1) `PackedStringArray("a","b")` no es constructor valido en Godot 4 → `PackedStringArray(["a","b"])`; (2) `instancia.free()` en RefCounted es error; (3) conteo de items vs modelo_ids unicos (cristal_ancestral esta en 2 .tres).

### Recomendaciones para el proximo agente
- **Prioridad: implementar el autoload `AssetProfile` (F1).** Toma el diseño de `03-Diseno.md` §4.2: tabla de hardware (Apple M → media, VRAM <2GB → baja, 2-4GB → media, >4GB → alta, mobile → baja, GPU blacklist → baja), fallback conservador media, `ruta(modelo_id)` que resuelve `res://assets/3d/{perfil}/{Modulo}_{asset}.glb` y degrada al perfil mas alto disponible si `variantes_disponibles` no contiene el activo. Test de extension natural: mockear `OS.get_processor_name()` / memoria de video.
- **Mapeo de los 14 heroes restantes:** decidir con el director si los props del mundo (totem, monolito, altar) viven en M159 como items o en un catalogo de props separado (M108/M10 los coloca). Solo entonces setear `variantes_disponibles`.
- **QA §21.8 de este cierre:** el verificador debe ser otro modelo (Hy3 o DeepSeek) — yo escribi el test, no puedo verificarme a mi mismo.
- **No revivir la idea de que H12 necesita a Hy4:** la pasada artistica ya esta. Hy4 si hara falta para M45/M48-Fase3 (rigging + animacion del jugador voxel), no para aca.
