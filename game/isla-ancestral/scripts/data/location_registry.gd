class_name LocationRegistry
extends Resource

enum LocationType {
    PUB = 0,
    CASA = 1,
    TIE = 2,
    TAL = 3,
    CUE = 4,
    BOS = 5,
    PLA = 6,
    RUI = 7,
    PUER = 8,
    MON = 9,
    SEL = 10,
    TEM = 11
}

enum IslandType {
    RIZ = 0,
    COR = 1,
    CEN = 2,
    AUR = 3
}

class LocationRequirements extends Resource:
    @export var herramienta_minima: String
    @export var costo_entrada: int
    @export var items_requeridos: Array[String]
    @export var npcs_requeridos: Array[String]
    @export var descripcion_requisitos: String

class LocationObject extends Resource:
    @export var item_id: String
    @export var nombre: String
    @export var posicion: Vector3
    @export var rotacion: float
    @export var variante: String
    @export var interactuable: bool
    @export var tipo_interaccion: String
    @export var recolectable: bool
    @export var drop_recurso: String
    @export var drop_cantidad: int
    @export var tiempo_regeneracion: float
    @export var notas: String

class LocationData extends Resource:
    @export var location_id: String
    @export var nombre: String
    @export var tipo: int
    @export var isla: int
    @export var descripcion: String
    @export var requisitos: LocationRequirements
    @export var objetos: Array[LocationObject]
    @export var npcs: Array[String]
    @export var conexiones: Array[String]
    @export var ampliable: bool
    @export var tags: Array[String]

static func location_type(value: int) -> int:
    return value

static func island_type(value: int) -> int:
    return value
