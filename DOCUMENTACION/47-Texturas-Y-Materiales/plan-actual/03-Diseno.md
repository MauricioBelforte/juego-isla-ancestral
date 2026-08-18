**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 47: Texturas y Materiales

## 1. Arquitectura

El módulo es un **sistema de contenido + herramientas de editor** (sin runtime propio salvo la carga de atlas):

```
Assets/_Project/Textures/
├── atlas/bloques/        (gen_bloques_*: tiles 32px por bioma → atlas_bloques.tres)
├── atlas/mobiliario/     (gen_*: muebles, construcción)
├── atlas/personajes/     (ropa y skins)
├── atlas/props/          (props 3D M45)
├── special/              (agua.tres, lava.tres, cristal.tres, emisivos)
├── procedural/           (scripts generadores + paletas .tres)
└── budget/               (texture_budget.json)

Assets/_Project/Shaders/
├── agua.gdshader
├── lava.gdshader
├── cristal.gdshader
└── emisivo_ancestral.gdshader

Assets/_Project/Editor/
├── validate_material.gd
└── generate_textures.gd   (procedural determinista)

Docs/MATERIAL_STYLE.md     → guía de materiales (paleta, roughness, emisión)
```

El terreno voxel (M08/M10) consume `atlas_bloques.tres` vía UV; los props de M45 consumen los atlas de categoría; el agua/lava/cristal/luminosos usan los shaders de `Assets/_Project/Shaders/`. El runtime no referencía archivos por path: usa los resources compilados (`.tres`).

## 2. Diagramas de Flujo (texto)

### 2.1 Generación procedural de variantes por bioma

```
diseñador pinta base (tile 32px) para una superficie (ej: césped)
  → define paleta del bioma en .tres (M09): colores base + acentos
  → script generate_textures.gd recibe (superficie_id, bioma, semilla_partida)
  → aplica: repinte de paleta → ruido determinista (NoiseTexture, seed=semilla+sufijo)
            → 3 variantes por bioma → exporta PNG + regiones UV del atlas
  → validate_material.gd revisa alineación/naming/presupuesto
  → pack del atlas de bloques → atlas_bloques.tres
  → registro en texture_budget.json
```

### 2.2 Asignación de material a un prop 3D

```
prop importado (M45) con slots mat_body, mat_madera
  → se asocia cada slot a un StandardMaterial3D del kit (categoría props)
  → si el prop requiere variante (ej: madera oscura) → se clona el material
    pero SOLO si el albedo difiere; si solo cambia color → texture swap
  → validar: el material compartido no se duplica innecesariamente
  → registrar en catálogo de assets (ref_3d_id + ref_mat_id)
```

### 2.3 Validación al importar (validate_material.gd)

```
al importar textura/material (M108):
  → resolución: múltiplo de 4, ≤ 2K (runtime), tamaño según tabla (3.1)
  → atlas: si es tile de atlas → alineación perfecta a la grilla (pos/tamaño)
           y sin overlap de UVs entre tiles
  → naming: prefijo tex_/mat_/atlas_ correcto (M108)
  → formato: PNG fuente o WebP comprimido; mipmaps ON
  → memoria: registrar en texture_budget.json; si la escena pivote supera
             el presupuesto M62 → error
  → shaders: si material con shader → verificar en whitelist (agua/lava/cristal/
             emisivo_ancestral) y contar instancias por escena (≤2 costosos)
  → emitir lista acumulada de errores
```

## 3. Tablas de Métricas (técnico)

### 3.1 Resoluciones y formatos

| Categoría | Resolución | Formato | Atlas |
|---|---|---|---|
| Tile de bloque | 32×32 (LOD 16×16) | PNG | atlas_bloques 1024 |
| Texturas de mobiliario | 512 | PNG/WebP | atlas_mobiliario 2048 |
| Personajes/ropa | 512 | PNG/WebP | atlas_personajes 2048 |
| Props | 512 | PNG/WebP | atlas_props 2048 |
| Normalmaps | misma que albedo | PNG | mismo atlas (capa N) |
| Agua/lava/cristal | 256 (tile) | WebP | especiales sueltos |

### 3.2 Materiales base del kit

| Superficie | Albedo | Rough | Metal | Notas |
|---|---|---|---|---|
| Tierra/arcilla | pastel marrón | 1.0 | 0 | grano sutil |
| Césped | verde bioma | 0.9 | 0 | normal sutil |
| Piedra | gris suave | 0.8 | 0 | 3 variantes |
| Arena | pálido cálido | 1.0 | 0 | haz perlin sutil |
| Madera | marrón cálido | 0.7 | 0 | veta suave |
| Metal | gris medio | 0.35 | 0.8 | herramientas/metal |
| Cristal | transparente | 0.1 | 0 | shader cristal |
| Hielo | azul claro | 0.25 | 0.1 | normal animado sutil |
| Lava | naranja | 0.4 | 0 | shader lava + emisión |
| Agua | azul bioma | 0.2 | 0 | shader agua + normal |
| Coral | rosa/coral | 0.9 | 0 | variantes por bioma |
| Musgo | verde oscuro | 0.9 | 0 | overlay sobre piedra |

### 3.3 Límites operativos

- Un draw call por material compartido; ≤ 2 shaders costosos por escena.
- Ninguna textura runtime > 2K; atlas ≤ 2K.
- Variantes por superficie ≥ 3 por bioma (semilla M10).
- Emisión ancestral: ≤ 1.5 en scale (compacto en color), sin bloom agresivo (M49).

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M08/M10 | Atlas de bloques consumido por el terreno voxel; semilla para variantes |
| M09 | Paletas por bioma como entrada de generación |
| M45 | Slots de material de las mallas; kit por categoría |
| M46 | Coherencia de paleta con arte 2D |
| M49 | Materiales luminosos vs bloom/GI |
| M50/M51 | Vegetación y agua consumen texturas definidas aquí |
| M61/M62 | Draw calls, VRAM, precompilación de shaders |
| M108 | Importación, compresión, pack de atlas |
| M06 | Git LFS para PNG fuente |