**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 46: Arte 2D

> Rutas previstas dentro de `Assets/_Project/` (estructura del proyecto Godot 4.x, ver AGENTS.md §24).
> ⚠️ **Estado: Pendiente de implementación.** Los archivos listados son diseño/documentación; no existe código runtime todavía.

## 1. Archivos Previstos

### 1.1 Scripts de editor (GDScript, tipado) — `Assets/_Project/Editor/`

| Archivo | Propósito | Estado |
|---|---|---|
| `validate_2d.gd` | Validador de piezas 2D: tamaño, resolución, alfa/halos, duplicados (RF14) | Pendiente de implementación |
| `pack_atlas.gd` | Regeneración de atlas por superficie (ui/icons/portraits/story) (RF12) | Pendiente de implementación |

### 1.2 Documentación viva — `Docs/`

| Archivo | Propósito | Estado |
|---|---|---|
| `ART_STYLE_2D.md` | Guía de estilo 2D: paleta, trazo, sombreado, recetas por familia (RF1) | Pendiente de implementación |

### 1.3 Carpetas de contenido — `Assets/_Project/Art/2D/`

| Carpeta | Contenido | Estado |
|---|---|---|
| `logo/` | Logo principal + variantes (SVG + PNG 1024) | Vacía — pendiente de producción |
| `ui/` `icons/` `portraits/` `story/` `symbols/` `badges/` | Piezas 2D por superficie (RF3-RF10) | Vacía — pendiente de producción |

## 2. Funciones Clave (firmas GDScript previstas)

```gdscript
# ---------- validate_2d.gd (EditorPlugin) ----------
class_name Art2DValidator
extends RefCounted

const TAMANOS_PERMITIDOS := {128, 256, 512, 1024}        # px, cuadrados
const MULPLO_4 := 4                                       # requisito compresión

func validar_pieza(ruta: String, tipo: String) -> Array[String]:
    # tipo ∈ {"ico", "pt", "illus", "sym", "badge", "ui_art"}
    var errores: Array[String] = []
    # 1) formato: PNG o WebP (con alfa) — SVG solo como fuente
    # 2) tamaño: cuadrado y dentro de TAMANOS_PERMITIDOS según tipo
    # 3) resolución: ancho % 4 == 0 (compresión)
    # 4) alfa: muestrear borde exterior — si alfa acepta valores intermedios
    #    en la periferia (>0 y <255) → posible halo → warning/error
    # 5) duplicados: registrar id de la pieza contra el catálogo
    # 6) nombres: prefijo correcto según tipo (ico_, pt_, illus_, sym_,
    #    badge_, ui_art_) cumpliendo M108
    return errores
```

```gdscript
# ---------- pack_atlas.gd (EditorTool) ----------
class_name AtlasPacker
extends RefCounted

const SUPERFICIES := ["ui", "icons", "portraits", "story", "badges"]

func regenerar(superficie: String, tam_max: int = 2048) -> PackedStringArray:
    # 1) listar piezas válidas de la carpeta (validate_2d.gd previo)
    # 2) empacar (binary/guillotine): padding >= 2 px, sin rotaciones
    # 3) exportar PNG (compresión M108) + .tres (AtlasTexture) + .json de coords
    # 4) verificar límites: atlas <= tam_max, piezas > 1024 fuera del atlas
    # 5) devolver rutas generadas (o errores)
    pass
```

## 3. Señales y Eventos

| Evento | Emisor | Consumidor |
|---|---|---|
| `asset_2d_importado(pieza_id, resultados)` | Validador (M108) | Catálogo actualiza estado a `imported` |
| `atlas_regenerado(superficie, rutas)` | AtlasPacker | Logging de editor (M103) |
| `pieza_rechazada(pieza_id, errores)` | Validador | Bug tracking (M102) |

## 4. Logs Relacionados

| Log | Contexto | Nivel |
|---|---|---|
| `ART-2D-IMPORT` | pieza 2D importada con éxito (id, tamaño, tipo) | INFO |
| `ART-2D-REJECT` | pieza rechazada (id y errores listados) | WARN |
| `ART-2D-ATLAS` | atlas regenerado (superficie, piezas, tamaño final) | INFO |

## 5. Dependencias de Implementación

| Necesita | Módulo | Uso |
|---|---|---|
| Godot 4.x (>= 4.4.1) | M04 | Importación de texturas, AtlasTexture |
| Guía de estilo 2D | M45 (herencia) | Recetas de estilo coherentes |
| Compresión/import | M108 | Import settings, WebP, mipmaps |
| Carga diferida | M63 | Atlas por superficie bajo demanda |
| Nombres de archivo | M108 | Prefijos y convenciones |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentado (diseño completo, checklist completo en 05-Checklist.md)

### Lo que hice
- Documentación completa del módulo 46-Arte 2D (5 archivos en plan-inicial y plan-actual).
- Guía de estilo derivada del 3D (M45), bancos de iconos, retratos con plantilla 3D, símbolos/insignias, atlas por superficie, validador 2D.
- Mapeo de la sección 45 "ARTE 2D" del plan maestro al ID 46 de CHECKLIST-GLOBAL (desfase de numeración idéntico al de M45).

### Lo que NO pude hacer
- No implementé `validate_2d.gd` ni `pack_atlas.gd` (herramientas de editor; se implementarán en el hito M1 con el proyecto Godot).
- No produje piezas de arte 2D (requiere diseñador/ilustrador; fase de producción).

### Recomendaciones para el próximo agente
- Implementar `ART_STYLE_2D.md` junto con `ART_STYLE_3D.md` (M45) en el mismo sprint para asegurar la herencia de estilo.
- Probar el pipeline completo con 3 iconos + 1 retrato de muestra antes de producir el banco completo.
- Coordinar con M108 el import settings de PNG/WebP con alfa (compresión VRAM).
- Considerar QA cruzado (sección 21.8) por otro modelo.