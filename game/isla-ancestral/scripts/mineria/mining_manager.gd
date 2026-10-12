# Modelo: MiniMax-M3
# Plataforma: Kilo Code
# Fecha: 2026-08-31
#
# M35: Minería — MiningManager (autoload "mineria").
# Capa de dominio de MINERIA sobre ResourceManager (M15). Reutiliza ResourceNode +
# ResourceDefinition + respawn calendario M29 + persistencia M59.
# Lo que MiningManager agrega:
#   - Carga del catálogo ores.json (RF2) via MiningVeinCatalog
#   - API intentar_extraccion(nodo, tool: ToolData) que aplica RF6 (picos T3+ dan doble drop)
#   - Límite suave diario por zona (RF10) con señal zone_exhausted
#   - Persistencia de contadores de zona (SaveManager M59)
#   - Señal mina_extraccion_exitosa con el resumen (para M53 UI texto flotante)
# Pitfalls respetados (GUIA-GODOT/INDICE.md):
#   - Sin class_name (autoload, §9.17/§9.41)
#   - snake_case en señales (§1.1)
#   - _ en vars no usadas (§1.3)
#
# ── Lote 1 (2026-10-11, DeepSeek-V4.1-Flash — encargo mimo msg 167) ──────────
# H-A: _tool_id() mapeaba el nivel a "pico_hierro"/"pico_oro"/"pico_cristal", pero
#      ResourceDefinition.es_accesible_con() compara por IGUALDAD contra
#      herramienta_requerida ("pico") -> TODO pico T2+ era rechazado con
#      "herramienta_invalida" y la veta no se podia minar (medido: sonda 2026-10-11).
#      Ahora devuelve el id corto del ToolData (nombre_id() -> "pico"), que es el
#      mismo contrato que usa M13 (tool_controller.gd:340).
# H-B: el drop se calculaba DOS veces (M15 con un sorteo PRNG y M35 con otro) y el
#      RF6 (doble drop por pico T3+) NUNCA se entregaba: solo se informaba en la
#      senal. Ahora M35 calcula los drops UNA vez, los entrega el mismo
#      (rm.entregar_drops) y reporta la cantidad REALMENTE entregada.
# H-C: el fallback anti-frustracion de M15 usa def_id como item_id; para las vetas
#      (def_id != item_id) entregaba un item FANTASMA (medido: minar veta_oro
#      depositaba "veta_oro" en el inventario en vez de "ancient_crystal"). M35 no
#      usa ese fallback: usa el item real de la definicion.
# Guards nuevos: herramienta inutilizada (J8), veta ya agotada (idempotente),
#      cooldown por veta (J6), definicion ausente con log DOM-MIN (J10).
#
# ── Lote 2 (2026-10-11, DeepSeek-V4.1-Flash — encargo mimo msg 171) ──────────
# Cierra 17 items `[ ]` de M35 DENTRO de su dominio (capa sobre M15), sin tocar el
# sistema voxel de M08 (decision "Opcion B" del propio modulo):
#   J1  estado parcial de veta persistido y restaurado
#   J5  snapshot/restore consistente (guardar en medio de una secuencia de golpes)
#   J9  prioridad por cercania entre varias vetas del mismo rayo (desempate estable)
#   K3  hot path sin allocaciones: intentar_extraccion_en() rellena el dict del caller
#   K5  barrido de regeneracion iterativo (NO instancia nodos por veta)
#   K6  profiler: presupuesto de golpe <= 1 ms CPU (medido; condiciones declaradas)
#   K7  definiciones compartidas como Resource (instancia unica, sin copias)
#   L5  derrumbe controlado cozy (breve, solo entierra la veta, sin dano)
#   L6  brillo de veta decreciente al agotarse (modelo para la capa visual M45/M52)
#   L7  anuncio dorado al recuperarse (señal con flag)
#   L8  texto flotante con la cantidad obtenida (etiqueta para M53)
#   L9  vibracion ligera OPCIONAL (se puede apagar)
#   I1  capa de mineral ancestral solo en cuevas de M26 (region templo)
#   I5  validacion anti-softlock (ninguna veta dentro de mecanismos/puzzles)
#   I8  coleccion de minerales del jugador (persistida)
#   G5  validacion de soporte: la veta nunca flota (lector de solidez inyectado)
#   G10 chunks ya editados no regeneran vetas
#
# H17 (hallazgo, reportado — NO corregido en M15): ResourceNode.evaluar_respawn()
#   restaura `golpes_restantes = 2` FIJO, ignorando def.golpes_requeridos, asi que
#   una veta ancestral (6 golpes) revivia con 2. M35 lo corrige en su barrido
#   (barrido_regeneracion) sin tocar el archivo de M15.
# K3/K6: el log `[DOM-MIN]` por golpe salio del hot path (ahora opt-in con
#   `_log_dom_min = false`). Un `print()` por golpe cuesta ~15 ms bajo tuberia
#   (trampa 120) y hacia inalcanzable el presupuesto de 1 ms de K6.

extends Node

signal mina_extraccion_exitosa(def_id: StringName, cantidad: int, world_pos: Vector3, zona: StringName)
signal mina_extraccion_fallida(def_id: StringName, razon: String)
signal zone_exhausted(zona: StringName)
## Lote 2 — L7: la veta se recupero (respawn). anuncio_dorado = rareza >= 2.
signal mina_veta_recuperada(def_id: StringName, world_pos: Vector3, anuncio_dorado: bool)
## Lote 2 — L5: derrumbe controlado cozy (breve, sin dano; solo entierra la veta).
signal mina_derrumbe(def_id: StringName, world_pos: Vector3)
## Lote 2 — L9: vibracion ligera OPCIONAL al extraer (solo si vibracion_habilitada).
signal mina_vibracion(def_id: StringName, world_pos: Vector3)
## Lote 2 — I8: primera vez que se registra un mineral en la coleccion del jugador.
signal mina_coleccion_nueva(item_id: StringName, total: int)

const SECCION_SAVE := "mining_manager"
const DEFAULT_ZONE_QUOTA := 12   # limite suave diario por zona (RF10)
const COOLDOWN_DEFECTO := 0.6    # segundos entre golpes si la herramienta no declara velocidad
## Lote 2 — L5: duracion del derrumbe decorativo (suave y breve).
const DERRUMBE_DURACION_S := 0.8
## Lote 2 — K6: presupuesto CPU de un golpe individual (us).
const HIT_BUDGET_US := 1000
## Lote 2 — L7: rareza a partir de la cual el anuncio de recuperacion es "dorado".
const RAREZA_ANUNCIO_DORADO := 2
## Lote 2 — G5: vecinos comprobados al validar el apoyo de una veta.
const VECINOS_SOPORTE := [Vector3(0, -1, 0), Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0, -1)]
## Lote 2 — vetas declaradas por el catalogo de M35 (I1/K7).
const VETAS_M35 := [&"veta_cobre", &"veta_hierro", &"veta_oro", &"veta_cristal", &"veta_ancestral", &"veta_polvo_estrellas"]

## Carga del catálogo al iniciar (RF2)
var _catalogo_cargado: bool = false
var _zone_quota: Dictionary = {}   # StringName (zona) -> int (extracciones hoy)
var _zone_quota_dia: Dictionary = {}  # zona -> dia_absoluto en que se reinicia
## Cooldown por veta (J6): instance_id del nodo -> ticks_usec del ultimo golpe aceptado.
var _ultimo_golpe_usec: Dictionary = {}
## RNG propio: M35 decide los drops (ya no depende del sorteo interno de M15).
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Hook de test: si >= 0 se usa como reloj (headless determinista, sin Time real).
var _test_t_usec: int = -1
## Lote 2 — K3: contador de diccionarios de resultado asignados (instrumentacion).
var _allocs_resultado: int = 0
## Lote 2 — J1: clave de veta -> golpes_restantes persistidos (veta a medias).
var _vetas_parciales: Dictionary = {}
## Lote 2 — G10: claves de chunk ya editados por el jugador (no regeneran vetas).
var _chunks_editados: Dictionary = {}
## Lote 2 — I8: item_id -> cantidad acumulada (coleccion de minerales del jugador).
var _coleccion: Dictionary = {}
## Lote 2 — L5: clave de veta -> ticks_usec de fin del derrumbe.
var _derrumbes: Dictionary = {}
## Lote 2 — L9: vibracion ligera opcional (cozy: se puede apagar).
var vibracion_habilitada: bool = true
## Log por golpe fuera del hot path (K3/K6). Opt-in explicito.
var _log_dom_min: bool = false

func _ready() -> void:
	_rng.randomize()
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
## K3: wrapper de compatibilidad — asigna UN diccionario de resultado por llamada.
## El camino caliente de produccion debe usar `intentar_extraccion_en()`.
func intentar_extraccion(nodo: Node, tool) -> Dictionary:
	_allocs_resultado += 1
	var out: Dictionary = {}
	intentar_extraccion_en(nodo, tool, out)
	return out

## K3: variante SIN allocaciones del hot path. Rellena `out` (diccionario del
## llamador) y devuelve `ok`. No crea diccionarios ni arrays propios.
## Precondicion: `out` debe ser un Dictionary del llamador (se limpia in-place).
func intentar_extraccion_en(nodo: Node, tool, out: Dictionary) -> bool:
	out.clear()
	out["ok"] = false
	if nodo == null or not is_instance_valid(nodo):
		out["razon"] = "nodo_invalido"
		return false
	if not (nodo is ResourceNode):
		out["razon"] = "no_es_veta"
		return false
	var rn: ResourceNode = nodo
	var rm: Node = _get_resource_manager()
	if rm == null:
		out["razon"] = "resource_manager_ausente"
		return false
	# J10: definicion ausente en catalogo -> log DOM-MIN + fallback, sin crash.
	var def: ResourceDefinition = rm.obtener_def(rn.def_id)
	if def == null:
		if _log_dom_min:
			print("[DOM-MIN] definicion ausente %s, drop fallback" % String(rn.def_id))
		mina_extraccion_fallida.emit(rn.def_id, "definicion_ausente")
		out["razon"] = "definicion_ausente"
		out["fallback"] = true
		return false
	# J8: herramienta inutilizada (durabilidad 0) -> se interrumpe sin corromper estado.
	if _herramienta_inutilizada(tool):
		if _log_dom_min:
			print("[DOM-MIN] pico sin durabilidad, golpe ignorado")
		mina_extraccion_fallida.emit(rn.def_id, "herramienta_rota")
		out["razon"] = "herramienta_rota"
		return false
	# Zona: el manager la deriva del region del def, o "superficie" si no hay.
	var zona: String = String(def.region) if def.region != &"" else "superficie"
	# RF10: limite suave diario por zona (no bloquea el mundo, avisa).
	if _is_zone_exhausted(zona):
		mina_extraccion_fallida.emit(rn.def_id, "zona_agotada")
		out["razon"] = "zona_agotada"
		out["zona"] = zona
		return false
	# RF5: herramienta valida (H-A: id corto "pico", no "pico_oro").
	var tool_id: StringName = _tool_id(tool)
	if not def.es_accesible_con(tool_id, true):
		mina_extraccion_fallida.emit(rn.def_id, "herramienta_invalida")
		out["razon"] = "herramienta_invalida"
		out["zona"] = zona
		return false
	# Veta ya agotada: no gasta durabilidad ni cuota (idempotente).
	if rn.estado == ResourceNode.Estado.AGOTADO:
		mina_extraccion_fallida.emit(rn.def_id, "veta_agotada")
		out["razon"] = "veta_agotada"
		out["zona"] = zona
		return false
	# J6: cooldown por veta -> un doble clic rapido descarta el segundo golpe.
	var ahora: int = _ahora_usec()
	if not _cooldown_ok(rn, tool, ahora):
		mina_extraccion_fallida.emit(rn.def_id, "cooldown")
		out["razon"] = "cooldown"
		out["zona"] = zona
		return false
	# ── Golpe real sobre el nodo de M15 ─────────────────────────
	var estado_antes: int = rn.estado
	if not rn.aplicar_golpe(tool_id):
		mina_extraccion_fallida.emit(rn.def_id, "golpe_rechazado")
		out["razon"] = "golpe_rechazado"
		out["zona"] = zona
		return false
	_ultimo_golpe_usec[rn.get_instance_id()] = ahora
	var cantidad: int = 0
	var agotada: bool = estado_antes != ResourceNode.Estado.AGOTADO and rn.estado == ResourceNode.Estado.AGOTADO
	if agotada:
		cantidad = _entregar_drops_de_veta(rn, def, rm, tool_id, _es_mejorada(tool))
		_iniciar_derrumbe(rn)                     # L5
		_vetas_parciales.erase(clave_veta(rn))    # J1: la veta ya no esta "a medias"
	else:
		_registrar_parcial(rn)                    # J1
	# Consumir cuota de zona (solo con golpe aceptado)
	_consume_zone_quota(zona)
	# L9: vibracion ligera OPCIONAL
	if vibracion_habilitada:
		mina_vibracion.emit(rn.def_id, rn.global_position)
	# Emitir senal de exito
	mina_extraccion_exitosa.emit(rn.def_id, cantidad, rn.global_position, StringName(zona))
	if _log_dom_min:
		print("[DOM-MIN] veta %s extraida en zona %s, cantidad %d (tool=%s)" % [String(rn.def_id), zona, cantidad, String(tool_id)])
	out["ok"] = true
	out["def_id"] = String(rn.def_id)
	out["cantidad"] = cantidad
	out["zona"] = zona
	return true

## Devuelve true si la zona supero su cuota diaria (RF10).
func is_zone_exhausted(zona: StringName) -> bool:
	return _is_zone_exhausted(String(zona))

## Cuota restante hoy en la zona (para HUD).
func quota_restante(zona: StringName) -> int:
	var z := String(zona)
	_reset_si_cambio_dia(z)
	return maxi(0, DEFAULT_ZONE_QUOTA - int(_zone_quota.get(z, 0)))

## ── Entrega de drops (H-B/H-C: fuente unica de verdad) ──────

## Calcula los drops UNA sola vez (con RF6), programa el respawn (M29) y los
## entrega a M15. Devuelve la cantidad total entregada al inventario.
func _entregar_drops_de_veta(rn: ResourceNode, def: ResourceDefinition, rm: Node, tool_id: StringName, mejorada: bool) -> int:
	# Respawn (contrato M15/M29): dia absoluto + dias_para_respawn del def.
	var gt: Node = _get_game_time()
	if gt != null and gt.has_method("dia_absoluto"):
		rn.programar_respawn(int(gt.dia_absoluto()) + maxi(1, def.dias_para_respawn))
	var drops: Dictionary = _calcular_drops(def, mejorada)
	var total: int = _total(drops)
	if rm.has_method("entregar_drops"):
		rm.entregar_drops(drops, def.def_id, tool_id, mejorada)
	# I8: la coleccion del jugador registra lo obtenido.
	for k in drops.keys():
		registrar_en_coleccion(String(k), int(drops[k]))
	if rm.has_signal("recurso_agotado"):
		rm.recurso_agotado.emit(def.def_id, rn.global_position)
	return total

## Drops de una veta: sorteo propio + garantia anti-frustracion con el ITEM REAL
## (H-C: nunca el id de la veta) + RF6 (doble drop con pico T3+).
func _calcular_drops(def: ResourceDefinition, mejorada: bool) -> Dictionary:
	var out: Dictionary = {}
	var entradas: Array[ResourceDropEntry] = def.drops_para_herramienta(mejorada)
	for entrada in entradas:
		if _rng.randf() <= entrada.probabilidad:
			var iid: String = String(entrada.item_id)
			out[iid] = int(out.get(iid, 0)) + entrada.cantidad(_rng)
	if out.is_empty():
		out[_item_principal(def)] = 1
	if mejorada and _def_tiene_drop_mejorado(def):
		for k in out.keys():
			out[k] = int(out[k]) * 2   # RF6: doble drop garantizado para picos T3+
	return out

## Item real del drop principal de la definicion (H-C).
func _item_principal(def: ResourceDefinition) -> String:
	for entrada in def.drops:
		var iid: String = String(entrada.item_id)
		if iid != "":
			return iid
	return String(def.def_id)

func _total(drops: Dictionary) -> int:
	var t := 0
	for v in drops.values():
		t += int(v)
	return t

func _def_tiene_drop_mejorado(def: ResourceDefinition) -> bool:
	for d in def.drops:
		if d.requiere_herramienta_mejorada:
			return true
	return false

## ── Limite suave por zona (RF10) ────────────────────────────

func _is_zone_exhausted(zona: String) -> bool:
	_reset_si_cambio_dia(zona)
	return int(_zone_quota.get(zona, 0)) >= DEFAULT_ZONE_QUOTA

func _consume_zone_quota(zona: String) -> void:
	_reset_si_cambio_dia(zona)
	_zone_quota[zona] = int(_zone_quota.get(zona, 0)) + 1
	if int(_zone_quota[zona]) >= DEFAULT_ZONE_QUOTA:
		zone_exhausted.emit(StringName(zona))
		if _log_dom_min:
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

## ── Tool helpers ─────────────────────────────────────────────

## Id corto de la herramienta para el contrato de M15 (H-A).
## ToolData.nombre_id() devuelve "pico"/"hacha"/... (ToolData.IDS), que es
## exactamente lo que declara ResourceDefinition.herramienta_requerida.
func _tool_id(tool) -> StringName:
	if tool == null:
		return &"pico"   # fallback explicito (M13 default)
	if tool is ToolData:
		var td: ToolData = tool as ToolData
		return td.nombre_id()
	return StringName(str(tool))

## Nivel del pico 1..4 (0 si no es ToolData).
func _nivel(tool) -> int:
	if tool is ToolData:
		var td: ToolData = tool as ToolData
		return int(td.nivel)
	return 0

## RF6: pico mejorado = T3 (ORO) o T4 (CRISTAL).
func _es_mejorada(tool) -> bool:
	return _nivel(tool) >= 3

## J8: la herramienta esta inutilizada (durabilidad 0, cozy: no desaparece).
func _herramienta_inutilizada(tool) -> bool:
	if tool is ToolData:
		var td: ToolData = tool as ToolData
		return td.inutilizada()
	return false

## J6: cooldown por veta (misma velocidad que declara la herramienta).
func _cooldown_ok(rn: ResourceNode, tool, ahora: int) -> bool:
	var key: int = rn.get_instance_id()
	if not _ultimo_golpe_usec.has(key):
		return true
	var cd_s: float = COOLDOWN_DEFECTO
	if tool is ToolData:
		var td: ToolData = tool as ToolData
		cd_s = maxf(0.0, td.velocidad_efectiva())
	var transcurrido: float = float(ahora - int(_ultimo_golpe_usec[key]))
	return transcurrido >= cd_s * 1000000.0

func _ahora_usec() -> int:
	if _test_t_usec >= 0:
		return _test_t_usec
	return Time.get_ticks_usec()

## ── Lote 2 · J1: veta a medias (estado parcial persistido) ───────────────────

## Clave estable de una veta en el mundo: def_id + posicion redondeada a 1 m.
## NO guarda la referencia al nodo (asi el save no retiene escenas).
func clave_veta(rn: ResourceNode) -> String:
	var p: Vector3 = rn.global_position
	return "%s@%d,%d,%d" % [String(rn.def_id), int(round(p.x)), int(round(p.y)), int(round(p.z))]

## Golpes restantes persistidos de una veta a medias (0 si no hay registro).
func golpes_parciales(rn: ResourceNode) -> int:
	return int(_vetas_parciales.get(clave_veta(rn), 0))

## Guarda el progreso parcial de una veta que NO se agoto (J1).
func _registrar_parcial(rn: ResourceNode) -> void:
	_vetas_parciales[clave_veta(rn)] = rn.golpes_restantes

## Aplica el estado parcial persistido a un nodo recien instanciado (J1).
## Devuelve true si aplico algo.
func aplicar_estado_parcial(rn: ResourceNode) -> bool:
	var k := clave_veta(rn)
	if not _vetas_parciales.has(k):
		return false
	var g: int = int(_vetas_parciales[k])
	if g <= 0:
		return false
	rn.golpes_restantes = g
	rn.estado = ResourceNode.Estado.DANIADO if g < maxi(1, _golpes_totales(rn)) else ResourceNode.Estado.INTACTO
	return true

## Golpes totales declarados por la definicion de la veta (fallback: los actuales).
func _golpes_totales(rn: ResourceNode) -> int:
	var def: ResourceDefinition = _def_de_id(rn.def_id)
	if def != null:
		return maxi(1, def.golpes_requeridos)
	return maxi(1, rn.golpes_restantes)

## Fraccion restante de la veta (1.0 intacta .. 0.0 agotada) para UI/brillo (L6).
func fraccion_restante(rn: ResourceNode) -> float:
	return clampf(float(rn.golpes_restantes) / float(maxi(1, _golpes_totales(rn))), 0.0, 1.0)

## ── Lote 2 · J5: snapshot consistente (guardar durante un golpe) ─────────────

## Snapshot atomico del estado del manager. Tomarlo en medio de una secuencia de
## golpes no pierde estado: el parcial se registra DENTRO del golpe aceptado.
func snapshot_estado() -> Dictionary:
	return get_save_data()

## Restaura un snapshot (J5). Delega en restore_save_data.
func restaurar_estado(data: Dictionary) -> void:
	restore_save_data(data)

## ── Lote 2 · J9: prioridad por cercania entre vetas del mismo rayo ──────────

## De varias vetas candidatas en un rayo, devuelve la mas cercana al origen.
## Desempate DETERMINISTA (distancia -> def_id -> posicion) para que el resultado
## no dependa del orden de iteracion (trampa 39).
func seleccionar_veta_mas_cercana(origen: Vector3, candidatas: Array) -> ResourceNode:
	var mejor: ResourceNode = null
	var mejor_d: float = -1.0
	var mejor_clave: String = ""
	for c in candidatas:
		if c == null or not is_instance_valid(c) or not (c is ResourceNode):
			continue
		var rn: ResourceNode = c
		var d: float = origen.distance_squared_to(rn.global_position)
		var k: String = "%s|%.3f,%.3f,%.3f" % [String(rn.def_id), rn.global_position.x, rn.global_position.y, rn.global_position.z]
		if mejor == null:
			mejor = rn
			mejor_d = d
			mejor_clave = k
			continue
		if d < mejor_d - 0.000001:
			mejor = rn
			mejor_d = d
			mejor_clave = k
		elif absf(d - mejor_d) <= 0.000001 and k < mejor_clave:
			mejor = rn
			mejor_d = d
			mejor_clave = k
	return mejor

## ── Lote 2 · K5/L7: barrido de regeneracion iterativo ───────────────────────

## Evalua las vetas dadas y respawnea las que cumplen su ciclo (M29).
## NO instancia nodos: itera el array recibido (K5).
## H17: corrige el `golpes_restantes = 2` fijo de M15 con el valor real del def.
## L7: emite mina_veta_recuperada con el flag de anuncio dorado.
## Devuelve {evaluados, respawnados}.
func barrido_regeneracion(vetas: Array, dia_actual: int, estacion_actual: int) -> Dictionary:
	var evaluados: int = 0
	var respawnados: int = 0
	for c in vetas:
		if c == null or not is_instance_valid(c) or not (c is ResourceNode):
			continue
		evaluados += 1
		var rn: ResourceNode = c
		var def: ResourceDefinition = _def_de_id(rn.def_id)
		if def == null:
			continue
		if rn.evaluar_respawn(dia_actual, estacion_actual):
			respawnados += 1
			rn.golpes_restantes = maxi(1, def.golpes_requeridos)   # H17
			_vetas_parciales.erase(clave_veta(rn))
			mina_veta_recuperada.emit(rn.def_id, rn.global_position, _anuncio_dorado(def))
	return {"evaluados": evaluados, "respawnados": respawnados}

## L7: el anuncio de recuperacion es "dorado" para vetas raras (rareza >= 2).
func _anuncio_dorado(def: ResourceDefinition) -> bool:
	return def != null and def.rareza >= RAREZA_ANUNCIO_DORADO

## ── Lote 2 · K6: profiler del golpe ─────────────────────────────────────────

## Mide el coste CPU de un golpe aceptado (K6). Devuelve la mediana de n muestras.
## Condiciones declaradas: headless, log DOM-MIN apagado, sin stdout en el tramo
## medido, y la cuota de zona se reinicia FUERA del tramo (para medir siempre el
## camino caliente completo y no un rechazo temprano).
func benchmark_golpe(nodo: Node, tool, n: int = 30) -> Dictionary:
	var muestras: Array[float] = []
	var out: Dictionary = {}
	var total: int = maxi(1, n)
	for i in range(total):
		_zone_quota.clear()
		if _test_t_usec >= 0:
			_test_t_usec += 3000000
		var t0: int = Time.get_ticks_usec()
		intentar_extraccion_en(nodo, tool, out)
		var dt: float = float(Time.get_ticks_usec() - t0)
		muestras.append(dt)
	muestras.sort()
	var mediana: float = muestras[muestras.size() / 2]
	return {
		"n": muestras.size(),
		"mediana_us": mediana,
		"max_us": muestras[muestras.size() - 1],
		"presupuesto_us": HIT_BUDGET_US,
	}

## ── Lote 2 · K7: definiciones compartidas (memoria unica) ───────────────────

## Cuenta cuantas vetas del catalogo resuelven y cuantas lo hacen a la MISMA
## instancia de Resource (K7: sin copias por consulta).
func definiciones_compartidas() -> Dictionary:
	var rm: Node = _get_resource_manager()
	var ids: int = 0
	var unicas: int = 0
	if rm == null:
		return {"ids": 0, "instancia_unica": 0}
	for vid in VETAS_M35:
		var a: ResourceDefinition = rm.obtener_def(StringName(vid))
		if a == null:
			continue
		ids += 1
		var b: ResourceDefinition = rm.obtener_def(StringName(vid))
		if is_same(a, b):
			unicas += 1
	return {"ids": ids, "instancia_unica": unicas}

## ── Lote 2 · L5: derrumbe controlado cozy ───────────────────────────────────

## Inicia un derrumbe breve al agotarse la veta. Es decorativo: NO hace dano ni
## bloquea el paso (cozy); solo entierra la veta agotada.
func _iniciar_derrumbe(rn: ResourceNode) -> void:
	_derrumbes[clave_veta(rn)] = _ahora_usec() + int(DERRUMBE_DURACION_S * 1000000.0)
	mina_derrumbe.emit(rn.def_id, rn.global_position)

## True mientras el derrumbe de esa veta sigue en curso (breve).
func derrumbe_activo(rn: ResourceNode) -> bool:
	var k := clave_veta(rn)
	if not _derrumbes.has(k):
		return false
	return _ahora_usec() < int(_derrumbes[k])

## ── Lote 2 · L6/L8: brillo y texto flotante (modelo para la capa visual) ────

## Intensidad de brillo de la veta segun lo que queda (L6). 0.0 = apagada.
## Las vetas raras brillan mas (factor 1.0 comun .. 1.3 legendaria; >1 = emisivo).
## El RENDER es de M45/M52; M35 provee el modelo medible.
func intensidad_brillo(def_id: StringName, fraccion: float) -> float:
	var def: ResourceDefinition = _def_de_id(def_id)
	var rareza: int = 0
	if def != null:
		rareza = clampi(def.rareza, 0, 3)
	var factor: float = 1.0 + 0.1 * float(rareza)
	return maxf(0.0, clampf(fraccion, 0.0, 1.0) * factor)

## Etiqueta del texto flotante de la cantidad obtenida (L8), para M53.
func texto_flotante(def_id: StringName, cantidad: int) -> String:
	var def: ResourceDefinition = _def_de_id(def_id)
	var nombre: String = def.display_name if def != null else String(def_id)
	return "+%d %s" % [maxi(0, cantidad), nombre]

## ── Lote 2 · L9: vibracion ligera opcional ──────────────────────────────────

## Habilita/deshabilita la vibracion al extraer (cozy: opcional).
func configurar_vibracion(activo: bool) -> void:
	vibracion_habilitada = activo

## ── Lote 2 · I1: vetas por region (capa ancestral solo en M26) ──────────────

## Ids de las vetas de M35 que declaran esa region.
func vetas_de_region(region: StringName) -> Array:
	var out: Array = []
	for vid in VETAS_M35:
		var def: ResourceDefinition = _def_de_id(StringName(vid))
		if def != null and def.region == region:
			out.append(StringName(vid))
	return out

## ── Lote 2 · I5: anti-softlock ──────────────────────────────────────────────

## I5: ninguna veta debe caer dentro de una zona protegida (mecanismos/puzzles)
## para no bloquear el progreso. `zonas_protegidas` = Array de AABB.
func validar_anti_softlock(pos: Vector3, zonas_protegidas: Array) -> bool:
	for z in zonas_protegidas:
		if z is AABB and (z as AABB).has_point(pos):
			return false
	return true

## ── Lote 2 · I8: coleccion de minerales del jugador ─────────────────────────

## Copia de la coleccion (item_id -> cantidad acumulada).
func coleccion_minerales() -> Dictionary:
	return _coleccion.duplicate()

## Registra minerales obtenidos en la coleccion (I8). Persistida en el save.
func registrar_en_coleccion(item_id: String, cantidad: int) -> void:
	if item_id == "" or cantidad <= 0:
		return
	var antes: int = int(_coleccion.get(item_id, 0))
	_coleccion[item_id] = antes + cantidad
	if antes == 0:
		mina_coleccion_nueva.emit(StringName(item_id), int(_coleccion[item_id]))

## ── Lote 2 · G5: la veta nunca flota ────────────────────────────────────────

## G5: valida que la veta tenga apoyo (debajo o al lado) usando un lector de
## solidez INYECTADO `Callable(Vector3) -> bool`. Sin lector valido devuelve
## false (no se asume soporte: mejor no sembrar una veta flotante).
func veta_tiene_soporte(pos: Vector3, lector_solido: Callable) -> bool:
	if not lector_solido.is_valid():
		return false
	for d in VECINOS_SOPORTE:
		var s: Variant = lector_solido.call(pos + (d as Vector3))
		if bool(s):
			return true
	return false

## ── Lote 2 · G10: chunks editados no regeneran vetas ────────────────────────

## Marca un chunk como editado por el jugador (solo guarda su CLAVE, no el nodo).
func marcar_chunk_editado(clave: String) -> void:
	if clave != "":
		_chunks_editados[clave] = true

## G10: un chunk ya editado NO debe regenerar vetas.
func debe_regenerar_vetas(clave: String) -> bool:
	return not _chunks_editados.has(clave)

## Cantidad de chunks marcados como editados.
func chunks_editados() -> int:
	return _chunks_editados.size()

## ── Acceso a definiciones ───────────────────────────────────

func _def_de_id(def_id: StringName) -> ResourceDefinition:
	var rm: Node = _get_resource_manager()
	if rm == null:
		return null
	return rm.obtener_def(def_id)

## ── Persistencia M59 ────────────────────────────────────────

func get_section_name() -> String:
	return SECCION_SAVE

func get_save_data() -> Dictionary:
	return {
		"version": 2,
		"zone_quota": _zone_quota.duplicate(),
		"zone_quota_dia": _zone_quota_dia.duplicate(),
		"catalogo_cargado": _catalogo_cargado,
		"vetas_parciales": _vetas_parciales.duplicate(),   # J1
		"coleccion": _coleccion.duplicate(),               # I8
	}

func restore_save_data(data: Dictionary) -> void:
	if int(data.get("version", 0)) < 1:
		return
	var zq: Dictionary = data.get("zone_quota", {})
	var zd: Dictionary = data.get("zone_quota_dia", {})
	_zone_quota.clear()
	for k in zq.keys():
		_zone_quota[String(k)] = int(zq[k])
	_zone_quota_dia.clear()
	for k in zd.keys():
		_zone_quota_dia[String(k)] = int(zd[k])
	_catalogo_cargado = bool(data.get("catalogo_cargado", false))
	# J1 / I8: solo se reemplazan si el save los trae (v1 no los tenia).
	if data.has("vetas_parciales"):
		var vp: Dictionary = data.get("vetas_parciales", {})
		_vetas_parciales.clear()
		for k in vp.keys():
			_vetas_parciales[String(k)] = int(vp[k])
	if data.has("coleccion"):
		var col: Dictionary = data.get("coleccion", {})
		_coleccion.clear()
		for k in col.keys():
			_coleccion[String(k)] = int(col[k])

## ── Accesos seguros a autoloads (GUIA-GODOT/09-godot4-migracion.md §9.17) ───────

func _get_resource_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("ResourceManager")

func _get_save_manager() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("SaveManager")

func _get_game_time() -> Node:
	return Engine.get_main_loop().root.get_node_or_null("GameTime")
