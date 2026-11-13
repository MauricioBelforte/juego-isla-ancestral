# Especificación de Texturas y Materiales — M47

**Módulo:** M47
**Autor:** agnes-3-flash (Kilo Code)
**Fecha:** 2026-10-12
**Estado:** Definición completa — lista para fase de implementación

---

## A. Objetivos y Dependencias

- **Objetivo:** Material kit central con atlas eficientes, variantes por bioma y presupuesto verificado.
- **Dependencias:** M08 (voxel), M45 (slots), M46 (paleta), M04 (Godot), M61/M62 (presupuestos), M108.
- **Alcance:** Modelado → M45, Iluminación → M49, Pipeline → M108, Arte 2D UI → M46.
- **Mapeo plan maestro:** Sección 46 "TEXTURAS Y MATERIALES" → ID 47 (desfase de numeración documentado).

## B. Catálogo de Superficies (25+)

| # | Superficie | Biomas | Prioridad |
|---|-----------|--------|-----------|
| 1 | Tierra | Todos | Alta |
| 2 | Césped | Bosque, Llanura | Alta |
| 3 | Piedra | Montaña, Volcánico | Alta |
| 4 | Arena | Desierto, Playa | Alta |
| 5 | Arcilla | Volcánico | Media |
| 6 | Madera | Bosque, Poblado | Alta |
| 7 | Metal | Poblado, Templo | Media |
| 8 | Cristal | Templo, Cueva | Media |
| 9 | Hielo | Glacial | Media |
| 10 | Lava | Volcánico | Baja |
| 11 | Agua | Todos | Alta |
| 12 | Coral | Costero | Baja |
| 13 | Musgo | Bosque, Cueva | Media |
| 14 | Ruinas | Todos | Alta |
| 15 | Paredes | Poblado | Media |
| 16 | Pisos | Poblado, Templo | Alta |
| 17 | Techos | Poblado | Media |
| 18 | Muebles | Poblado | Baja |
| 19 | Ropa | Personajes | Alta |
| 20 | Herramientas | Todos | Alta |
| 21 | Vehículos | Todos | Media |
| 22 | Vegetación | Bosque, Llanura | Alta |
| 23 | Material ancestral | Templo, Cueva | Alta |
| 24 | Material luminoso | Templo, Cueva | Alta |
| 25 | Acero oxidado | Poblado | Baja |

Variantes por bioma: 3 por superficie/bioma (barajado determinista por seed).

## C. Atlas de Bloques

- **Tileset único:** Todos los bloques de M08 en un solo atlas 1024×1024.
- **Resolución:** 32 px/tile (LOD 16 px).
- **Tiles por atlas:** ~32 (1024/32 = 32 tiles por lado).
- **Caras diferenciadas:** Césped = verde arriba / tierra lados.
- **Variantes:** ≥3 por bloque/bioma, misma métrica UV.
- **Regla:** No duplicar un bloque en otro atlas.

## D. Variantes Procedurales

- **Determinismo:** `seed = hash(semilla, superficie, bioma, variante)` (M10 PRNG).
- **Paleta por bioma (M09):** Única entrada de color.
- **Barajado:** Por PRNG de chunk (no por frame).
- **Commitar:** PNG generados como fuente (nunca regenerar en runtime).

## E. Materiales de Personajes

- **Slots:** M19/M11 definen slots de ropa. M47 define el material.
- **Recolor por NPC:** Vía albedo compartida + texture swap (no duplicar material).
- **Regla:** 1 material por slot, swap = cambiar texture reference.

## F. Mobiliario

- **Atlas de mobiliario:** M17/M18 definen props, M47 texturas.
- **Niveles de madera:** Base / Oscura / Teñida / Ancestral (4 variantes).

## G. Ruinas/Templos

- **Acabado ancestral:** M25 + M24/M26 — piedra con glifos + emisión sutil.
- **Piedra desgastada:** M09 bioma — musgo + erosión procedural.

## H. Materiales Luminosos

- **Shader emisivo_ancestral:** Sellos, glifos, esporas (M11).
- **Tope emisión:** ≤ 1.5 (sin bloom agresivo M49).
- **Pulso:** Sutil determinista (sin RNG runtime).

## I. Agua

- **Shader:** Normalmap animado por TIME.
- **Refracción:** Sin refracción global (solo pools pequeños).
- **Color:** Por bioma (M09).
- **Coordinación:** M51 (agua/vegetación).

## J. Lava

- **Shader:** Ruido desplazado cruzado.
- **Emisión:** Moderada (≤ 2.0).
- **Presencia:** Solo biomas volcánicos.

## K. Cristal

- **Shader:** Transparencia + refracción ligera.
- **Máximo:** 2 instancias por escena.
- **Uso:** Vitrinas M37 + templos M24/M26.

## L. Herramientas

- **9 herramientas × 4 niveles:** M13 define, M47 texturiza.
- **Diferencias por nivel:** Mango, hoja, aura (emisión sutil).

## M. Validación Automática

- **Resolución:** Múltiplo de 4, ≤ 2K.
- **Alineación:** Tiles alineados al atlas.
- **Overlap:** UVs sin overlap entre tiles.
- **Naming:** `tex_` / `mat_` / `atlas_`.
- **Formato:** PNG/WebP + mipmaps.
- **Memoria:** Por escena pivote contra M62.
- **Shaders:** Whitelist + ≤ 2 costosos por escena.

## N. Naming

- **Texturas:** `tex_{superficie}_{bioma}_{variante}.png`
- **Materiales:** `mat_{superficie}_{tipo}.tres`
- **Atlas:** `atlas_{categoria}.png`
- **Alineación:** M108 (pipeline de importación).

## O. Presupuesto

- **Per textura:** `texture_budget.json` (resolución, formato, VRAM).
- **Suma por escena:** Contra M62.
- **Alerta:** En editor si excede presupuesto.

## P. Determinismo

- **Reproducción:** Misma semilla → mismas variantes.
- **RNG:** Prohibido en runtime.
- **Generación:** `generate_textures.gd` (seed = hash).

## Q. No Funcionales

- **Rendimiento:** 1 draw call por material compartido, ≤2 shaders costosos/escena.
- **Memoria:** Atlas ≤ 2K, sin texturas runtime > 2K.
- **Variedad:** ≥3 variantes/bioma.
- **Cozy:** Paleta pastel M09, sin contrastes agresivos.
- **Mantenible:** Fuentes procedurales versionadas, PNG en Git LFS.
- **Consistencia:** Atlas de bloques único.

## R. Alternativas Descartadas

| Alternativa | Motivo |
|-------------|--------|
| Textura individual por bloque | Draw calls + memoria |
| Solo 16 px/tile | Calidad cozy insuficiente |
| Variantes 100% a mano | 900+ inmanejables |
| Regenerar en runtime | Determinismo M10/M63 |
| Shaders para todo | Costo M61 |
| Recolor por instancia | State changes |

## S. Riesgos

| Riesgo | Mitigación |
|--------|------------|
| Duplicados en memoria | Registro + validador |
| Tiling visible | Variantes + barajado + normalmap |
| Shaders costosos | Whitelist + conteo |
| Atlas desalineado | Validador de alineación |
| Memoria creciente | texture_budget.json en cada PR |

## T. Integraciones

- M08/M10: Atlas + semillas
- M09: Paletas por bioma
- M45: Slots de material
- M46: Paleta 2D
- M49: Emisión vs bloom
- M50/M51: Vegetación/agua
- M61/M62: Presupuestos
- M108: Importación
- M06: Git LFS

## U. Flujos

- **Generación procedural:** Base → paleta → ruido → variantes.
- **Asignación a prop:** Slots → kit → variante.
- **Validación:** Al importar (script validate_material.gd).
- **IA apoyo:** M86 paleta.

## V. Criterios de Aceptación

- 25+ superficies con material asignado
- Atlas completo sin duplicados
- Misma semilla → mismas variantes
- Recolor sin duplicar memoria
- Lava/cristal ≤2 shaders costosos
- Validador rechaza 4K/desalineado
- VRAM dentro M62
- Superficies cumplen M108 + Git LFS

## W. Notas

- Desfase numeración: plan maestro §46 = M47.
- Módulo DELEGABLE.
- Dependencia implementación: hito M1.

## X. Nuevos materiales de casas (2026-11-12, ERNIE-5.5-Flash-Preview)

> Creados para las casas grandes (Casona del Gremio y Mansión del Museo). Se suman a la paleta low-poly existente; no usan imágenes de textura.

| Material | RGB sRGB | Roughness | Metallic | Alpha | Uso |
|---|---|---:|---:|---:|---|
| `MAT_Vino` | (120, 45, 55) | 0.80 | 0.0 | 1.0 | Tapizados, mantas, alfombras, tapices |
| `MAT_OroViejo` | (190, 150, 70) | 0.45 | 0.70 | 1.0 | Marcos, espejos, arañas, herrajes |
| `MAT_VerdeSage` | (110, 140, 100) | 0.90 | 0.0 | 1.0 | Plantas, fieltro de billar, globos |
| `MAT_Agua` | (80, 150, 170) | 0.15 | 0.0 | 0.55 | Fuentes, acuarios, bañeras |
| `MAT_Libro` | (150, 110, 80) | 0.90 | 0.0 | 1.0 | Libros de estanterías |
| `MAT_Cobre` | (170, 100, 60) | 0.40 | 0.80 | 1.0 | Bañera, ollas, detalles |
| `MAT_Marfil` | (230, 220, 195) | 0.70 | 0.0 | 1.0 | Estatuas, velas, porcelana |
| `MAT_Coral` | (220, 130, 110) | 0.80 | 0.0 | 1.0 | Macetas, boyas, peces |

**Validación:** los 8 materiales usan Principled BSDF con color base + roughness + metallic constantes; el color se hornea en vertex colors (`COLOR_0`) al exportar. Para Godot se unifican a ≤8 materiales por casa con `generar_variante.py --media --baja` o atlas M47 (1024², 32 px/tile).
