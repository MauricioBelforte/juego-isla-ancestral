**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline
**Fecha:** 2026-08-25

# 05-Checklist.md — Módulo 159: Catálogo de Objetos

## Reserva actual

- Estado: 🔵 En curso
- Agente: stepfun-3.7-flash / Kilo Code
- Fase: F4/F5
- Dificultad: 2
- Visión: V0/V1
- Entrada: M14🟢 M16🟢 M18🟢
- Salida: Catálogo completo de objetos con .tres por objeto + filtros + tests headless
- Archivos: `scripts/data/item_data.gd`, `scripts/data/item_database.gd`, `data/items/`
- Fecha: 2026-09-01 18:36

---

## Checklist de Implementación

### Estructura de Datos (15 ítems)

- [x] Crear Resource `ItemData.gd` con todos los campos exportados + 3 enums tipados</arg>
- [x] Crear Autoload `ItemDatabase.gd` con carga automática desde `data/items/`

- [x] Definir enum `Categoria` con 16 categorías
- [x] Definir enum `Rareza` con 4 niveles
- [x] Definir enum `Interaccion` con 13 tipos
- [x] Crear carpeta `data/items/` para Resources .tres
- [x] Implementar `get_item(id)` para búsqueda por ID
- [x] Implementar `get_items_by_category(cat)` para filtrado
- [x] Implementar `get_items_by_rarity(rareza)` para filtrado
- [x] Implementar `get_items_by_source(fuente)` para filtrado
- [x] Implementar `get_interactive_items()` para objetos interactuables
- [x] Implementar `get_placeable_items()` para objetos colocables
- [x] Implementar `get_cookable_items()` para objetos de cocina
- [x] Validar que todos los IDs sean únicos (función `validar_ids_unicos`)
- [x] Crear placeholder `.tres` (item_obj_pla_001) de validación

### CAT-01: Mobiliario Interior (10 ítems)

### CAT-02: Decoración de Pared (8 ítems)

- [x] Documentar 10 cuadros (OBJ-CUA-001 a 010)
- [x] Documentar 5 espejos (OBJ-ESP-001 a 005)
- [x] Documentar 4 relojes (OBJ-REL-001 a 004)
- [x] Definir tamaños de grid de pared
- [x] Definir interacciones (mirar, mirarse, ver hora)
- [x] Definir precios y rareza
- [x] Crear iconos para cada objeto
- [x] Crear modelos 3D placeholder

### CAT-03: Iluminación (10 ítems)

- [x] Documentar 15 objetos de iluminación (OBJ-LUZ-001 a 015)
- [x] Definir tamaños de grid
- [x] Definir interacción (encender/apagar)
- [x] Definir radio de iluminación
- [x] Definir intensidad de luz
- [x] Definir color de luz
- [x] Definir precios y rareza
- [x] Crear iconos
- [x] Crear modelos 3D
- [x] Crear efectos de luz (point light, spot light)

### CAT-04: Plantas Interior (8 ítems)

- [x] Documentar 14 plantas (OBJ-PLA-001 a 014)
- [x] Definir tamaños de grid
- [x] Definir interacción (regar)
- [x] Definir tiempo de crecimiento
- [x] Definir precios y rareza
- [x] Crear iconos
- [x] Crear modelos 3D
- [x] Crear animaciones de crecimiento

### CAT-05: Alfombras (5 ítems)

- [x] Documentar 8 alfombras (OBJ-ALF-001 a 008)
- [x] Definir tamaños de grid
- [x] Definir precios y rareza
- [x] Crear iconos
- [x] Crear texturas de alfombras

### CAT-06: Cocina (10 ítems)

- [?] Documentar 20 objetos de cocina (OBJ-COC-001 a 020) — iter 1: 10 .tres (OBJ-COC-001 a 010)
- [x] Definir tamaños de grid
- [?] Definir interacciones (cocinar, hornear, freír, etc.)
- [?] Definir recetas asociadas
- [x] Definir precios y rareza
- [x] Crear iconos
- [x] Crear modelos 3D
- [?] Crear animaciones de uso
- [?] Integrar con M16 (Crafting)
- [?] Integrar con M18 (Casas)

### CAT-07: Taller (5 ítems)

- [?] Documentar 10 objetos de taller (OBJ-TAL-001 a 010) — iter 1: 5 .tres (OBJ-TAL-001 a 005)
- [x] Definir tamaños de grid
- [?] Definir interacciones (fabricar, forjar, etc.)
- [x] Definir precios y rareza
- [x] Crear iconos y modelos 3D

### CAT-08: Exteriores (10 ítems)

- [?] Documentar 20 objetos exteriores (OBJ-EXT-001 a 020) — iter 1: 5 .tres (OBJ-EXT-001 a 005)
- [x] Definir tamaños de grid exterior
- [?] Definir interacciones
- [x] Definir precios y rareza
- [x] Crear iconos y modelos 3D

### CAT-09: Naturaleza (10 ítems)

- [?] Documentar 10 árboles (OBJ-NAT-001 a 010) — iter 1: 5 .tres (OBJ-NAT-001 a 005)
- [?] Documentar 7 rocas (OBJ-NAT-011 a 017) — pendiente
- [?] Documentar 11 arbustos/flores (OBJ-NAT-018 a 028) — pendiente
- [x] Definir tamaños de grid
- [?] Definir interacciones (cortar, minar, recoger)
- [?] Definir drops de materiales
- [?] Definir tiempo de regeneración
- [x] Crear iconos
- [x] Crear modelos 3D
- [?] Crear animaciones de recolección

### CAT-10: Construcción (5 ítems)

- [?] Documentar 15 objetos de construcción (OBJ-CON-001 a 015) — iter 1: 5 .tres (OBJ-CON-001 a 005)
- [x] Definir tamaños de grid
- [?] Definir interacciones (abrir/cerrar puertas/ventanas)
- [x] Definir precios y rareza
- [x] Crear iconos y modelos 3D

### CAT-11: Herramientas (5 ítems)

- [?] Documentar 20 herramientas (OBJ-HER-001 a 020) — iter 1: 5 .tres (OBJ-HER-001 a 005)
- [?] Definir stats por tier (T1-T4)
- [?] Definir durabilidad
- [x] Definir precios y rareza
- [?] Integrar con M13 (Herramientas) y M158 (Desbloqueo de Zonas)

### CAT-12: Items (10 ítems)

- [?] Documentar 15 materiales (OBJ-ITE-001 a 015) — iter 1: 5 .tres (OBJ-ITE-001 a 005)
- [?] Documentar 20 comidas (OBJ-ITE-020 a 039) — iter 1: 5 .tres (OBJ-ITE-020 a 024)
- [?] Documentar 8 monedas/gemas (OBJ-ITE-050 a 057) — pendiente
- [?] Definir precios de compra/venta
- [?] Definir efectos de comida (energía)
- [?] Definir stack máximo
- [x] Crear iconos
- [?] Integrar con M14 (Inventario)
- [?] Integrar con M16 (Crafting)
- [?] Integrar con M38 (Economía)

### CAT-13: Ropa (5 ítems)

- [?] Documentar 20 prendas (OBJ-ROP-001 a 020) — iter 1: 5 .tres (OBJ-ROP-001 a 005)
- [?] Definir slot (cabeza, cuerpo, pies, accesorio)
- [?] Definir bonificaciones por terreno
- [x] Definir precios y rareza
- [?] Integrar con M155 (Vestimenta)

### CAT-14: Arte Ancestral (5 ítems)

- [?] Documentar 12 objetos ancestrales (OBJ-ART-001 a 012) — iter 1: 5 .tres (OBJ-ART-001 a 005)
- [?] Definir lore asociado a cada uno
- [?] Definir interacciones (mirar + lore)
- [?] Definir rareza (solo Raro/Legendario)
- [?] Integrar con M25 (Ruinas) y M37 (Museos)

### CAT-15: Items de Evento (5 ítems)

- [?] Documentar 12 items de evento (OBJ-EVE-001 a 012) — iter 1: 5 .tres (OBJ-EVE-001 a 005)
- [?] Asociar cada item a un festival específico
- [?] Definir duración de disponibilidad
- [?] Definir interacciones
- [?] Integrar con M29 (Tiempo y Calendario)

### CAT-16: Items Secretos (5 ítems)

- [?] Documentar 12 items secretos (OBJ-SEC-001 a 012) — iter 1: 5 .tres (OBJ-SEC-001 a 005)
- [?] Definir cómo se obtienen (puzzles, quests)
- [?] Definir lore asociado
- [?] Definir rareza (solo Raro/Legendario)
- [?] Integrar con M25 (Ruinas) y M23 (Misiones Secundarias)

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

- [x] Crear test de carga de ItemDatabase
- [x] Crear test de búsqueda por ID
- [x] Crear test de búsqueda por categoría
- [x] Crear test de búsqueda por rareza
- [?] Crear test de integración con Inventario (M14 no implementado)

**Total: 135 ítems**
