**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 47: Texturas y Materiales

## 1. Análisis del Dominio

El dominio de texturas y materiales de Aurora se descompone en nueve subsistemas:

### 1.1 Atlas de bloques (núcleo voxel)
- **Dominio:** todos los bloques del mundo (M08) viven en UN atlas de tiles. Cada tile es la cara de un bloque; el terreno voxel (M10) referencia tiles por UV, no texturas sueltas.
- **Resolución por tile:** 16 px y 32 px son las opciones estándar (16px tile = atlas 512×512 para 32 tiles; 32px = atlas 1024). Se adopta 32 px/tile para calidad cozy, 16 px en LOD lejano (M61).
- **Faces diferenciadas:** algunos bloques requieren cara superior/ lateral distintas (césped: verde arriba, tierra en lados); el atlas soporta tiles por cara.
- **Variantes:** cada bloque base tiene ≥3 variantes de textura por bioma (M09) con la MISMA métrica de UV (solo cambia la región del atlas); el problema de "tiling visible" se minimiza con variantes barajadas por PRNG (M10).

### 1.2 Variantes procedurales deterministas
- **Dominio:** generar 13 biomas × 25 superficies × 3 variantes a mano = 975 texturas es inmanejable. Se generan proceduralmente (Godot NoiseTexture + script) a partir de una paleta por bioma (M09).
- **Determinismo:** el script de generación recibe la semilla de partida (M10) y reproduce exactamente el mismo resultado; los .png generados se commitean como fuente (no se regeneran en runtime).
- **Clave:** el runtime JAMÁS genera texturas; las variantes son assets.

### 1.3 Materiales Godot (StandardMaterial3D)
- **Dominio:** la mayoría de superficies usan StandardMaterial3D: albedo, rough, metallic, emissive, normal. Con el flujo PBR Metallic-Roughness (glTF, M45).
- **Reutilitzación:** un StandardMaterial3D compartido por objeto (los reco lore viajan por `instance shader` solo cuando hay < 10 variantes); el recolor de personajes usa `texture` de albedo distinta sobre el mismo material base.
- **ShaderCache:** los materiales con shader se precompilan (M61); los shaders heredan de un base común para reducir state changes.

### 1.4 Materiales especiales (shaders acotados)
- **Agua (RF8):** material transparente, normalmap animado suave; en cooperación con M51. En Godot: ShaderMaterial con `depth_prepass`, transparencia básica; NO refracción real en tertulia general (solo en pools pequeños).
- **Lava (RF9):** emisión por ruido desplazado (2 texturas cruzadas); solo biomas volcánicos; emisión moderada (sin bloom agresivo, M49).
- **Cristal (RF10):** shader con `ALPHA` y refracción ligera (screen texture), solo en vitrinas (M37) y templos (M24/M26); máximo 2 instancias por escena.
- **Luminosos (RF7):** emisivos con `EMISSION` constante + pulso sutil; los materiales ancestrales (sellos, glifos) brillan en la oscuridad (M31) pero con tope de emisión para no romper cozy.

### 1.5 Presupuesto de memoria (M62)
- **Dominio:** texturas = mayor consumidor de VRAM. Reglas: ninguna textura runtime > 2K; atlas por categoría ≤ 2K; mipmaps ON por defecto; compresión VRAM (S3TC/BC) en import (M108).
- **Estimación:** cada textura registra su tamaño en `texture_budget.json` (RF14); el validador suma el total por escena contra el presupuesto de M62.

### 1.6 Atlas de categorías (no voxel)
- **Dominio:** además del atlas de bloques, existen atlas de: mobiliario/construcción (M17/M18), personajes/ropa (M19), props (M45). Cada categoría tiene su atlas ≤ 2K con padding ≥ 2 px (mismo criterio que M46).
- **Slots de material (M45):** las mallas traen slots (`mat_body`, `mat_madera`...); el atlas de categoría asigna las regiones UV por slot.

### 1.7 Determinismo vs aleatoriedad de percepción
- **Dominio:** el ojo nota repetición de una textura si el tile es muy distintivo. Mitigación: variantes por bioma (≥3), barajado por PRNG de chunk (M10), normalmaps sutiles.
- **Regla:** la repetición se rompe con VARIANTES del mismo tile, no con texturas nuevas (evita memoria).

### 1.8 Validación técnica
- **Dominio:** `validate_material.gd` verifica al importar: resolución múltiplo de 4, alineación a grilla del atlas (tile perfecto), overlap de UVs entre tiles, formato (PNG/WebP), naming, presupuesto de memoria real por escena.

### 1.9 Flujo de producción
- **Dominio:** artista de texturas pinta las "fuentes" (o ajusta paletas), el script procedural genera variantes por bioma, el validador revisa, el importador de M108 comprime, los materiales se ensamblan en Godot y se registran en el catálogo.

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Textura individual por bloque (sin atlas) | **Descartado** | Draw calls y memoria explotando; el voxel exige atlas |
| Solo 16 px/tile | **Descartado** | Muy blanda para el estilo cozy; se usa 32 px con LOD 16px |
| Variantes 100% a mano | **Descartado** | 900+ texturas inmanejables; se generan procedurally con paleta |
| Regenerar texturas en runtime | **Descartado** | Rompe determinismo y carga (M63); se commitean generadas |
| Shaders para todo (PBR custom global) | **Descartado** | Costo prohibido (M61); solo 4 materiales especiales acotados |
| Recolor por instancia del material | **Descartado** | Multiplica shader state changes; se usa albedo compartida + texture swap |

## 3. Decisiones del Módulo

1. **Atlas de bloques único de 32 px/tile** con variantes por bioma (≥3) y LOD 16px.
2. **Texturas procedurales deterministas** generadas con semilla de partida y commiteadas como source.
3. **StandardMaterial3D base** compartido; 4 shaders especiales acotados (agua, lava, cristal, luminosos/emisivos).
4. **Paleta por bioma (M09)** como entrada única del script de generación.
5. **Registro de presupuesto** (`texture_budget.json`) con estimación de VRAM por escena.
6. **Validador automático** (`validate_material.gd`) como puerta de entrada previa a M108.

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Texturas duplicadas en memoria por descuido | Media | Alto | Registro de presupuesto + validador + revisión M62 |
| Tiling visible del atlas de bloques | Alta | Medio | Variantes por bioma + barajado PRNG + normalmap sutil |
| Shaders costosos acumulados | Media | Alto | Límite de 2 shaders especiales por escena + precompilación |
| Atlas desalineado que genera artefactos | Media | Medio | Validador de alineación + padding |
| Memoria creciente sin control | Media | Alto | texture_budget.json contra M62 en cada PR |