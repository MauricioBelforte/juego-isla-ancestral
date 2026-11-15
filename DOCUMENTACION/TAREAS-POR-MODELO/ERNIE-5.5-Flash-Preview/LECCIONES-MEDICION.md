# Lecciones de medicion — ERNIE-5.5-Flash-Preview

**Proposito:** que la proxima sesion no repita los tres errores que me costaron un diagnostico
invertido y una retraccion el 2026-11-13/14. **No es un backlog**: lo mantiene el agente, no el director.

## E-24 me mordió tres veces (error mas caro de mi nicho)

### 1. Medir vertices, jamas esquinas de AABB, en geometria rotada

Transformar las 8 esquinas del `bound_box` (o del AABB del accessor) por la matriz del nodo da un
**minimo FALSO**: en objetos rotados las esquinas se van por debajo de la malla real.

Con ese metodo "diagnostique" 5 assets hundidos que **estaban perfectos**:

| Asset | Mi medida falsa | Medida real (vertices) |
|---|---|---|
| `perla_ancestral` | −0,586 | **+0,0450** |
| `globo_del_viento` | −0,336 | **+0,0450** |
| `roca_pedernal` | −0,292 | **+0,0450** |
| `roca_comun` | −0,109 | **+0,0450** |
| `conejo` (alta) | −0,170 | 0,0000 (este si estaba afuera) |

**Regla:** el `z_min` se calcula sobre vertices. Para GLB: leer el accessor `POSITION`
(componentType 5126 float32, VEC3) y aplicar la matriz del nodo **por vertice**.

### 2. `bpy.data.libraries.load()` NO vincula a la escena

Sin link, `matrix_world` queda **stale** y el bbox sale mal. Caso: `SM_Roca_Comun_Chica` daba
`−0,7389` y con link explicito da `+0,0450`.

```python
with bpy.data.libraries.load(ruta) as (src, dst):
    dst.objects = list(src.objects)
for o in dst.objects:
    if o and o.name not in bpy.context.scene.collection.objects:
        bpy.context.scene.collection.objects.link(o)
bpy.context.view_layer.update()
```

### 3. Leer el docstring del helper ANTES de recetar

`tools/mcp/blender-mcp/scripts-reutilizables/corregir_asset.py` L71-75 documentaba E-24 con el
caso exacto de `roca_comun`. Lo cite en un mensaje y volvi a caer en la misma trampa al medir el GLB.

### 4. Respaldo: nunca carpeta plana con nombres repetidos

Copie `alta/` + `media/` + `baja/` de GLB a **una sola carpeta**. Los tres LOD tienen el **mismo
nombre de archivo** → `media` y `baja` pisaron a `alta` → quedaron **27 de 78**. Respaldo inservible.
Para respaldar LODs: preservar la estructura de carpetas o renombrar con sufijo.

### 5. El acuse de exito se escribe despues de verificar

Lei "76 exportados, 0 errores" y casi declaro exito. `git status -- game/isla-ancestral/assets/3d`
dio **0 archivos modificados**: el re-export fue un no-op y los GLB ya estaban al dia.

## Metodo de medicion correcto (reusable)

| Objeto | Metodo |
|---|---|
| `.blend` | `libraries.load` + **link a `scene.collection.objects`** + `view_layer.update()` + `evaluated_get(depsgraph)` + `to_mesh()` (vertices reales) |
| `.glb` | parsear JSON + BIN, accessor `POSITION`, matriz del nodo **por vertice** (script: `auditar_glb_vertice.py`, pendiente de graduar a `scripts-reutilizables/`) |
| Excluir siempre | `Base_Arena` y demas piezas del **set de captura** (no son parte del asset) |

## Convencion del proyecto (no es un bug)

**`Z_APOYO = 0,045`** con tolerancia `±0,020`. Un `z_min` de 0,045 es **correcto**, no "flotando".
Esta en `tools/mcp/blender-mcp/REPORTE-FLOTANTES.md`. Mi primer diagnostico compare contra 0 y
reporto 458 assets "flotando": eran la convencion, no un defecto.

## Estado del tooling (2026-11-14)

- **`exportar_godot.py` no corre desde el addon MCP**: `AttributeError: 'Context' object has no
  attribute 'active_object'` en `io_scene_gltf2`. Usar headless:
  `blender -b --factory-startup --python exportar_godot.py` con `EXPORT_*` por env.
- **3 scripts no compilan** (SyntaxError, mojibake en docstrings): `corregir_asset.py` L62,
  `asentar_en_base.py` L35, `auditar_apoyos.py` L57. Reportados a agnes para DS-OC.
- `exportar_godot.py` saltea por mtime (E-49) salvo `EXPORT_FORZAR=1`.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-14 02:50