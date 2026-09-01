**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-23
**Hora:** 03:39

# Log 136: Creación de M161 (Diseño Visual de NPCs)

## Archivos Creados
- `DOCUMENTACION/161-Diseno-Visual-De-NPCs/plan-inicial/01-Requerimientos.md`
- `DOCUMENTACION/161-Diseno-Visual-De-NPCs/plan-inicial/02-Analisis.md`
- `DOCUMENTACION/161-Diseno-Visual-De-NPCs/plan-inicial/03-Diseno.md`
- `DOCUMENTACION/161-Diseno-Visual-De-NPCs/plan-inicial/04-Codigo.md`
- `DOCUMENTACION/161-Diseno-Visual-De-NPCs/plan-inicial/05-Checklist.md`
- `DOCUMENTACION/161-Diseno-Visual-De-NPCs/plan-actual/` (copias)

## Archivos Modificados
- `CHECKLIST-GLOBAL.md` — Agregado M161, total actualizado a 161 módulos

## Descripción de la Modificación

Se creó el módulo M161 (Diseño Visual de NPCs) que define la apariencia completa de cada NPC: ropa, herramientas, colores y rasgos físicos.

### Contenido del Módulo:

**01-Requerimientos.md:**
- Problema: No existía diseño visual detallado para NPCs
- Objetivo: Diseño completo de 23 NPCs (4 islas)
- 10 requisitos funcionales
- 7 criterios de aceptación

**02-Analisis.md:**
- Jerarquía de elementos visuales por NPC
- Formato de diseño por NPC
- IDs de rasgos físicos (piel, cabello, ojos)
- Análisis de integración con 9 módulos

**03-Diseno.md (ARCHIVO PRINCIPAL):**
- Paleta de colores de piel (5 tonos HEX)
- Paleta de colores de cabello (8 colores HEX)
- Paleta de colores de ojos (5 colores HEX)
- **Isla Raíz (8 NPCs):**
  - Mayor: sombrero #2E5A4C, bastón dorado
  - Carpintero: fedora paja #F5DEB3, hacha T1, delantal cuero
  - Vendedora: bufanda #E2725B, bolsa
  - Viejo Sabio: sombrero gastado #36454F, bastón retorcido, gafas
  - Pescador: gorro #87CEEB, caña T1, salvavidas
  - Agricultora: sombrero paja #FF69B4, rastrillo T1, guantes
  - Niña: cinta #FF69B4, pelota
  - Animador: sombrero copa #FFD700, cencerro
- **Isla Coral (5 NPCs):**
  - Herrero: pelada, delantal quemado, martillo
  - Pescadora: paja #F5DEB3, red, perlas
  - Comerciante: turbante #FFD700, bolsa cuero
  - Guardia: casco #71797E, lanza
  - Niña Playa: flores #FF69B4, cubo
- **Isla Ceniza (5 NPCs):**
  - Herrero Avanzado: gafas #71797E, martillo pesado
  - Minero: casco linterna #71797E, pico T1
  - Cocinera: cofia #FFFDD0, cuchara
  - Bibliotecario: lentes, libro antiguo
  - Guardia Mina: casco reforzado, lanza
- **Isla Aurora (5 NPCs):**
  - Encantador: sombrero #191970, báculo con cristal
  - Sanadora: cofia #FFFDD0, poción
  - Guardia Ancestral: casco #FFD700, lanza dorada
  - Artista: beret #2C2C2C, paleta pintor
  - Viajero Misterioso: capucha #36454F, farol azul
- Tablas resumen visual por isla
- Reglas de identificación por profesión
- Colores predominantes por isla
- Proporciones por tipo de NPC
- Variantes estacionales

**04-Codigo.md:**
- Resource: NPCVisualData.gd
- Resource: RopaData.gd
- Resource: AccesorioData.gd
- Enums: PielType, CabelloType, OjosType, ComplexionType, EstacionType
- Autoload: NPCVisualDatabase.gd
- Estructura de carpetas: data/npc_visuals/RIZ/, COR/, CEN/, AUR/
- Script de validación de diseños
- Integración con M19, M45, M46, M155, M160

**05-Checklist.md:**
- 130 ítems de implementación
- Distribuidos en: estructura datos (15), Raíz (20), Coral (15), Ceniza (15), Aurora (15), tablas resumen (10), integración (20), testing (10), documentación (10)

## Elementos Visuales Clave por NPC:

| NPC | Sombrero | Herramienta | Color Clave |
|-----|----------|-------------|-------------|
| Mayor | Gorro alcalde | Bastón dorado | #2E5A4C |
| Carpintero | Fedora paja | Hacha T1 | #F5DEB3 |
| Vendedora | Bufanda | Bolsa | #E2725B |
| Viejo Sabio | Sombrero gastado | Bastón | #36454F |
| Pescador | Gorro red | Caña T1 | #87CEEB |
| Agricultora | Sombrero paja | Rastrillo T1 | #FF69B4 |
| Herrero | Pelada | Martillo | #B87333 |
| Encantador | Sombrero puntiagudo | Báculo | #191970 |
| Guardia | Casco | Lanza | #FFD700 |

## Impacto
- Cada NPC es identificable por su aspecto sin ver el nombre
- Artistas tienen especificaciones exactas para modelado 3D
- Colores coherentes por isla y profesión
- Herramientas en mano conectadas con M159
- Base para retratos 2D (M46) y variantes estacionales

## Commits Relacionados
- `c939fd6` — Creación de M160 (Diseño de Ubicaciones del Mundo)
- Este commit — Creación de M161 (Diseño Visual de NPCs)