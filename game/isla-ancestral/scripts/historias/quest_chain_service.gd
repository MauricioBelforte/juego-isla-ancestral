# Modelo: Step 3.7 Flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M23: Historias Secundarias — QuestChainService (autoload "Historias").
# Carga data-driven de cadenas desde data/historias/*.json, valida anti-repetición,
# expone consultas por id/estado y señales de progreso.
# ⚠️ Sin class_name: es autoload.

extends Node

signal cadena_descubierta(chain: QuestChain)
signal cadena_completada(chain: QuestChain)
signal paso_completado(chain_id: String, paso_id: String)

const SECCION_SAVE := "historias"

var _cadenas: Dictionary = {}           # id -> QuestChain
var _por_tipo: Dictionary = {}          # tipo -> Array[QuestChain]
var _estado: Dictionary = {}            # chain_id -> {paso_actual, completada, consecuencias_aplicadas}
var _validator: Script = null

func _ready() -> void:
    _cargar_cadenas()
    _registrar_proveedor_guardado()

## ── Carga data-driven ────────────────────────────────────

func _cargar_cadenas() -> void:
    var dir := DirAccess.open("res://data/historias/")
    if dir == null:
        push_warning("[M23] data/historias/ no encontrado")
        return
    dir.list_dir_begin()
    var fname := dir.get_next()
    while fname != "":
        if fname.ends_with(".json"):
            _cargar_cadena_desde_json(fname)
        fname = dir.get_next()
    dir.list_dir_end()
    _rebuild_cache()

func _cargar_cadena_desde_json(fname: String) -> void:
    var path := "res://data/historias/" + fname
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_warning("[M23] no se pudo abrir %s" % path)
        return
    var text := file.get_as_text()
    file.close()
    var json := JSON.new()
    if json.parse(text) != OK:
        push_warning("[M23] JSON inválido en %s" % path)
        return
    var data := json.get_data()
    if data is Dictionary and data.has("cadenas"):
        for chain_data in data["cadenas"]:
            _registrar_cadena(chain_data)

func _registrar_cadena(data: Dictionary) -> void:
    var chain := QuestChain.new()
    chain.id = str(data.get("id", ""))
    chain.titulo = str(data.get("titulo", ""))
    chain.contexto = str(data.get("contexto", ""))
    chain.pasos = data.get("pasos", [])
    chain.recompensa = data.get("recompensa", {})
    chain.consecuencia = data.get("consecuencia", {})
    chain.dialogo_posterior = str(data.get("dialogo_posterior", ""))
    chain.oculta = bool(data.get("oculta", false))
    chain.postgame = bool(data.get("postgame", false))
    
    # Validación anti-repetición
    var errores := chain.validar()
    if errores.size() > 0:
        push_warning("[M23] cadena '%s' inválida: %s" % [chain.id, ", ".join(errores)])
        return
    
    _cadenas[chain.id] = chain
    # Indexar por tipo
    var tipo: String = str(data.get("tipo", "general"))
    _por_tipo.setdefault(tipo, []).append(chain)

func _rebuild_cache() -> void:
    # Reconstruir índices si es necesario
    pass

## ── Consultas ────────────────────────────────────────────

func get_cadena(chain_id: String) -> QuestChain:
    return _cadenas.get(chain_id, null)

func get_cadenas_por_tipo(tipo: String) -> Array:
    return _por_tipo.get(tipo, [])

func get_cadenas_disponibles() -> Array:
    var out: Array = []
    for chain in _cadenas.values():
        if not chain.es_oculta():
            out.append(chain)
    return out

func get_cadenas_ocultas() -> Array:
    var out: Array = []
    for chain in _cadenas.values():
        if chain.es_oculta():
            out.append(chain)
    return out

func get_cadenas_postgame() -> Array:
    var out: Array = []
    for chain in _cadenas.values():
        if chain.es_postgame():
            out.append(chain)
    return out

## ── Estado de progreso ──────────────────────────────────

func get_estado_cadena(chain_id: String) -> Dictionary:
    return _estado.get(chain_id, {})

func marcar_paso_completado(chain_id: String, paso_id: String) -> void:
    if chain_id not in _estado:
        _estado[chain_id] = {"paso_actual": "", "completada": false, "consecuencias_aplicadas": false}
    _estado[chain_id]["paso_actual"] = paso_id
    paso_completado.emit(chain_id, paso_id)
    
    # Verificar si es el último paso
    var chain := get_cadena(chain_id)
    if chain != null:
        var ultimo_paso := chain.pasos.back()
        if ultimo_paso.get("id") == paso_id:
            _estado[chain_id]["completada"] = true
            cadena_completada.emit(chain)

func get_consecuencias_pendientes() -> Array:
    var out: Array = []
    for chain_id in _estado:
        var st := _estado[chain_id]
        if st.get("completada", false) and not st.get("consecuencias_aplicadas", false):
            out.append(chain_id)
    return out

## ── Persistencia (RF17 / M59) ────────────────────────────

func _registrar_proveedor_guardado() -> void:
    var sm = get_node_or_null("/root/SaveManager")
    if sm != null and sm.has_method("register_provider"):
        sm.register_provider(self)

func get_section_name() -> String:
    return SECCION_SAVE

func get_save_data() -> Dictionary:
    return {"estado_cadenas": _estado.duplicate()}

func restore_save_data(data: Dictionary) -> void:
    _estado.clear()
    var estado_data = data.get("estado_cadenas", {})
    for chain_id in estado_data:
        _estado[chain_id] = estado_data[chain_id]

## ── Validación batch (editor/CI) ────────────────────────

## Valida todas las cadenas cargadas y retorna Array de errores.
func validar_todas() -> Array:
    var errores: Array = []
    for chain in _cadenas.values():
        var errs := chain.validar()
        if errs.size() > 0:
            errores.append("Cadena '%s': %s" % [chain.id, ", ".join(errs)])
    return errores
