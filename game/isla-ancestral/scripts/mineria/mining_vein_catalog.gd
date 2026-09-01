# Modelo: MiniMax-M3
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M35: Minería — MiningVeinCatalog (catálogo data-driven de vetas mineras).
# Opción B (recomendada por Deepseek V4 Flash 2026-08-31 en plan-actual/05-Checklist.md §J):
# las vetas son nodos ResourceNode (M15) con categoria MINERAL/RARO y herramienta_requerida="pico".
# Este script NO duplica ResourceDefinition; solo lee un JSON y registra las definiciones en
# ResourceManager (M15), reutilizando el pipeline existente de drops + respawn + persistencia.
# RF1-RF4: vetas 1-3 bloques, catalogo coherente con M15, bandas de profundidad, cuevas.
# Decisión de min: si una veta ya está registrada en ResourceManager (caso _mineral_cobre),
# NO se sobreescribe — gana la definición previa para no romper M15.

class_name MiningVeinCatalog
extends RefCounted

const CATALOGO_PATH := "res://data/mining/ores.json"

## Carga el catálogo de vetas desde JSON y las registra en ResourceManager (M15).
## Devuelve la cantidad de vetas efectivamente registradas.
## Si el archivo no existe o el JSON está malformado, registra 0 y no falla.
static func cargar_y_registrar() -> int:
    var rm := _get_resource_manager()
    if rm == null:
        push_warning("[M35] ResourceManager no disponible; catalogo no cargado")
        return 0
    var ruta_abs := ProjectSettings.globalize_path(CATALOGO_PATH)
    if not FileAccess.file_exists(CATALOGO_PATH):
        push_warning("[M35] Catalogo no encontrado en %s" % CATALOGO_PATH)
        return 0
    var contenido := FileAccess.get_file_as_string(CATALOGO_PATH)
    if contenido.is_empty():
        push_warning("[M35] Catalogo vacio en %s" % CATALOGO_PATH)
        return 0
    var parsed: Variant = JSON.parse_string(contenido)
    if typeof(parsed) != TYPE_ARRAY:
        push_warning("[M35] JSON invalido (raiz no es array) en %s" % CATALOGO_PATH)
        return 0
    var vetas: Array = parsed
    var registradas := 0
    for entrada in vetas:
        if not (entrada is Dictionary):
            continue
        if _registrar_veta(rm, entrada):
            registradas += 1
    return registradas

## Registra una veta individual si no existe ya en ResourceManager.
static func _registrar_veta(rm: Node, data: Dictionary) -> bool:
    var def_id := StringName(String(data.get("id", "")))
    if def_id == &"":
        return false
    # Respetar M15: si ya existe la definición, no la sobreescribimos
    if rm.obtener_def(def_id) != null:
        return false
    var def := ResourceDefinition.new()
    def.def_id = def_id
    def.display_name = String(data.get("display_name", String(def_id)))
    var categoria_str := String(data.get("categoria", "MINERAL")).to_upper()
    match categoria_str:
        "RARO":
            def.categoria = ResourceDefinition.Categoria.RARO
        _:
            def.categoria = ResourceDefinition.Categoria.MINERAL
    var rareza := int(data.get("rareza", 0))
    def.rareza = clampi(rareza, 0, 3)
    def.herramienta_requerida = &"pico"
    def.golpes_requeridos = maxi(1, int(data.get("golpes", 2)))
    def.temporada_respawn = StringName(String(data.get("temporada_respawn", "todas")))
    var region := String(data.get("region", ""))
    def.region = StringName(region) if region != "" else &""
    def.valor_venta = maxi(0, int(data.get("valor_venta", 5)))
    def.dias_para_respawn = maxi(0, int(data.get("dias_para_respawn", 2)))
    # Drops: una sola entrada por defecto con min/max del JSON
    var drop_min := maxi(1, int(data.get("drop_min", 1)))
    var drop_max := maxi(drop_min, int(data.get("drop_max", 2)))
    var drop_entry := ResourceDropEntry.new()
    drop_entry.item_id = String(def_id)
    drop_entry.cantidad_min = drop_min
    drop_entry.cantidad_max = drop_max
    drop_entry.probabilidad = clampf(float(data.get("drop_probabilidad", 1.0)), 0.0, 1.0)
    drop_entry.requiere_herramienta_mejorada = bool(data.get("requiere_mejorada", false))
    def.drops = [drop_entry]
    rm._definiciones[def.def_id] = def
    return true

## Acceso seguro al autoload ResourceManager (sin class_name, ver 07-GUIA-GODOT §9.17).
static func _get_resource_manager() -> Node:
    return Engine.get_main_loop().root.get_node_or_null("ResourceManager")