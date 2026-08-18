**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 45: Arte 3D

> Rutas previstas dentro de `Assets/_Project/` (estructura del proyecto Godot 4.x, ver AGENTS.md §24).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Scripts de editor (GDScript, tipado) — `Assets/_Project/Editor/`

| Archivo | Propósito | Estado |
|---|---|---|
| `validate_mesh.gd` | Validador de assets: escala, tris, topología, UVs, LODs (RF14) | Pendiente de implementación |
| `asset_catalog.gd` | Gestor del catálogo de assets (RF13): alta, estados, consultas | Pendiente de implementación |
| `generate_lod.gd` | Helper de decimación y exportación de LOD1/LOD2 (RF9) | Pendiente de implementación |

### 1.2 Documentación viva — `Docs/`

| Archivo | Propósito | Estado |
|---|---|---|
| `ART_STYLE_3D.md` | Guía de estilo única: siluetas, proporciones, paleta por bioma, reglas (RF1) | Pendiente de implementación |
| `ASSET_REVIEW.md` | Checklist de revisión de asset (RF17) | Pendiente de implementación |

### 1.3 Carpetas de contenido — `Assets/_Project/Models/`

| Carpeta | Contenido | Estado |
|---|---|---|
| `characters/` `animals/` `buildings/` `furniture/` `tools/` `vehicles/` `vegetation/` `props/` `ruins/` `temples/` `decorations/` `interactives/` | Mallas `.glb` por categoría (RF15) | Vacía — pendiente de producción de assets |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- validate_mesh.gd (EditorPlugin/EditorImportPlugin) ----------
class_name MeshValidator
extends RefCounted

const ESCALA_TOLERANCIA := 1e-3
const TECHOS := {
    "chr_": 8_000, "npc_": 6_000, "ani_": 2_500, "bld_": 15_000,
    "furn_": 800, "tool_": 600, "veh_": 12_000, "veg_": 3_000,
    "prop_": 1_200, "ruin_": 14_000, "temple_": 14_000, "dec_": 800,
}

func validar(mesh: ArrayMesh, categoria: String, tris_max: int) -> Array[String]:
    # Devuelve lista de errores (vacía = OK); acumula TODOS los errores
    var errores: Array[String] = []
    # 1) escala: cada SurfaceTool debe estar en escala 1:1
    # 2) tris: mesh.get_faces().size() / 3 <= tris_max
    # 3) topología: recorrer índices, detectar n-gons (fan de 4+ usando la misma normal)
    #    y vértices duplicados (posición+normal idénticas)
    # 4) UVs: fuera de [0,1] salvo flag atlas; padding mínimo 4 px
    # 5) LOD: si tris > 500, buscar variantes lod1/lod2 en el mismo asset
    # 6) origen: si categoria in ["prop_", "dec_", "bld_", "furn_"], Y origen ~ 0
    return errores
```

```gdscript
# ---------- asset_catalog.gd (EditorPlugin) ----------
class_name AssetCatalogDB
extends RefCounted

const RUTA_CATALOGO := "res://Assets/docs/asset_catalog.json"

class Entrada:
    var asset_id: StringName
    var categoria: String      # "chr_", "prop_", ...
    var bioma: StringName     # "pradera", "bosque", ...
    var estado: String        # planned|made|reviewed|imported
    var duenio: String
    var prioridad: String     # alta|media|baja
    var deps: Array[StringName] = []

func registrar(entrada: Entrada) -> void:
    # valida: id único, prefijo de categoría correcto (RF15), estado válido
    pass

func consultar(filtro_categoria: String = "") -> Array[Entrada]:
    pass
```

```gdscript
# ---------- generate_lod.gd (EditorTool) ----------
class_name LodGenerator
extends RefCounted

func generar_lods(ruta_glb: String) -> Array[String]:
    # 1) importar malla, 2) decimar al 50% y 20% (SurfaceTool / QuadMeshUtil)
    # 3) exportar variantes lod1/glb y lod2/glb junto a la original
    # 4) devolver rutas generadas (o errores accionables)
    pass
```

## 3. Señales y Eventos

Como módulo de contenido/herramientas, no expone señales de runtime. La "comunicación" se da por:

| Evento | Emisor | Consumidor |
|---|---|---|
| `asset_importado(asset_id, resultados)` | Importador (M108) | Catálogo actualiza estado a `imported` |
| `asset_rechazado(asset_id, errores)` | Validador | Log de editor (M103), bug tracking (M102) |
| `catalogo_actualizado(asset_id)` | Catálogo | Logging de editor |

## 4. Logs Relacionados

Este módulo (como M47/mesh pipeline) participará del sistema de logging para *editor*:

| Log | Contexto | Nivel |
|---|---|---|
| `ART-3D-IMPORT` | asset importado con éxito (id, tris, LODs) | INFO |
| `ART-3D-REJECT` | asset rechazado por el validador (id y errores) | WARN |
| `ART-3D-LOD` | generación de LODs completada | INFO |
| `ART-3D-CATALOG` | alta/actualización de entradas de catálogo | INFO |

## 5. Dependencias de Implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (>= 4.4.1) | M04 | Importador glTF, editor tools |
| Métrica voxel 1 m | M08 | Alineación de props, escala de personaje |
| Presupuestos de frame | M61 | Techos de polígonos y LOD distances |
| Pipeline de assets | M108 | Import settings, compresión, convenciones |
| Texturas | M47 | Slots de material, atlas |
| Git LFS | M06 | Trackear `.blend` y `.glb` |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentado (diseño completo, checklist completo en 05-Checklist.md)

### Lo que hice
- Documentación completa del módulo 45-Arte 3D (5 archivos en plan-inicial y plan-actual).
- Guía de estilo "Cozy Voxel" (voxel + low-poly redondeado), techos de polígonos por categoría, LODs, sockets, kit modular y validador de assets.
- Mapeo de la sección 44 "ARTE 3D" del plan maestro al ID 45 de CHECKLIST-GLOBAL (desfase de numeración: el plan inicial tiene 44=ARTE 3D, 45=ARTE 2D; la tabla global los reordenó).
- Integrado a la arquitectura existente (M04/M08/M61/M108/M47/M48) y al flujo de producción del plan (Blender, Git LFS, uso de IA como base con review).

### Lo que NO pude hacer
- No implementé `validate_mesh.gd` ni `asset_catalog.gd` (son herramientas de editor; se implementarán con el proyecto Godot en el hito M1).
- No produje assets 3D (requiere Blender/artista; fase de producción).

### Recomendaciones para el próximo agente
- Al crear el proyecto Godot (M1), implementar primero `validate_mesh.gd` con la tabla de techos y un prop de prueba end-to-end.
- Definir `ART_STYLE_3D.md` con paletas concretas de los 13 biomas (insumo de M09) antes de producir la primera tanda de assets.
- Coordinar con M108 la configuración de importación glTF (no embeker texturas, aplicar compresión, generar LODs con el helper).
- Considerar QA cruzado (sección 21.8) de este módulo por otro modelo.