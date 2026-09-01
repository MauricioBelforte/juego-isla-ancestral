# Modelo: MiniMax-M3
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M35: Minería — MiningManager (autoload "mineria").
# Capa de dominio de MINERIA sobre ResourceManager (M15). Reutiliza ResourceNode +
# ResourceDefinition + drops + respawn calendario M29 + persistencia M59.
# Lo que MiningManager agrega:
#   - Carga del catálogo ores.json (RF2) via MiningVeinCatalog
#   - API intentar_extraccion(nodo, tool: ToolData) que aplica RF6 (picos T3+ dan doble drop)
#   - Límite suave diario por zona (RF10) con señal zone_exhausted
#   - Persistencia de contadores de zona (SaveManager M59)
#   - Señal mina_extraccion_exitosa con el resumen (para M53 UI texto flotante)
# Pitfalls respetados (07-GUIA-GODOT):
#   - Sin class_name (autoload, §9.17/§9.41)
#   - snake_case en señales (§1.1)
#   - _ en vars no usadas (§1.3)

extends Node

signal mina_extraccion_exitosa(def_id: StringName, cantidad: int, world_pos: Vector3, zona: StringName)
signal mina_extraccion_fallida(def_id: StringName, razon: String)
signal zone_exhausted(zona: StringName)

const SECCION_SAVE := "mining_manager"
const DEFAULT_ZONE_QUOTA := 12   # limite suave diario por zona (RF10)

## Carga del catálogo al iniciar (RF2)
var _catalogo_cargado: bool = false
var _zone_quota: Dictionary = {}   # StringName (zona) -> int (extracciones hoy)
var _zone_quota_dia: Dictionary = {}  # zona -> dia_absoluto en que se reinicia

func _ready() -> void:
    # Catálogo primero (idempotente, no pisa _mineral_cobre de M15)
    var n := MiningVeinCatalog.cargar_y_registrar()
    if n > 0:
        _catalogo_cargado = true
        print("[M35] Catalogo de vetas mineras cargado: %d vetas" % n)
    # Persistencia
    var sm := _get_save_manager()
    if sm != null and sm.has_method("register_provider"):
        sm.register_provider(self)
    # Reset diario al cambio de dia (M29)
    var gt := _get_game_time()
    if gt != null and gt.has_signal("dia_cambio"):
        gt.dia_cambio.connect(_on_dia_cambio)

## ── API publica ─────────────────────────────────────────────

## Intenta extraer de un ResourceNode con la herramienta dada.
## Devuelve {ok, def_id, cantidad, zona, razon} para que el caller (M13/M53) actúe.
## tool puede ser null → rechazo suave.
func intentar_extraccion(nodo: Node, tool) -> Dictionary:
    if nodo == null or not is_instance_valid(nodo):
        return {"ok": false, "razon": "nodo_invalido"}
    if not (nodo is ResourceNode):
        return {"ok": false, "razon": "no_es_veta"}
    var rn: ResourceNode = nodo
    var rm: Node = _get_resource_manager()
    if rm == null:
        return {"ok": false, "razon": "resource_manager_ausente"}
    var def: ResourceDefinition = rm.obtener_def(rn.def_id)
    if def == null:
        return {"ok": false, "razon": "definicion_ausente"}
    # Zona: el manager puede derivarla del region del def, o "" si no hay
    var zona: String = String(def.region) if def.region != &"" else "superficie"
    # Limite suave (RF10): si la zona ya esta agotada, NO bloqueamos pero avisamos
    if _is_zone_exhausted(zona):
        mina_extraccion_fallida.emit(rn.def_id, "zona_agotada")
        return {"ok": false, "razon": "zona_agotada", "zona": zona}
    # Validar herramienta (RF5)
    var tool_id: StringName = _tool_id(tool)
    if not def.es_accesible_con(tool_id, true):
        mina_extraccion_fallida.emit(rn.def_id, "herramienta_invalida")
        return {"ok": false, "razon": "herramienta_invalida", "zona": zona}
    # Llamar al golpe real de M15 (ResourceManager.recibir_golpe_en_nodo)
    var mejorada: bool = _es_mejorada(tool)
    var ok_golpe: bool = bool(rm.recibir_golpe_en_nodo(rn, tool_id))
    if not ok_golpe:
        mina_extraccion_fallida.emit(rn.def_id, "golpe_rechazado")
        return {"ok": false, "razon": "golpe_rechazado", "zona": zona}
    # Calcular drops manualmente para aplicar RF6 (doble drop por tool_power alto)
    var cantidad: int = _calcular_drops_con_rf6(def, tool_id, mejorada, rm)
    # Consumir cuota de zona
    _consume_zone_quota(zona)
    # Emitir senal de exito
    mina_extraccion_exitosa.emit(rn.def_id, cantidad, rn.global_position, StringName(zona))
    # Log DOM-MIN
    print("[DOM-MIN] veta %s extraida en zona %s, cantidad %d (tool=%s)" % [String(rn.def_id), zona, cantidad, String(tool_id)])
    return {"ok": true, "def_id": String(rn.def_id), "cantidad": cantidad, "zona": zona}

## Devuelve true si la zona supero su cuota diaria (RF10).
func is_zone_exhausted(zona: StringName) -> bool:
    return _is_zone_exhausted(String(zona))

## Cuota restante hoy en la zona (para HUD).
func quota_restante(zona: StringName) -> int:
    var z := String(zona)
    _reset_si_cambio_dia(z)
    return maxi(0, DEFAULT_ZONE_QUOTA - int(_zone_quota.get(z, 0)))

## ── Limite suave por zona (RF10) ────────────────────────────

func _is_zone_exhausted(zona: String) -> bool:
    _reset_si_cambio_dia(zona)
    return int(_zone_quota.get(zona, 0)) >= DEFAULT_ZONE_QUOTA

func _consume_zone_quota(zona: String) -> void:
    _reset_si_cambio_dia(zona)
    _zone_quota[zona] = int(_zone_quota.get(zona, 0)) + 1
    if int(_zone_quota[zona]) >= DEFAULT_ZONE_QUOTA:
        zone_exhausted.emit(StringName(zona))
        print("[DOM-MIN] zona %s agotada por limite diario" % zona)

func _reset_si_cambio_dia(zona: String) -> void:
    var gt := _get_game_time()
    if gt == null or not gt.has_method("dia_absoluto"):
        return
    var dia_actual: int = int(gt.dia_absoluto())
    var dia_anterior: int = int(_zone_quota_dia.get(zona, -1))
    if dia_anterior != dia_actual:
        _zone_quota[zona] = 0
        _zone_quota_dia[zona] = dia_actual

func _on_dia_cambio(_info: Dictionary) -> void:
    # Reset global al cambiar el dia
    for z in _zone_quota.keys():
        _zone_quota[z] = 0

## ── RF6: doble drop por herramienta mejorada ────────────────

func _calcular_drops_con_rf6(def: ResourceDefinition, tool_id: StringName, mejorada: bool, rm: Node) -> int:
    # A partir de los drops de M15 (que ya aplican probabilidad anti-frustracion),
    # si la herramienta es mejorada y el def tiene requiere_mejorada, multiplicar.
    var drops_base: Dictionary = rm.generar_drops(def.def_id, tool_id, mejorada)
    var total := 0
    for cant in drops_base.values():
        total += int(cant)
    if mejorada and _def_tiene_drop_mejorado(def):
        total *= 2  # RF6: doble drop garantizado para picos T3+
    return maxi(1, total)

func _def_tiene_drop_mejorado(def: ResourceDefinition) -> bool:
    for d in def.drops:
        if d.requiere_herramienta_mejorada:
            return true
    return false

## ── Tool helpers ─────────────────────────────────────────────

func _tool_id(tool) -> StringName:
    if tool == null:
        return &"pico"   # fallback explicito (M13 default)
    if tool is ToolData:
        # ToolData.Nivel: COBRE=1, HIERRO=2, ORO=3, CRISTAL=4
        # Mapeamos a id jerarquico para que es_accesible_con lo acepte
        var nivel: int = int(tool.nivel) if "nivel" in tool else 1
        match nivel:
            4: return &"pico_cristal"
            3: return &"pico_oro"
            2: return &"pico_hierro"
            _: return &"pico"
    return StringName(str(tool))

func _es_mejorada(tool) -> bool:
    if tool == null:
        return false
    if tool is ToolData:
        var nivel: int = int(tool.nivel) if "nivel" in tool else 1
        return nivel >= 3   # ORO o CRISTAL
    return false

## ── Persistencia M59 ────────────────────────────────────────

func get_section_name() -> String:
    return SECCION_SAVE

func get_save_data() -> Dictionary:
    return {
        "version": 1,
        "zone_quota": _zone_quota.duplicate(),
        "zone_quota_dia": _zone_quota_dia.duplicate(),
        "catalogo_cargado": _catalogo_cargado,
    }

func restore_save_data(data: Dictionary) -> void:
    if int(data.get("version", 0)) < 1:
        return
    var zq: Dictionary = data.get("zone_quota", {})
    var zd: Dictionary = data.get("zone_quota_dia", {})
    for k in zq.keys():
        _zone_quota[String(k)] = int(zq[k])
    for k in zd.keys():
        _zone_quota_dia[String(k)] = int(zd[k])
    _catalogo_cargado = bool(data.get("catalogo_cargado", false))

## ── Accesos seguros a autoloads (07-GUIA-GODOT §9.17) ───────

func _get_resource_manager() -> Node:
    return Engine.get_main_loop().root.get_node_or_null("ResourceManager")

func _get_save_manager() -> Node:
    return Engine.get_main_loop().root.get_node_or_null("SaveManager")

func _get_game_time() -> Node:
    return Engine.get_main_loop().root.get_node_or_null("GameTime")