**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-08-22

# 05-Checklist.md — Módulo 159: Catálogo de Objetos

## Checklist de Implementación (120 ítems)

### Estructura de Datos (15 ítems)

- [ ] Crear Resource `ItemData.gd` con todos los campos exportados
- [ ] Crear Autoload `ItemDatabase.gd` con carga automática
- [ ] Definir enum `Categoria` con 16 categorías
- [ ] Definir enum `Rareza` con 4 niveles
- [ ] Definir enum `Interaccion` con 13 tipos
- [ ] Crear carpeta `data/items/` para Resources .tres
- [ ] Crear plantilla de Resource para cada categoría
- [ ] Implementar `get_item(id)` para búsqueda por ID
- [ ] Implementar `get_items_by_category(cat)` para filtrado
- [ ] Implementar `get_items_by_rarity(rareza)` para filtrado
- [ ] Implementar `get_items_by_source(fuente)` para filtrado
- [ ] Implementar `get_interactive_items()` para objetos interactuables
- [ ] Implementar `get_placeable_items()` para objetos colocables
- [ ] Implementar `get_cookable_items()` para objetos de cocina
- [ ] Validar que todos los IDs sean únicos

### CAT-01: Mobiliario Interior (10 ítems)

- [ ] Documentar 10 mesas (OBJ-MES-001 a 010)
- [ ] Documentar 10 sillas (OBJ-SIL-001 a 010)
- [ ] Documentar 10 camas (OBJ-CAM-001 a 010)
- [ ] Documentar 10 estanterías (OBJ-EST-001 a 010)
- [ ] Definir tamaños de grid para cada mueble
- [ ] Definir interacciones para cada mueble
- [ ] Definir precios de compra/venta
- [ ] Definir rareza de cada mueble
- [ ] Crear iconos para cada mueble
- [ ] Crear modelos 3D placeholder para cada mueble

### CAT-02: Decoración de Pared (8 ítems)

- [ ] Documentar 10 cuadros (OBJ-CUA-001 a 010)
- [ ] Documentar 5 espejos (OBJ-ESP-001 a 005)
- [ ] Documentar 4 relojes (OBJ-REL-001 a 004)
- [ ] Definir tamaños de grid de pared
- [ ] Definir interacciones (mirar, mirarse, ver hora)
- [ ] Definir precios y rareza
- [ ] Crear iconos para cada objeto
- [ ] Crear modelos 3D placeholder

### CAT-03: Iluminación (10 ítems)

- [ ] Documentar 15 objetos de iluminación (OBJ-LUZ-001 a 015)
- [ ] Definir tamaños de grid
- [ ] Definir interacción (encender/apagar)
- [ ] Definir radio de iluminación
- [ ] Definir intensidad de luz
- [ ] Definir color de luz
- [ ] Definir precios y rareza
- [ ] Crear iconos
- [ ] Crear modelos 3D
- [ ] Crear efectos de luz (point light, spot light)

### CAT-04: Plantas Interior (8 ítems)

- [ ] Documentar 14 plantas (OBJ-PLA-001 a 014)
- [ ] Definir tamaños de grid
- [ ] Definir interacción (regar)
- [ ] Definir tiempo de crecimiento
- [ ] Definir precios y rareza
- [ ] Crear iconos
- [ ] Crear modelos 3D
- [ ] Crear animaciones de crecimiento

### CAT-05: Alfombras (5 ítems)

- [ ] Documentar 8 alfombras (OBJ-ALF-001 a 008)
- [ ] Definir tamaños de grid
- [ ] Definir precios y rareza
- [ ] Crear iconos
- [ ] Crear texturas de alfombras

### CAT-06: Cocina (10 ítems)

- [ ] Documentar 20 objetos de cocina (OBJ-COC-001 a 020)
- [ ] Definir tamaños de grid
- [ ] Definir interacciones (cocinar, hornear, freír, etc.)
- [ ] Definir recetas asociadas
- [ ] Definir precios y rareza
- [ ] Crear iconos
- [ ] Crear modelos 3D
- [ ] Crear animaciones de uso
- [ ] Integrar con M16 (Crafting)
- [ ] Integrar con M18 (Casas)

### CAT-07: Taller (5 ítems)

- [ ] Documentar 10 objetos de taller (OBJ-TAL-001 a 010)
- [ ] Definir tamaños de grid
- [ ] Definir interacciones (fabricar, forjar, etc.)
- [ ] Definir precios y rareza
- [ ] Crear iconos y modelos 3D

### CAT-08: Exteriores (10 ítems)

- [ ] Documentar 20 objetos exteriores (OBJ-EXT-001 a 020)
- [ ] Definir tamaños de grid exterior
- [ ] Definir interacciones
- [ ] Definir precios y rareza
- [ ] Crear iconos y modelos 3D

### CAT-09: Naturaleza (10 ítems)

- [ ] Documentar 10 árboles (OBJ-NAT-001 a 010)
- [ ] Documentar 7 rocas (OBJ-NAT-011 a 017)
- [ ] Documentar 11 arbustos/flores (OBJ-NAT-018 a 028)
- [ ] Definir tamaños de grid
- [ ] Definir interacciones (cortar, minar, recoger)
- [ ] Definir drops de materiales
- [ ] Definir tiempo de regeneración
- [ ] Crear iconos
- [ ] Crear modelos 3D
- [ ] Crear animaciones de recolección

### CAT-10: Construcción (5 ítems)

- [ ] Documentar 15 objetos de construcción (OBJ-CON-001 a 015)
- [ ] Definir tamaños de grid
- [ ] Definir interacciones (abrir/cerrar puertas/ventanas)
- [ ] Definir precios y rareza
- [ ] Crear iconos y modelos 3D

### CAT-11: Herramientas (5 ítems)

- [ ] Documentar 20 herramientas (OBJ-HER-001 a 020)
- [ ] Definir stats por tier (T1-T4)
- [ ] Definir durabilidad
- [ ] Definir precios y rareza
- [ ] Integrar con M13 (Herramientas) y M158 (Desbloqueo de Zonas)

### CAT-12: Items (10 ítems)

- [ ] Documentar 15 materiales (OBJ-ITE-001 a 015)
- [ ] Documentar 20 comidas (OBJ-ITE-020 a 039)
- [ ] Documentar 8 monedas/gemas (OBJ-ITE-050 a 057)
- [ ] Definir precios de compra/venta
- [ ] Definir efectos de comida (energía)
- [ ] Definir stack máximo
- [ ] Crear iconos
- [ ] Integrar con M14 (Inventario)
- [ ] Integrar con M16 (Crafting)
- [ ] Integrar con M38 (Economía)

### CAT-13: Ropa (5 ítems)

- [ ] Documentar 20 prendas (OBJ-ROP-001 a 020)
- [ ] Definir slot (cabeza, cuerpo, pies, accesorio)
- [ ] Definir bonificaciones por terreno
- [ ] Definir precios y rareza
- [ ] Integrar con M155 (Vestimenta)

### CAT-14: Arte Ancestral (5 ítems)

- [ ] Documentar 12 objetos ancestrales (OBJ-ART-001 a 012)
- [ ] Definir lore asociado a cada uno
- [ ] Definir interacciones (mirar + lore)
- [ ] Definir rareza (solo Raro/Legendario)
- [ ] Integrar con M25 (Ruinas) y M37 (Museos)

### CAT-15: Items de Evento (5 ítems)

- [ ] Documentar 12 items de evento (OBJ-EVE-001 a 012)
- [ ] Asociar cada item a un festival específico
- [ ] Definir duración de disponibilidad
- [ ] Definir interacciones
- [ ] Integrar con M29 (Tiempo y Calendario)

### CAT-16: Items Secretos (5 ítems)

- [ ] Documentar 12 items secretos (OBJ-SEC-001 a 012)
- [ ] Definir cómo se obtienen (puzzles, quests)
- [ ] Definir lore asociado
- [ ] Definir rareza (solo Raro/Legendario)
- [ ] Integrar con M25 (Ruinas) y M23 (Misiones Secundarias)

### Diseño Visual (15 ítems)

- [ ] Crear `06-Diseno-Visual.md` con paleta global de colores
- [ ] Definir colores HEX para cada categoría de objeto
- [ ] Definir formas y proporciones por categoría
- [ ] Definir materiales por categoría
- [ ] Definir paleta por bioma (13 biomas)
- [ ] Definir reglas de variantes de color (máx 6 por malla)
- [ ] Definir proporciones para Godot (1m = 1 unidad)
- [ ] Definir LODs por categoría
- [ ] Definir texturas por material
- [ ] Crear referencias visuales para mobiliario
- [ ] Crear referencias visuales para herramientas
- [ ] Crear referencias visuales para naturaleza
- [ ] Validar paleta de colores con dirección de arte
- [ ] Documentar variaciones por bioma
- [ ] Integrar con M45 (Arte 3D) para producción de assets

### Integración y Validación (10 ítems)

- [ ] Verificar que todos los IDs son únicos
- [ ] Verificar que todas las categorías tienen objetos
- [ ] Verificar que todos los objetos tienen icono
- [ ] Verificar que todos los objetos interactuables tienen interacción definida
- [ ] Verificar que todos los objetos colocables tienen tamaño definido
- [ ] Verificar que todos los objetos de tienda tienen precio
- [ ] Verificar que la suma total es ≥ 300 objetos
- [ ] Documentar integración con M14 (Inventario)
- [ ] Documentar integración con M16 (Crafting)
- [ ] Documentar integración con M18 (Casas)

### Testing (5 ítems)

- [ ] Crear test de carga de ItemDatabase
- [ ] Crear test de búsqueda por ID
- [ ] Crear test de búsqueda por categoría
- [ ] Crear test de búsqueda por rareza
- [ ] Crear test de integración con Inventario

**Total: 135 ítems**
