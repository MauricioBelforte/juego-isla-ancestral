**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 160: Diseño de Ubicaciones del Mundo

## 1. Estructura de Datos Propuesta

### 1.1 Resource: LocationData.gd

```gdscript
## Datos de una ubicación del mundo.
class_name LocationData
extends Resource

## ID de la ubicación (formato LOC-ISLA-TIPO-NÚMERO)
@export var location_id: String

## Nombre de la ubicación
@export var nombre: String

## Tipo de ubicación
@export var tipo: LocationType

## Isla donde se encuentra
@export var isla: IslandType

## Descripción breve
@export var descripcion: String

## Requisitos de acceso (herramientas, monedas, items)
@export var requisitos: LocationRequirements

## Lista de objetos en esta ubicación
@export var objetos: Array[LocationObject]

## NPCs asociados a esta ubicación
@export var npcs: Array[String]

## Conexiones con otras ubicaciones (IDs)
@export var conexiones: Array[String]

## Si esta ubicación es ampliable por el jugador
@export var ampliable: bool

## Tags para filtrado (tutorial, puzzle, boss, etc.)
@export var tags: Array[String]
```

### 1.2 Enum: LocationType.gd

```gdscript
## Tipos de ubicación del mundo.
enum LocationType {
    PUB,    ## Pueblo
    CASA,   ## Casa
    TIE,    ## Tienda
    TAL,    ## Taller
    CUE,    ## Cueva
    BOS,    ## Bosque
    PLA,    ## Playa
    RUI,    ## Ruinas
    PUER,   ## Puerto
    MON,    ## Monte
    SEL,    ## Selva
    TEM     ## Templo
}
```

### 1.3 Enum: IslandType.gd

```gdscript
## Islas del juego.
enum IslandType {
    RIZ,    ## Isla Raíz (Tutorial, Carpintería)
    COR,    ## Isla Coral (Herrería, Pesca)
    CEN,    ## Isla Ceniza (Herrería Avanzada, Recursos)
    AUR     ## Isla Aurora (Encantamiento, Historia)
}
```

### 1.4 Resource: LocationRequirements.gd

```gdscript
## Requisitos para acceder a una ubicación.
class_name LocationRequirements
extends Resource

## Herramienta mínima requerida (ej: "T1", "T2")
@export var herramienta_minima: String

## Monedas necesarias (0 = gratis)
@export var costo_entrada: int

## Items especiales requeridos
@export var items_requeridos: Array[String]

## NPCs que deben estar presentes
@export var npcs_requeridos: Array[String]

## Descripción legible de los requisitos
@export var descripcion_requisitos: String
```

### 1.5 Resource: LocationObject.gd

```gdscript
## Objeto dentro de una ubicación.
class_name LocationObject
extends Resource

## ID del objeto en M159 (ej: OBJ-CAM-001)
@export var item_id: String

## Nombre del objeto
@export var nombre: String

## Posición en la ubicación (coordenadas locales)
@export var posicion: Vector3

## Rotación en grados (0, 90, 180, 270)
@export var rotacion: float

## Variante del objeto (si aplica)
@export var variante: String

## Si el objeto es interactuable
@export var interactuable: bool

## Tipo de interacción (si interactuable)
@export var tipo_interaccion: String

## Si el objeto es de recolección (se puede recoger)
@export var recolectable: bool

## Recurso que drops (si recolectable)
@export var drop_recurso: String

## Cantidad de drops
@export var drop_cantidad: int

## Tiempo de regeneración en segundos (0 = no regenera)
@export var tiempo_regeneracion: float

## Notas para artistas/programadores
@export var notas: String
```

### 1.6 Autoload: WorldLocations.gd

```gdscript
## Autoload que gestiona todas las ubicaciones del mundo.
extends Node

## Diccionario de ubicaciones: location_id -> LocationData
var locations: Dictionary = {}

## Señal cuando se carga una ubicación
signal location_loaded(location_id: String)

## Señal cuando se descarga una ubicación
signal location_unloaded(location_id: String)

func _ready() -> void:
    _load_all_locations()

## Carga todas las ubicaciones desde archivos .tres
func _load_all_locations() -> void:
    var dir = DirAccess.open("res://data/locations/")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".tres"):
                var location = load("res://data/locations/" + file_name) as LocationData
                if location:
                    locations[location.location_id] = location
            file_name = dir.get_next()

## Obtiene una ubicación por su ID
func get_location(location_id: String) -> LocationData:
    return locations.get(location_id)

## Obtiene todas las ubicaciones de una isla
func get_locations_by_island(isla: IslandType) -> Array[LocationData]:
    var result: Array[LocationData] = []
    for loc in locations.values():
        if loc.isla == isla:
            result.append(loc)
    return result

## Obtiene todas las ubicaciones de un tipo
func get_locations_by_type(tipo: LocationType) -> Array[LocationData]:
    var result: Array[LocationData] = []
    for loc in locations.values():
        if loc.tipo == tipo:
            result.append(loc)
    return result

## Verifica si el jugador puede acceder a una ubicación
func can_access(location_id: String, inventory: InventoryData, tools: Array[String]) -> bool:
    var location = get_location(location_id)
    if not location:
        return false
    
    var req = location.requisitos
    
    # Verificar herramienta mínima
    if req.herramienta_minima != "":
        if not tools.has(req.herramienta_minima):
            return false
    
    # Verificar monedas
    if req.costo_entrada > 0:
        if inventory.get_currency() < req.costo_entrada:
            return false
    
    # Verificar items requeridos
    for item in req.items_requeridos:
        if not inventory.has_item(item):
            return false
    
    return true
```

## 2. Archivos de Datos

### 2.1 Estructura de Carpetas

```
data/
├── locations/
│   ├── RIZ/
│   │   ├── LOC-RIZ-PUB-001.tres
│   │   ├── LOC-RIZ-CASA-001.tres
│   │   ├── LOC-RIZ-TIE-001.tres
│   │   ├── LOC-RIZ-TAL-001.tres
│   │   ├── LOC-RIZ-PUER-001.tres
│   │   ├── LOC-RIZ-BOS-001.tres
│   │   ├── LOC-RIZ-BOS-002.tres
│   │   ├── LOC-RIZ-BOS-003.tres
│   │   ├── LOC-RIZ-PLA-001.tres
│   │   ├── LOC-RIZ-PLA-002.tres
│   │   ├── LOC-RIZ-CUE-001.tres
│   │   └── LOC-RIZ-RUI-001.tres
│   ├── COR/
│   │   ├── LOC-COR-PUB-001.tres
│   │   └── ... (12 archivos)
│   ├── CEN/
│   │   ├── LOC-CEN-PUB-001.tres
│   │   └── ... (11 archivos)
│   └── AUR/
│       ├── LOC-AUR-PUB-001.tres
│       └── ... (11 archivos)
```

### 2.2 Ejemplo: LOC-RIZ-CASA-001.tres

```gdscript
[gd_resource type="Resource" script_class="LocationData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/data/LocationData.gd" id="1"]

[resource]
script = ExtResource("1")
location_id = "LOC-RIZ-CASA-001"
nombre = "Casa del Jugador"
tipo = 1  # CASA
isla = 0  # RIZ
descripcion = "Choza básica de madera con 1 habitación"
requisitos = null  # Sin requisitos
ampliable = true
tags = ["tutorial", "casa_jugador"]

objects = [
    {
        "item_id": "OBJ-CAM-001",
        "nombre": "Cama Simple",
        "posicion": Vector3(2, 0, 3),
        "rotacion": 0,
        "interactuable": true,
        "tipo_interaccion": "dormir"
    },
    {
        "item_id": "OBJ-EST-001",
        "nombre": "Estantería Baja",
        "posicion": Vector3(0, 0, 0),
        "rotacion": 0,
        "interactuable": true,
        "tipo_interaccion": "almacenamiento"
    }
]
```

## 3. Integración con Otros Módulos

### 3.1 M27 (Islas)

```gdscript
# En IslandManager.gd
func get_island_locations(isla: IslandType) -> Array[LocationData]:
    return WorldLocations.get_locations_by_island(isla)
```

### 3.2 M17 (Construcción)

```gdscript
# En BuildSystem.gd
func can_build_at(location_id: String) -> bool:
    var location = WorldLocations.get_location(location_id)
    return location and location.ampliable
```

### 3.3 M18 (Casas)

```gdscript
# En HouseManager.gd
func get_house_location(house_id: String) -> LocationData:
    return WorldLocations.get_location(house_id)
```

### 3.4 M39 (Tiendas)

```gdscript
# En ShopManager.gd
func get_shop_location(shop_id: String) -> LocationData:
    return WorldLocations.get_location(shop_id)
```

### 3.5 M159 (Catálogo de Objetos)

```gdscript
# En ItemDatabase.gd
func get_item_for_location(item_id: String) -> ItemData:
    return get_item(item_id)
```

### 3.6 M58 (Guardado)

```gdscript
# En SaveManager.gd
func save_locations() -> Dictionary:
    var data = {}
    for loc in WorldLocations.locations.values():
        data[loc.location_id] = {
            "objects": loc.objetos,
            "state": loc.get_state()
        }
    return data

func load_locations(data: Dictionary) -> void:
    for loc_id in data.keys():
        var loc = WorldLocations.get_location(loc_id)
        if loc:
            loc.set_state(data[loc_id])
```

## 4. Validación de IDs

### 4.1 Script de Validación

```gdscript
# validate_location_ids.gd (Editor tool)
extends EditorScript

func _run() -> void:
    var locations = WorldLocations.locations
    var item_database = ItemDatabase.items
    
    var errors = []
    
    for loc_id in locations.keys():
        var loc = locations[loc_id]
        
        # Validar formato de ID
        if not loc_id.begins_with("LOC-"):
            errors.append("ID inválido: " + loc_id)
        
        # Validar que todos los objetos existen en M159
        for obj in loc.objetos:
            if not item_database.has(obj.item_id):
                errors.append("Objeto no existe en M159: " + obj.item_id + " en " + loc_id)
        
        # Validar conexiones
        for conn in loc.conexiones:
            if not locations.has(conn):
                errors.append("Conexión inválida: " + conn + " en " + loc_id)
    
    if errors.is_empty():
        print("✅ Todos los IDs son válidos")
    else:
        for error in errors:
            print("❌ " + error)
```

### 4.2 Formato de Validación

```
LOC-[ISLA]-[TIPO]-[NÚMERO]

ISLA: RIZ | COR | CEN | AUR
TIPO: PUB | CASA | TIE | TAL | CUE | BOS | PLA | RUI | PUER | MON | SEL | TEM
NÚMERO: 001-999

Ejemplos válidos:
- LOC-RIZ-CASA-001 ✓
- LOC-COR-TIE-002 ✓
- LOC-CEN-CUE-001 ✓
- LOC-AUR-TEM-003 ✓

Ejemplos inválidos:
- LOC-XYZ-CASA-001 ✗ (isla inválida)
- LOC-RIZ-XXX-001 ✗ (tipo inválido)
- LOC-RIZ-CASA-00 ✗ (número incompleto)
```
