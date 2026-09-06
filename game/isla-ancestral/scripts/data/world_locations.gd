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
    cargar_catalogo_json()
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

# ═══════════ M160 iter. 5 (glm-5.3-flash): catálogo JSON + conexiones ═══════════

const RUTA_CATALOGO := "res://data/ubicaciones/ubicaciones_loc.json"

const ISLA_POR_CODIGO := {"RIZ": ISLAND_RIZ, "COR": ISLAND_COR, "CEN": ISLAND_CEN, "AUR": ISLAND_AUR}
const TIPO_POR_CODIGO := {
    "pub": LOC_TYPE_PUB, "casa": LOC_TYPE_CASA, "tie": LOC_TYPE_TIE, "tal": LOC_TYPE_TAL,
    "cue": LOC_TYPE_CUE, "bos": LOC_TYPE_BOS, "pla": LOC_TYPE_PLA, "rui": LOC_TYPE_RUI,
    "puer": LOC_TYPE_PUER, "mon": LOC_TYPE_MON, "sel": LOC_TYPE_SEL, "tem": LOC_TYPE_TEM,
}

## Carga el catálogo JSON (data-driven) y registra las ubicaciones que no
## existan como .tres. Retorna {cargadas, omitidas, errores}.
func cargar_catalogo_json() -> Dictionary:
    var res := {"cargadas": 0, "omitidas": 0, "errores": 0}
    if not FileAccess.file_exists(RUTA_CATALOGO):
        print("[M160] catálogo JSON no encontrado: %s" % RUTA_CATALOGO)
        res["errores"] = 1
        return res
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_CATALOGO))
    if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("ubicaciones"):
        print("[M160] catálogo JSON inválido")
        res["errores"] = 1
        return res
    var LD = load("res://scripts/data/location_data.gd")
    var LR = load("res://scripts/data/location_requirements.gd")
    if not LD or not LR:
        res["errores"] = 1
        return res
    for ub in parsed["ubicaciones"]:
        if typeof(ub) != TYPE_DICTIONARY or not ub.has("id"):
            res["errores"] += 1
            continue
        var id: String = ub["id"]
        if locations.has(id):
            res["omitidas"] += 1
            continue
        var loc = LD.new()
        loc.location_id = id
        loc.nombre = String(ub.get("nombre", id))
        loc.tipo = int(TIPO_POR_CODIGO.get(String(ub.get("tipo", "")), 0))
        loc.isla = int(ISLA_POR_CODIGO.get(String(ub.get("isla", "")), 0))
        loc.descripcion = String(ub.get("descripcion", ""))
        loc.ampliable = bool(ub.get("ampliable", false))
        loc.tags = ub.get("tags", [])
        loc.npcs = ub.get("npcs", [])
        loc.conexiones = ub.get("conexiones", [])
        var objetos_res: Array = []
        for o in ub.get("objetos", []):
            var LO = load("res://scripts/data/location_object.gd")
            var obj = LO.new()
            obj.item_id = String(o.get("id_objeto", ""))
            obj.recolectable = bool(o.get("recolectable", false))
            obj.tiempo_regeneracion = float(o.get("regeneracion_seg", 0.0))
            if o.has("herramienta"):
                obj.tipo_interaccion = String(o["herramienta"])
            if o.has("tier_minimo"):
                obj.notas = String(o["tier_minimo"])
            obj.interactuable = not obj.recolectable
            objetos_res.append(obj)
        loc.objetos = objetos_res
        var req_d: Dictionary = ub.get("requisitos", {})
        var req = LR.new()
        req.herramienta_minima = String(req_d.get("herramienta_minima", ""))
        req.costo_entrada = int(req_d.get("costo_entrada", 0))
        req.items_requeridos = req_d.get("items_requeridos", [])
        req.npcs_requeridos = req_d.get("npcs_requeridos", [])
        req.descripcion_requisitos = String(req_d.get("descripcion", "Acceso libre"))
        loc.requisitos = req
        locations[id] = loc
        res["cargadas"] += 1
    _reflejar_conexiones()
    print("[M160] catálogo JSON: %d cargadas, %d omitidas (.tres), %d errores" % [res["cargadas"], res["omitidas"], res["errores"]])
    return res

## Hace el grafo bidireccional EN MEMORIA (los .tres no se modifican):
## toda conexión A->B agrega B->A si falta.
func _reflejar_conexiones() -> void:
    var agregadas := 0
    for id in locations:
        var loc = locations[id]
        for destino_v in loc.conexiones:
            var destino_s := String(destino_v)
            if not locations.has(destino_s):
                continue
            var dest_conex: Array = locations[destino_s].conexiones
            if not dest_conex.has(id):
                dest_conex.append(id)
                agregadas += 1
    if agregadas > 0:
        print("[M160] conexiones bidireccionales reflejadas: %d" % agregadas)

## Verifica que todas las conexiones apunten a ubicaciones registradas y que
## sean bidireccionales. Retorna {totales, faltantes: Array, unidireccionales: Array}.
func validar_conexiones() -> Dictionary:
    var res := {"totales": 0, "faltantes": [], "unidireccionales": []}
    for id in locations:
        var loc = locations[id]
        for destino in loc.conexiones:
            res["totales"] += 1
            var destino_s := String(destino)
            if not locations.has(destino_s):
                res["faltantes"].append("%s -> %s" % [id, destino_s])
            elif not (locations[destino_s].conexiones as Array).has(id):
                res["unidireccionales"].append("%s <-> %s" % [id, destino_s])
    return res

## Devuelve las conexiones de una ubicación (IDs) para navegación/mapa.
func get_conexiones(location_id: String) -> Array:
    var loc = get_location(location_id)
    if loc == null:
        return []
    return loc.conexiones

## Objetos recolectables de una ubicación (Array de LocationObject).
func get_recolectables(location_id: String) -> Array:
    var loc = get_location(location_id)
    if loc == null:
        return []
    var res: Array = []
    for o in loc.objetos:
        if o.recolectable:
            res.append(o)
    return res
