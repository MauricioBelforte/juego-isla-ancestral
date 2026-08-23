**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 160: Diseño de Ubicaciones del Mundo

## Checklist de Implementación (140 ítems)

### Estructura de Datos (15 ítems)

- [ ] Crear Resource `LocationData.gd` con todos los campos exportados
- [ ] Crear Resource `LocationRequirements.gd` para requisitos de acceso
- [ ] Crear Resource `LocationObject.gd` para objetos en ubicaciones
- [ ] Crear enum `LocationType` con 12 tipos
- [ ] Crear enum `IslandType` con 4 islas
- [ ] Crear Autoload `WorldLocations.gd`
- [ ] Implementar `get_location(id)` para búsqueda por ID
- [ ] Implementar `get_locations_by_island(isla)` para filtrado
- [ ] Implementar `get_locations_by_type(tipo)` para filtrado
- [ ] Implementar `can_access(location_id, inventory, tools)` para validación
- [ ] Crear carpeta `data/locations/` para Resources .tres
- [ ] Crear subcarpetas por isla (RIZ, COR, CEN, AUR)
- [ ] Validar que todos los IDs sean únicos
- [ ] Crear script de validación de IDs
- [ ] Documentar formato de IDs en README

### Isla Raíz: Pueblo (15 ítems)

- [ ] Documentar LOC-RIZ-PUB-001 (Plaza del Pueblo) con 8 objetos fijos
- [ ] Documentar LOC-RIZ-CASA-001 (Casa del Jugador) con 7 objetos
- [ ] Documentar LOC-RIZ-TIE-001 (Tienda General) con 5 objetos
- [ ] Documentar LOC-RIZ-TAL-001 (Carpintería) con 5 objetos
- [ ] Documentar LOC-RIZ-PUER-001 (Puerto) con 4 objetos
- [ ] Definir conexiones entre ubicaciones del pueblo
- [ ] Definir requisitos de acceso para cada ubicación
- [ ] Definir horarios de NPCs en tiendas
- [ ] Crear Resources .tres para cada ubicación
- [ ] Validar conexiones bidireccionales
- [ ] Definir objetos interactuables por ubicación
- [ ] Definir objetos de recolección por ubicación
- [ ] Definir objetos decorativos por ubicación
- [ ] Integrar con M39 (Tiendas) para catálogos
- [ ] Integrar con M18 (Casas) para ampliaciones

### Isla Raíz: Naturaleza (15 ítems)

- [ ] Documentar LOC-RIZ-BOS-001 (Bosque Principal) con 7 objetos
- [ ] Documentar LOC-RIZ-BOS-002 (Claros del Bosque) con 4 objetos
- [ ] Documentar LOC-RIZ-BOS-003 (Árbol Grande) con 3 objetos
- [ ] Documentar LOC-RIZ-PLA-001 (Playa Principal) con 3 objetos
- [ ] Documentar LOC-RIZ-PLA-002 (Cueva de la Playa) con 2 objetos
- [ ] Documentar LOC-RIZ-CUE-001 (Cueva de Tutorial) con 3 objetos
- [ ] Documentar LOC-RIZ-RUI-001 (Ruinas Antiguas) con 3 objetos
- [ ] Definir recursos de recolección por ubicación
- [ ] Definir tiempos de regeneración
- [ ] Definir requisitos de herramientas para recolección
- [ ] Crear Resources .tres para cada ubicación
- [ ] Validar que todos los objetos M159 existen
- [ ] Integrar con M14 (Inventario) para drops
- [ ] Integrar con M25 (Ruinas) para puzzles
- [ ] Documentar conexiones con pueblo

### Isla Coral (20 ítems)

- [ ] Documentar LOC-COR-PUB-001 (Plaza del Puerto) con 8 objetos
- [ ] Documentar LOC-COR-TIE-001 (Ferretería) con 5 objetos
- [ ] Documentar LOC-COR-TIE-002 (Pescadería) con 5 objetos
- [ ] Documentar LOC-COR-TAL-001 (Herrería) con 5 objetos
- [ ] Documentar LOC-COR-CASA-001 (Casa del Herrero) con 7 objetos
- [ ] Documentar LOC-COR-PUER-001 (Puerto Tropical) con 4 objetos
- [ ] Documentar LOC-COR-SEL-001 (Selva Tropical) con 6 objetos
- [ ] Documentar LOC-COR-SEL-002 (Cataratas) con 4 objetos
- [ ] Documentar LOC-COR-PLA-001 (Playa de Coral) con 3 objetos
- [ ] Documentar LOC-COR-PLA-002 (Arrecife) con 3 objetos
- [ ] Documentar LOC-COR-CUE-001 (Cueva del Coral) con 3 objetos
- [ ] Documentar LOC-COR-MON-001 (Monte Vigía) con 3 objetos
- [ ] Definir conexiones entre ubicaciones
- [ ] Definir requisitos de acceso
- [ ] Crear Resources .tres para cada ubicación
- [ ] Integrar con M158 (Herramientas T2)
- [ ] Integrar con M39 (Tiendas Coral)
- [ ] Validar objetos M159
- [ ] Documentar productos exclusivos
- [ ] Definir horarios de tiendas

### Isla Ceniza (20 ítems)

- [ ] Documentar LOC-CEN-PUB-001 (Plaza de la Forja) con 6 objetos
- [ ] Documentar LOC-CEN-TIE-001 (Tienda de Minerales) con 5 objetos
- [ ] Documentar LOC-CEN-TAL-001 (Herrería Avanzada) con 5 objetos
- [ ] Documentar LOC-CEN-CASA-001 (Casa del Herrero Avanzado) con 7 objetos
- [ ] Documentar LOC-CEN-PUER-001 (Puerto Minero) con 4 objetos
- [ ] Documentar LOC-CEN-MON-001 (Montaña Principal) con 5 objetos
- [ ] Documentar LOC-CEN-MON-002 (Mina Abandonada) con 4 objetos
- [ ] Documentar LOC-CEN-BOS-001 (Bosque de Cenizas) con 4 objetos
- [ ] Documentar LOC-CEN-CUE-001 (Cueva de Minerales) con 4 objetos
- [ ] Documentar LOC-CEN-CUE-002 (Cueva Profunda) con 3 objetos
- [ ] Documentar LOC-CEN-RUI-001 (Ruinas de la Forja) con 3 objetos
- [ ] Definir conexiones entre ubicaciones
- [ ] Definir requisitos de acceso (Herramienta T2 mínima)
- [ ] Crear Resources .tres para cada ubicación
- [ ] Integrar con M158 (Herramientas T3)
- [ ] Integrar con M39 (Tiendas Ceniza)
- [ ] Validar objetos M159
- [ ] Documentar minerales exclusivos
- [ ] Definir puzzle de ruinas
- [ ] Definir sistema de minas

### Isla Aurora (20 ítems)

- [ ] Documentar LOC-AUR-PUB-001 (Plaza Ancestral) con 6 objetos
- [ ] Documentar LOC-AUR-TIE-001 (Tienda de Encantamientos) con 5 objetos
- [ ] Documentar LOC-AUR-TAL-001 (Taller del Encantador) con 5 objetos
- [ ] Documentar LOC-AUR-CASA-001 (Casa del Encantador) con 7 objetos
- [ ] Documentar LOC-AUR-PUER-001 (Puerto Ancestral) con 4 objetos
- [ ] Documentar LOC-AUR-SEL-001 (Selva Ancestral) con 5 objetos
- [ ] Documentar LOC-AUR-TEM-001 (Templo de la Brisa) con 4 objetos
- [ ] Documentar LOC-AUR-TEM-002 (Templo del Sol) con 4 objetos
- [ ] Documentar LOC-AUR-TEM-003 (Templo de la Luna) con 4 objetos
- [ ] Documentar LOC-AUR-CUE-001 (Cueva de las Estrellas) con 3 objetos
- [ ] Documentar LOC-AUR-RUI-001 (Ruinas del Archivo) con 3 objetos
- [ ] Definir conexiones entre ubicaciones
- [ ] Definir requisitos de acceso (Herramienta T3 mínima)
- [ ] Crear Resources .tres para cada ubicación
- [ ] Integrar con M158 (Herramientas T4)
- [ ] Integrar con M39 (Tiendas Aurora)
- [ ] Validar objetos M159
- [ ] Documentar puzzles de templos (3 templos)
- [ ] Definir lore de ruinas
- [ ] Integrar con historia principal

### Integración y Validación (15 ítems)

- [ ] Verificar que todos los IDs de ubicaciones son únicos
- [ ] Verificar que todos los IDs de objetos M159 existen
- [ ] Verificar que todas las conexiones son bidireccionales
- [ ] Verificar que los requisitos de acceso son consistentes
- [ ] Verificar que las tiendas tienen dueño NPC
- [ ] Verificar que las casas son ampliables
- [ ] Verificar que los puertos conectan con M28
- [ ] Documentar integración con M27 (Islas)
- [ ] Documentar integración con M17 (Construcción)
- [ ] Documentar integración con M18 (Casas)
- [ ] Documentar integración con M39 (Tiendas)
- [ ] Documentar integración con M159 (Catálogo)
- [ ] Documentar integración con M158 (Herramientas)
- [ ] Documentar integración con M58 (Guardado)
- [ ] Crear test de carga de ubicaciones

### Testing (10 ítems)

- [ ] Crear test de carga de WorldLocations
- [ ] Crear test de búsqueda por ID
- [ ] Crear test de búsqueda por isla
- [ ] Crear test de búsqueda por tipo
- [ ] Crear test de validación de acceso
- [ ] Crear test de conexiones bidireccionales
- [ ] Crear test de objetos M159
- [ ] Crear test de requisitos de herramientas
- [ ] Crear test de integración con Inventario
- [ ] Crear test de guardado/carga

### Documentación (5 ítems)

- [ ] Crear README con formato de IDs
- [ ] Documentar convenciones de posicionamiento
- [ ] Documentar reglas de conexiones
- [ ] Documentar integración con otros módulos
- [ ] Crear guía para agregar nuevas ubicaciones

**Total: 140 ítems**
