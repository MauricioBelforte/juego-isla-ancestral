**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# ART_STYLE_3D.md — Guía de Estilo Artístico 3D

> Documento vivo del módulo M45 (Arte 3D). Define el estilo visual 3D del juego para que cualquier modelador —humano o asistido por IA— produzca assets coherentes.

## 1. Estilo General

**Cozy Voxel Redondeado + Low-Poly**

- El mundo base es voxel (bloques de 1 m³, M08)
- Los assets 3D (personajes, props, edificios) usan **low-poly redondeado** que complementa el voxel sin contradecirlo
- Siluetas suaves, ángulos redondeados, proporciones amables
- **Cabezas grandes** en personajes/NPCs (estilo chibi cozy)
- Sin detalles agresivos, sin bordes filosos, sin texturas ruidosas

## 2. Paleta de Color por Bioma

| Bioma | Colores dominantes | Acentos |
|-------|-------------------|---------|
| Pradera/Raíz | Verde suave #A8D8B9, Marrón claro #D4A574 | Amarillo #FFD93D, Rosa #FFB5B5 |
| Bosque nevado | Blanco #F0F0F0, Azul claro #B8E0FF | Gris #C0C0C0, Verde oscuro #5B8C5A |
| Volcán/Ceniza | Rojo oscuro #8B2500, Gris #696969 | Naranja #FF6B35, Negro #2D2D2D |
| Costa/Coral | Azul turquesa #40E0D0, Arena #F5DEB3 | Rosa #FFB6C1, Verde #90EE90 |
| Aurora | Lila #E8D5FF, Dorado #FFD700 | Azul #87CEEB, Blanco #FFFFFF |

## 3. Métricas de Escala

| Elemento | Escala | Notas |
|----------|--------|-------|
| Bloque voxel | 1 m × 1 m × 1 m | Referencia base |
| Personaje jugador | ~1.8 m alto | Cabeza ~30% del cuerpo |
| NPC | ~1.7-1.9 m | Varía por personaje |
| Animal pequeño | ~0.3-0.5 m | Conejo, pájaro |
| Animal mediano | ~0.8-1.2 m | Oso, ciervo |
| Mueble | ~0.5-1.5 m | Según tipo |
| Herramienta (en mano) | ~0.3-0.6 m | Proporción al jugador |
| Edificio | ~3-8 m | Según tamaño |
| Árbol pequeño | ~2-4 m | Incluido voxel |
| Árbol grande | ~5-10 m | Incluido voxel |

## 4. Reglas de Topología

1. **Solo quads y tris** — sin n-gons
2. **Sin vértices duplicados** no soldados
3. **Normales consistentes** — sin caras invertidas
4. **UVs sin superposición** (excepto atlas intencional)
5. **Padding UV ≥ 4px** entre islas
6. **Origen del mesh** en el punto de anclaje (pies del personaje, centro del mueble)
7. **+Z = frente** (o según convención del proyecto), **+Y = arriba**

## 5. Convenciones de Nombres

| Prefijo | Categoría | Ejemplo |
|---------|-----------|---------|
| `chr_` | Personaje jugador | `chr_jugador_base` |
| `npc_` | NPC | `npc_luna_pintora` |
| `ani_` | Animal | `ani_conejito`, `ani_oso_grande` |
| `bld_` | Edificio | `bld_casa_luna` |
| `furn_` | Mueble | `furn_mesa_trabajo` |
| `tool_` | Herramienta | `tool_pico_cobre` |
| `veh_b` | Barco | `veh_b_barco_pesca` |
| `veh_` | Vehículo | `veh_dirigible` |
| `veg_` | Vegetación | `veg_arbol_roble` |
| `prop_` | Prop pequeño | `prop_jarron_1` |
| `ruin_` | Ruina | `ruin_templo_este` |
| `temple_` | Templo | `temple_puzzle_1` |
| `deco_` | Decorativo | `deco_farol` |
| `int_` | Interactivo | `int_cajon_tesoro` |

## 6. Herramienta Estándar

- **Blender** (gratuito, GPL)
- Formato fuente: `.blend`
- Exportación: glTF 2.0
- Unidad Blender = 1 m (coherente con voxel)

## 7. Checklist de Revisión de Asset

Antes de importar cada asset, verificar:

- [ ] Estilo coherente con voxel redondeado
- [ ] Escala correcta según tabla de métricas
- [ ] Polígonos dentro del techo de su categoría (ver tabla en 01-Requerimientos.md)
- [ ] Sin n-gons, sin vértices duplicados
- [ ] UVs dentro de 0..1, sin superposición, padding ≥4px
- [ ] Origen en punto de anclaje correcto
- [ ] Normales consistentes
- [ ] Nombre con prefijo correcto
- [ ] LOD configurado si >500 tris
- [ ] Material/textura asignada (M47)
