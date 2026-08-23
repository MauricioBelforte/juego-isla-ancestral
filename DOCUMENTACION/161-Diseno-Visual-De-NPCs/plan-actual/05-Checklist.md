**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 161: Diseño Visual de NPCs

## Checklist de Implementación (130 ítems)

### Estructura de Datos (15 ítems)

- [ ] Crear Resource `NPCVisualData.gd` con todos los campos
- [ ] Crear Resource `RopaData.gd` para prendas de ropa
- [ ] Crear Resource `AccesorioData.gd` para accesorios
- [ ] Crear enum `PielType` con 5 tonos
- [ ] Crear enum `CabelloType` con 8 colores
- [ ] Crear enum `OjosType` con 5 colores
- [ ] Crear enum `ComplexionType` con 5 tipos
- [ ] Crear enum `EstacionType` con 4 estaciones
- [ ] Crear Autoload `NPCVisualDatabase.gd`
- [ ] Implementar `get_visual(npc_id)` para búsqueda
- [ ] Implementar `get_visuals_by_island(isla)` para filtrado
- [ ] Implementar `get_seasonal_variant(npc_id, estacion)`
- [ ] Crear carpeta `data/npc_visuals/` con subcarpetas por isla
- [ ] Validar que todos los IDs coinciden con M19
- [ ] Crear script de validación de diseños

### Isla Raíz: 8 NPCs (20 ítems)

- [ ] Diseñar Mayor del Pueblo (sombrero #2E5A4C, bastón dorado)
- [ ] Diseñar Carpintero (fedora paja #F5DEB3, hacha T1)
- [ ] Diseñar Vendedora Tienda General (bufanda #E2725B, bolsa)
- [ ] Diseñar Viejo Sabio (sombrero gastado #36454F, bastón retorcido)
- [ ] Diseñar Pescador del Puerto (gorro #87CEEB, caña T1)
- [ ] Diseñar Agricultora (sombrero paja #FF69B4, rastrillo T1)
- [ ] Diseñar Niña del Pueblo (cinta #FF69B4, pelota)
- [ ] Diseñar Animador de Plaza (sombrero copa #FFD700, cencerro)
- [ ] Definir colores HEX para cada prenda del Mayor
- [ ] Definir colores HEX para cada prenda del Carpintero
- [ ] Definir colores HEX para cada prenda de la Vendedora
- [ ] Definir colores HEX para cada prenda del Viejo Sabio
- [ ] Definir colores HEX para cada prenda del Pescador
- [ ] Definir colores HEX para cada prenda de la Agricultora
- [ ] Definir colores HEX para cada prenda de la Niña
- [ ] Definir colores HEX para cada prenda del Animador
- [ ] Crear Resources .tres para cada NPC de Raíz
- [ ] Definir herramientas en mano con IDs M159
- [ ] Definir accesorios para cada NPC
- [ ] Validar que herramientas M159 existen

### Isla Coral: 5 NPCs (15 ítems)

- [ ] Diseñar Herrero de Coral (pelada, delantal quemado #36454F, martillo)
- [ ] Diseñar Pescadora de Coral (paja #F5DEB3, red)
- [ ] Diseñar Comerciante Viajero (turbante #FFD700, bolsa cuero)
- [ ] Diseñar Guardia del Puerto (casco #71797E, lanza)
- [ ] Diseñar Niña de la Playa (flores #FF69B4, cubo)
- [ ] Definir colores HEX para cada NPC
- [ ] Crear Resources .tres para cada NPC de Coral
- [ ] Definir herramientas en mano con IDs M159
- [ ] Definir accesorios para cada NPC
- [ ] Validar coherencia visual entre NPCs de Coral
- [ ] Verificar identificación por profesión
- [ ] Documentar variantes primavera
- [ ] Documentar variantes verano
- [ ] Documentar variantes otoño
- [ ] Documentar variantes invierno

### Isla Ceniza: 5 NPCs (15 ítems)

- [ ] Diseñar Herrero Avanzado (gafas #71797E, martillo pesado)
- [ ] Diseñar Minero (casco linterna #71797E, pico T1)
- [ ] Diseñar Cocinera (cofia #FFFDD0, cuchara)
- [ ] Diseñar Bibliotecario (lentes, libro antiguo)
- [ ] Diseñar Guardia de la Mina (casco reforzado, lanza)
- [ ] Definir colores HEX para cada NPC
- [ ] Crear Resources .tres para cada NPC de Ceniza
- [ ] Definir herramientas en mano con IDs M159
- [ ] Definir accesorios para cada NPC
- [ ] Validar coherencia visual entre NPCs de Ceniza
- [ ] Verificar identificación por profesión
- [ ] Documentar variantes estacionales
- [ ] Definir cicatrices y marcas para Herrero/Minero
- [ ] Definir manchas de ceniza para todos
- [ ] Verificar gafas de seguridad en mineros

### Isla Aurora: 5 NPCs (15 ítems)

- [ ] Diseñar Encantador (sombrero #191970, báculo)
- [ ] Diseñar Sanadora (cofia #FFFDD0, poción)
- [ ] Diseñar Guardia Ancestral (casco #FFD700, lanza dorada)
- [ ] Diseñar Artista (beret #2C2C2C, paleta pintor)
- [ ] Diseñar Viajero Misterioso (capucha #36454F, farol azul)
- [ ] Definir colores HEX para cada NPC
- [ ] Crear Resources .tres para cada NPC de Aurora
- [ ] Definir herramientas en mano con IDs M159
- [ ] Definir accesorios para cada NPC
- [ ] Validar coherencia visual entre NPCs de Aurora
- [ ] Verificar identificación por profesión
- [ ] Documentar variantes estacionales
- [ ] Definir brillo mágico para Encantador
- [ ] Definir efecto etéreo para Sanadora
- [ ] Verificar runas y elementos ancestrales

### Tablas Resumen (10 ítems)

- [ ] Crear tabla resumen visual de Isla Raíz
- [ ] Crear tabla resumen visual de Isla Coral
- [ ] Crear tabla resumen visual de Isla Ceniza
- [ ] Crear tabla resumen visual de Isla Aurora
- [ ] Verificar que todos los colores son consistentes por isla
- [ ] Verificar que todas las profesiones son identificables
- [ ] Verificar que no hay colores duplicados entre NPCs de misma isla
- [ ] Documentar reglas de diseño visual
- [ ] Documentar proporciones por tipo de NPC
- [ ] Documentar variantes estacionales generales

### Integración y Validación (20 ítems)

- [ ] Verificar que IDs coinciden con M19 (25 NPCs)
- [ ] Verificar que herramientas coinciden con M159
- [ ] Verificar que retratos 2D (M46) usan estos diseños
- [ ] Verificar que modelos 3D (M45) implementan estos diseños
- [ ] Verificar que NPCs aparecen en ubicaciones M160
- [ ] Verificar que ropa puede coincidir con M155
- [ ] Verificar coherencia entre NPCs de misma isla
- [ ] Verificar identificación por profesión
- [ ] Documentar integración con M19
- [ ] Documentar integración con M159
- [ ] Documentar integración con M45
- [ ] Documentar integración con M46
- [ ] Documentar integración con M155
- [ ] Documentar integración con M160
- [ ] Documentar integración con M27
- [ ] Documentar integración con M29
- [ ] Documentar integración con M39
- [ ] Crear test de carga de NPCVisualDatabase
- [ ] Crear test de búsqueda por ID
- [ ] Crear test de búsqueda por isla

### Testing (10 ítems)

- [ ] Crear test de carga de diseños
- [ ] Crear test de búsqueda por ID
- [ ] Crear test de búsqueda por isla
- [ ] Crear test de variantes estacionales
- [ ] Crear test de herramientas M159
- [ ] Crear test de colores HEX
- [ ] Crear test de integración con M19
- [ ] Crear test de integración con M46
- [ ] Crear test de validación visual
- [ ] Crear test de coherencia por isla

### Documentación (10 ítems)

- [ ] Crear README con formato de IDs
- [ ] Documentar paleta de piel completa
- [ ] Documentar paleta de cabello completa
- [ ] Documentar paleta de ojos completa
- [ ] Documentar reglas de identificación por profesión
- [ ] Documentar reglas de coherencia por isla
- [ ] Documentar variantes estacionales
- [ ] Documentar integración con otros módulos
- [ ] Crear guía para agregar nuevos NPCs
- [ ] Documentar proporciones y tamaños

**Total: 130 ítems**
