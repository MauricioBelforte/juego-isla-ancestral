extends Node

## Autoload que gestiona todas las ubicaciones del mundo.
var locations: Dictionary = {}

signal location_loaded(location_id: String)
signal location_unloaded(location_id: String)

## Espejo local de enums para evitar dependencias de class_name
## en este autoload (Godot 4.7.2 no los resuelve en parseo).
const LOC_TYPE_PUB = 0
const LOC_TYPE_CASA = 1
const LOC_TYPE_TIE = 2
const LOC_TYPE_TAL = 3
const LOC_TYPE_CUE = 4
const LOC_TYPE_BOS = 5
const LOC_TYPE_PLA = 6
const LOC_TYPE_RUI = 7
const LOC_TYPE_PUER = 8
const LOC_TYPE_MON = 9
const LOC_TYPE_SEL = 10
const LOC_TYPE_TEM = 11

const ISLAND_RIZ = 0
const ISLAND_COR = 1
const ISLAND_CEN = 2
const ISLAND_AUR = 3

func _ready() -> void:
    _bootstrap_riz_if_needed()
    _load_all_locations()
    print("[M160] Ubicaciones cargadas: %d" % locations.size())

## Genera .tres seed para RIZ si la carpeta esta vacia.
func _bootstrap_riz_if_needed() -> void:
    var dir = DirAccess.open("res://data/locations/RIZ/")
    if not dir:
        DirAccess.make_dir_recursive_absolute("res://data/locations/RIZ/")
        dir = DirAccess.open("res://data/locations/RIZ/")
    if not dir:
        return
    dir.list_dir_begin()
    var has_tres = false
    while true:
        var f = dir.get_next()
        if f == "":
            break
        if f.ends_with(".tres"):
            has_tres = true
            break
    if has_tres:
        return

    print("[M160] Generando .tres seed de Isla Raiz...")
    _save_riz(_make_riz_pub())
    _save_riz(_make_riz_casa())
    _save_riz(_make_riz_tie())
    print("[M160] Seed RIZ generado.")

func _make_riz_pub() -> Dictionary:
    var data = {}
    data.location_id = "LOC-RIZ-PUB-001"
    data.nombre = "Pueblo Raiz"
    data.tipo = LOC_TYPE_PUB
    data.isla = ISLAND_RIZ
    data.descripcion = "Pueblo central de la Isla Raiz. Punto de encuentro y tutorial."
    data.ampliable = false
    data.tags = ["tutorial", "pueblo"]
    data.npcs = ["NPC-GUIA-001"]
    data.conexiones = ["LOC-RIZ-CASA-001", "LOC-RIZ-TIE-001"]
    data.objetos = []
    var req = {}
    req.herramienta_minima = ""
    req.costo_entrada = 0
    req.items_requeridos = []
    req.npcs_requeridos = []
    req.descripcion_requisitos = "Acceso libre"
    data.requisitos = req
    return data

func _make_riz_casa() -> Dictionary:
    var data = {}
    data.location_id = "LOC-RIZ-CASA-001"
    data.nombre = "Casa del Jugador"
    data.tipo = LOC_TYPE_CASA
    data.isla = ISLAND_RIZ
    data.descripcion = "Casa inicial del jugador en la Isla Raiz."
    data.ampliable = true
    data.tags = ["tutorial", "casa"]
    data.npcs = []
    data.conexiones = ["LOC-RIZ-PUB-001"]
    data.objetos = []
    var req = {}
    req.herramienta_minima = ""
    req.costo_entrada = 0
    req.items_requeridos = []
    req.npcs_requeridos = []
    req.descripcion_requisitos = "Acceso libre"
    data.requisitos = req
    return data

func _make_riz_tie() -> Dictionary:
    var data = {}
    data.location_id = "LOC-RIZ-TIE-001"
    data.nombre = "Tienda General"
    data.tipo = LOC_TYPE_TIE
    data.isla = ISLAND_RIZ
    data.descripcion = "Tienda basica de la Isla Raiz."
    data.ampliable = false
    data.tags = ["tienda", "economia"]
    data.npcs = ["NPC-TENDERO-001"]
    data.conexiones = ["LOC-RIZ-PUB-001"]
    data.objetos = []
    var req = {}
    req.herramienta_minima = ""
    req.costo_entrada = 0
    req.items_requeridos = []
    req.npcs_requeridos = []
    req.descripcion_requisitos = "Acceso libre"
    data.requisitos = req
    return data

func _save_riz(data: Dictionary) -> void:
    var LD = load("res://scripts/data/location_data.gd")
    var LR = load("res://scripts/data/location_requirements.gd")
    if not LD or not LR:
        print("[M160] Error cargando clases de datos")
        return
    var loc = LD.new()
    loc.location_id = data.location_id
    loc.nombre = data.nombre
    loc.tipo = data.tipo
    loc.isla = data.isla
    loc.descripcion = data.descripcion
    loc.ampliable = data.ampliable
    loc.tags = data.tags
    loc.npcs = data.npcs
    loc.conexiones = data.conexiones
    loc.objetos = data.objetos
    var req = LR.new()
    req.herramienta_minima = data.requisitos.herramienta_minima
    req.costo_entrada = data.requisitos.costo_entrada
    req.items_requeridos = data.requisitos.items_requeridos
    req.npcs_requeridos = data.requisitos.npcs_requeridos
    req.descripcion_requisitos = data.requisitos.descripcion_requisitos
    loc.requisitos = req
    var path = "res://data/locations/RIZ/%s.tres" % loc.location_id
    var result = ResourceSaver.save(loc, path)
    print("[M160] Guardado %s -> %s" % [loc.location_id, "OK" if result == OK else "FAIL"])

## Carga todas las ubicaciones desde archivos .tres, recorriendo subcarpetas.
func _load_all_locations() -> void:
    var base = "res://data/locations/"
    var dir = DirAccess.open(base)
    if not dir:
        return
    dir.list_dir_begin()
    var folder = dir.get_next()
    while folder != "":
        if folder == "" or folder == "." or folder == "..":
            folder = dir.get_next()
            continue
        if dir.current_is_dir():
            var sub = DirAccess.open(base + folder + "/")
            if sub:
                sub.list_dir_begin()
                var file_name = sub.get_next()
                while file_name != "":
                    if file_name.ends_with(".tres"):
                        var path = base + folder + "/" + file_name
                        var location = load(path)
                        if location:
                            locations[location.location_id] = location
                    file_name = sub.get_next()
        folder = dir.get_next()

## Obtiene una ubicacion por su ID
func get_location(location_id: String):
    return locations.get(location_id)

## Obtiene todas las ubicaciones de una isla
func get_locations_by_island(isla):
    var result: Array = []
    for loc in locations.values():
        if loc.isla == isla:
            result.append(loc)
    return result

## Obtiene todas las ubicaciones de un tipo
func get_locations_by_type(tipo):
    var result: Array = []
    for loc in locations.values():
        if loc.tipo == tipo:
            result.append(loc)
    return result

## Verifica si el jugador puede acceder a una ubicacion
func can_access(location_id: String, inventory, tools: Array) -> bool:
    var location = get_location(location_id)
    if not location:
        return false
    var req = location.requisitos
    if req.costo_entrada > 0:
        if not inventory or inventory.monedas < req.costo_entrada:
            return false
    for item_id in req.items_requeridos:
        if not inventory.tiene_item(item_id):
            return false
    if req.herramienta_minima:
        var tiene_herramienta = false
        for tool in tools:
            if tool == req.herramienta_minima:
                tiene_herramienta = true
                break
        if not tiene_herramienta:
            return false
    return true
