**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 47: Texturas y Materiales

> Rutas previstas dentro de `Assets/_Project/` (estructura del proyecto Godot 4.x, ver AGENTS.md §24).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Scripts de editor (GDScript, tipado) — `Assets/_Project/Editor/`

| Archivo | Propósito | Estado |
|---|---|---|
| `validate_material.gd` | Validador: resolución, alineación de atlas, naming, memoria (RF12/RF14) | Pendiente de implementación |
| `generate_textures.gd` | Generador procedural determinista de variantes por bioma (RF15) | Pendiente de implementación |

### 1.2 Shaders — `Assets/_Project/Shaders/`

| Archivo | Propósito | Estado |
|---|---|---|
| `agua.gdshader` | Material transparente con onda suave determinista (RF8) | Pendiente de implementación |
| `lava.gdshader` | Emisión con ruido desplazado (RF9) | Pendiente de implementación |
| `cristal.gdshader` | Transparencia + refracción ligera acotada (RF10) | Pendiente de implementación |
| `emisivo_ancestral.gdshader` | Glow de sellos/glifos/esporas (RF7) | Pendiente de implementación |

### 1.3 Contenido — `Assets/_Project/Textures/`

| Carpeta | Contenido | Estado |
|---|---|---|
| `atlas/bloques/` | Tiles 32 px por bioma + atlas_bloques.tres | Vacía — pendiente |
| `atlas/mobiliario/` `atlas/personajes/` `atlas/props/` | Atlas por categoría | Vacía — pendiente |
| `special/` | Materiales agua/lava/cristal/emisivos `.tres` | Vacía — pendiente |
| `procedural/` | Paletas `.tres` por bioma + script de generación | Vacía — pendiente |
| `budget/` | `texture_budget.json` (RF14) | Vacía — pendiente |

### 1.4 Documentación viva — `Docs/MATERIAL_STYLE.md`

| Archivo | Propósito | Estado |
|---|---|---|
| `MATERIAL_STYLE.md` | Guía: paleta, roughness, emisión, recetas por superficie | Pendiente de implementación |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- generate_textures.gd (EditorTool) ----------
class_name TextureGenerator
extends RefCounted

func generar_variantes(superficie_id: String, bioma: StringName,
        semilla_partida: int, variantes: int = 3) -> Array[String]:
    # 1) cargar paleta del bioma (.tres, M09): colores base + acentos
    # 2) generar ruido determinista: NoiseTexture2D con seed =
    #    hash(semilla_partida, superficie_id, bioma, variante_idx)
    # 3) repintar el tile base con la paleta (ColorMatrix / custom shader offscreen)
    # 4) exportar PNG a atlas/bloques/ con sufijo _v1.._v3
    # 5) devolver rutas generadas (o errores accionables)
    pass
```

```gdscript
# ---------- validate_material.gd (EditorPlugin) ----------
class_name MaterialValidator
extends RefCounted

const ATLAS_MAX := 2048
const RESOLUCIONES := {"bloque": 32, "mobiliario": 512, "personajes": 512, "props": 512}

func validar_textura(ruta: String, categoria: String) -> Array[String]:
    var errores: Array[String] = []
    # 1) dimensión: múltiplo de 4, <= ATLAS_MAX, == RESOLUCIONES[categoria] si aplica
    # 2) si es tile de atlas: verificar alineación a grilla (para bloques: mult. de 32)
    #    y que su región UV no solape otras (leer .tres del atlas)
    # 3) formato: PNG o WebP; mipmaps configurados en import (M108)
    # 4) naming: prefijos tex_/mat_/atlas_ según tipo (M108)
    # 5) memoria: sumar resolución^2 * 4 bytes (RGBA8) o comprimido; anotar en
    #    texture_budget.json; comparar escena pivote contra presupuesto M62
    return errores

func validar_material(mat: Material, escena_pivote: Node3D) -> Array[String]:
    # 1) shader en whitelist (agua/lava/cristal/emisivo_ancestral)?
    # 2) conteo de shaders costosos visibles en escena <= 2
    # 3) emisión <= 1.5 (evitar bloom agresivo, M49)
    # 4) si es StandardMaterial3D standard: compartido (no duplicado por instancia)
    return errores
```

```gdscript
# ---------- shader ejemplo: agua.gdshader ----------
shader_type spatial;
// solo blend premultiplied básico + normalmap animado por TIME (determinista
// por fase fija, sin RNG); profundidad de refracción nula (ver M51)

const WAVE_SPEED := 0.15;
// ...
```

## 3. Señales y Eventos

| Evento | Emisor | Consumidor |
|---|---|---|
| `atlas_actualizado(atlas_id, rutas)` | Generador/importador | Registro de presupuesto, logging M103 |
| `textura_rechazada(tex_id, errores)` | Validador | Bug tracking M102 |
| `presupuesto_excedido(escena, vram_mb)` | Validador | Alerta de editor, logging |

## 4. Logs Relacionados

| Log | Contexto | Nivel |
|---|---|---|
| `MAT-GEN` | variantes procedurales generadas (superficie, bioma, cantidad) | INFO |
| `MAT-IMPORT` | textura/material importado con éxito | INFO |
| `MAT-REJECT` | textura/material rechazado con errores | WARN |
| `MAT-BUDGET` | presupuesto de VRAM por escena actualizado | INFO |

## 5. Dependencias de Implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (>= 4.4.1) | M04 | StandardMaterial3D, ShaderMaterial, NoiseTexture2D |
| Atlas de bloques + semillas | M08/M10 | Estructura del atlas y determinismo |
| Paletas por bioma | M09 | Entradas de color de generación |
| Slots de material | M45 | Asociación de materiales a mallas |
| Presupuestos | M61/M62 | Draw calls y VRAM |
| Importación/compresión | M108 | Configuración de import de texturas |
| Git LFS | M06 | PNG fuente pesados |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentado (diseño completo, checklist completo en 05-Checklist.md)

### Lo que hice
- Documentación completa del módulo 47-Texturas y Materiales (5 archivos en plan-inicial y plan-actual).
- Catálogo de 25+ superficies del plan maestro (sección 46), atlas de bloques 32 px con variantes por bioma procedurales y deterministas, kit de StandardMaterial3D, 4 shaders acotados (agua/lava/cristal/emisivo ancestral) y registro de presupuesto de VRAM.
- Integrado con M08/M09/M10 (voxel y biomas), M45 (slots), M61/M62 (presupuestos) y M108 (importación).

### Lo que NO pude hacer
- No implementé `validate_material.gd` ni `generate_textures.gd` (herramientas de editor; se implementan en el hito M1).
- No generé texturas ni materiales reales (fase de producción de assets).

### Recomendaciones para el próximo agente
- Implementar primero el atlas de bloques y la generación procedural con una sola superficie (césped) end-to-end como prueba de cola.
- Definir las paletas por bioma (M09) antes de escalar la generación a las 25 superficies.
- Coordinar con M108 el import settings de texturas (compresión VRAM, mipmaps).
- Considerar QA cruzado (sección 21.8) por otro modelo.