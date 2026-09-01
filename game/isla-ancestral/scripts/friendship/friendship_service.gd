# Modelo: Hy3 (WorkBuddy)
# Plataforma: WorkBuddy AI
# Fecha: 2026-08-30
#
# M20: Amistad — FriendshipService (autoload "Friendship")
# Unica autoridad del estado de amistad por vecino. Evalua regalos
# (GiftEvaluator), registra charlas/envia cartas, aplica puntos, resuelve
# subidas de nivel y emite sobre EventBus (M07 dominio NPC):
#   EventBus.npc.friendship_level_up(npc_id, new_level)
#   EventBus.npc.gift_given(npc_id, item_id, liked)
#   EventBus.npc.cumpleanos(npc_id, edad)              [nuevo]
#   EventBus.npc.carta_recibida(npc_id, respuesta_id)  [nuevo]
# Proveedor de guardado (M59): seccion "friendship".
#
# Integracion M29 (Tiempo y Calendario): el servicio consume el calendario de
# Aurora (TimeCalendar/GameClock) para (a) fechas de cumpleanos (mes/dia),
# (b) limites diarios y (c) la maduracion de cartas al dia siguiente. La
# fuente de verdad del dia es dia_absoluto() (monotono); los limites diarios
# y la maduracion de cartas usan ese contador para no romperse en el paso de
# mes (28->1) ni de ano.
#
# ⚠️ Sin class_name: es autoload (pitfall documentado). GiftEvaluator/VecinoAmistad
# son class_name.
extends Node

const EVALUADOR_SCRIPT := preload("res://scripts/friendship/gift_evaluator.gd")
const VECINO_SCRIPT := preload("res://scripts/friendship/vecino_amistad.gd")
const VILLAGER_PROFILE_SCRIPT := preload("res://scripts/npc/villager_profile.gd")
const CONFIG_SCRIPT := preload("res://scripts/friendship/amistad_config.gd")

## Recompensas por nivel de ejemplo (fallback si no existe amistad_config.tres).
const RECOMPENSAS_NIVEL := {
	2: ["receta_herramienta_basica"],
	3: ["decorativo_estatua"],
	5: ["receta_comida_gourmet"],
	8: ["decorativo_fuente"],
}

## Puntos de carta respondida (se aplican al RECIBIR, no al enviar).
const PUNTOS_CARTA := 8
## Puntos por celebrar el cumpleanos de un vecino (participante del evento).
const PUNTOS_CUMPLEANOS := 15
## Bonus extra al regalar en cumpleanos (encima de la clase del regalo).
const BONUS_CUMPLEANOS_REGALO := 5

## Config de niveles/recompensas cargada desde data/amistad/amistad_config.tres
## (override de los fallback de abajo). Ver _cargar_config().
var _config = null
var _umbrales: Array = VECINO_SCRIPT.UMBRALES
var _recompensas: Dictionary = RECOMPENSAS_NIVEL
## Perfiles M19 cacheados por vecino_id para evaluacion de regalos (gustos reales).
var _perfiles: Dictionary = {}

## DOM-AMISTAD: log centralizado de eventos de amistad (regalos, niveles, eventos)
## con rotacion (cap LOG_CAP; se descartan los mas antiguos). Sin UI.
const LOG_CAP := 100
var _eventos: Array = []

signal regalo_entregado(vecino_id: String, item_id: String, clase: int, puntos: int)
signal charla_realizada(vecino_id: String, puntos: int)
signal carta_enviada(vecino_id: String, texto_id: String)
signal carta_recibida(vecino_id: String, respuesta_id: String)
signal nivel_subido(vecino_id: String, nivel: int)
signal evento_celebrado(evento_id: String, participantes: Array)
## Emitido cuando amanece el cumpleanos de un vecino (M29 dia_cambio).
signal cumpleanos_hoy(vecino_id: String, edad: int)

var _vecinos: Dictionary = {}   # vecino_id -> VecinoAmistad
var _dia: int = 0              # dia absoluto (clave de limites diarios)

# Estado de calendario espejo (sincronizado desde M29 en dia_cambio).
var _mes: int = 1
var _dia_mes: int = 1
var _anio: int = 1

# ── Datos estaticos (data-driven, desacoplados de M19) ──
var _cumpleanos: Dictionary = {}   # vecino_id -> {nombre, mes, dia, edad_base}
var _cartas_data: Dictionary = {}  # texto_id -> {cuerpo, respuesta, adjunto_retorno}

# ── Estado de cartas y cumpleanos (persistido) ──
# _cartas: vecino_id -> {pendientes:[...], recibidas:[...]}
var _cartas: Dictionary = {}
# _anio_cumpleanos: vecino_id -> anio en que se celebro por ultima vez
var _anio_cumpleanos: Dictionary = {}
# _cumpleanos_anunciados: vecino_id -> dia_absoluto del ultimo aviso (anti-doble-emision)
var _cumpleanos_anunciados: Dictionary = {}

func _ready() -> void:
	_cargar_cumpleanos()
	_cargar_cartas()
	_cargar_config()
	_sincronizar_con_calendario()
	_sincronizar_con_m19()
	_registrar_como_proveedor_guardado()

## Se registra en SaveManager (M59) como ISaveProvider de la seccion "friendship".
## Duck-typing defensivo: si SaveManager aun no existe, se reintenta al guardar.
func _registrar_como_proveedor_guardado() -> void:
	var sm = get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

## ── Carga de datos ───────────────────────────────────────

func _cargar_json(ruta: String) -> Dictionary:
	if not FileAccess.file_exists(ruta):
		push_warning("[Friendship] No existe %s" % ruta)
		return {}
	var f := FileAccess.open(ruta, FileAccess.READ)
	if f == null:
		return {}
	var texto := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(texto)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[Friendship] JSON invalido: %s" % ruta)
		return {}
	return parsed

func _cargar_cumpleanos() -> void:
	var d := _cargar_json("res://data/amistad/cumpleanos.json")
	_cumpleanos = {}
	for c in d.get("cumpleanos", []):
		var vid := str(c.get("vecino_id", ""))
		if vid == "":
			continue
		_cumpleanos[vid] = {
			"nombre": str(c.get("nombre", "")),
			"mes": int(c.get("mes", 1)),
			"dia": int(c.get("dia", 1)),
			"edad_base": int(c.get("edad_base", 0)),
		}

func _cargar_cartas() -> void:
	var d := _cargar_json("res://data/amistad/cartas.json")
	_cartas_data = {}
	for clave in d.get("cartas", {}):
		_cartas_data[str(clave)] = d["cartas"][clave]

## Carga la config de niveles/recompensas desde amistad_config.tres (data-driven).
## Si el .tres no existe o falla, se conservan los fallback const UMBRALES /
## RECOMPENSAS_NIVEL (el juego sigue funcionando).
func _cargar_config() -> void:
	var cfg = load("res://data/amistad/amistad_config.tres")
	if cfg != null and cfg is CONFIG_SCRIPT:
		if cfg.umbrales.size() > 0:
			_umbrales = Array(cfg.umbrales)
		if cfg.recompensas_nivel.size() > 0:
			_recompensas = cfg.recompensas_nivel
	else:
		push_warning("[Friendship] amistad_config.tres no disponible; usando UMBRALES por defecto")

## ── Sincronizacion con el calendario (M29) ─────────────

## Devuelve el calendario facada: TimeCalendar (M29) si existe, sino GameClock
## (M30, autoridad del tick). Ambos re-emiten senales equivalentes.
func _calendario() -> Node:
	var tc = get_node_or_null("/root/TimeCalendar")
	if tc != null:
		return tc
	return get_node_or_null("/root/GameTime")

func _sincronizar_con_calendario() -> void:
	var cal = _calendario()
	if cal == null:
		return
	_actualizar_desde_calendario(cal)
	if cal.has_signal("dia_cambio"):
		if not cal.dia_cambio.is_connected(_on_dia_calendario):
			cal.dia_cambio.connect(_on_dia_calendario)

## ── Sincronizacion con M19 (NPC y Vecinos) ──────────
## M20 CONSUME M19: los cumpleanos se leen de VillagerProfile (fuente de verdad) y
## se fusionan sobre el seed data/amistad/cumpleanos.json. Sin acoplar M19 -> M20:
## M20 tira de los perfiles activos; M19 no necesita saber que existe M20.

func _sincronizar_con_m19() -> void:
	var vm = get_node_or_null("/root/VillagerManager")
	if vm != null and vm.has_signal("poblacion_cambio"):
		if not vm.poblacion_cambio.is_connected(_on_poblacion_m19):
			vm.poblacion_cambio.connect(_on_poblacion_m19)
	sincronizar_cumpleanos_desde_m19()

func _on_poblacion_m19(_lista: Array) -> void:
	sincronizar_cumpleanos_desde_m19()

## Extrae los datos de cumpleanos de un VillagerProfile (duck-typing: se identifica
## por has_method("evaluar_objeto")). Devuelve {} si el perfil no tiene fecha valida
## (mes/dia = 0) para no pisar el seed JSON con valores vacios.
func _cumpleanos_desde_perfil(perfil) -> Dictionary:
	if perfil == null or not perfil.has_method("evaluar_objeto"):
		return {}
	var mes := int(perfil.cumpleanos_mes)
	var dia := int(perfil.cumpleanos_dia)
	if mes <= 0 or dia <= 0:
		return {}
	return {
		"nombre": str(perfil.nombre),
		"mes": mes,
		"dia": dia,
		"edad_base": int(perfil.edad_base),
	}

## Fusiona un VillagerProfile en el estado de cumpleanos (override del seed por id).
## Cachea SIEMPRE el perfil completo (para evaluacion de regalos con gustos reales),
## aunque no tenga cumpleanos definido. Devuelve true si sincronizo una fecha valida.
func set_cumpleanos_desde_perfil(perfil) -> bool:
	if perfil != null and perfil.has_method("evaluar_objeto"):
		var vidp := str(perfil.id)
		if vidp != "":
			_perfiles[vidp] = perfil
	var c := _cumpleanos_desde_perfil(perfil)
	if c.is_empty():
		return false
	var vid := str(perfil.id)
	if vid == "":
		return false
	_cumpleanos[vid] = c
	return true

## Sincroniza los cumpleanos de todos los villagers activos en VillagerManager.
## Llamado en _ready, en cada dia nuevo (frescura) y al cambiar la poblacion.
func sincronizar_cumpleanos_desde_m19() -> void:
	if not is_inside_tree():
		return
	var vm = get_node_or_null("/root/VillagerManager")
	if vm == null or not vm.has_method("obtener_activos"):
		return
	for v in vm.obtener_activos():
		if is_instance_valid(v) and v.has_method("obtener_perfil"):
			set_cumpleanos_desde_perfil(v.obtener_perfil())

func _actualizar_desde_calendario(cal: Node) -> void:
	if cal.has_method("get_dia_absoluto"):
		_dia = int(cal.get_dia_absoluto())
	if cal.has_method("get_fecha"):
		var f: Dictionary = cal.get_fecha()
		_mes = int(f.get("mes", _mes))
		_dia_mes = int(f.get("dia", _dia_mes))
		_anio = int(f.get("anio", _anio))

func _on_dia_calendario(info: Dictionary) -> void:
	var cal = _calendario()
	if cal != null and cal.has_method("get_dia_absoluto"):
		_dia = int(cal.get_dia_absoluto())
	if info is Dictionary:
		_mes = int(info.get("mes", _mes))
		_dia_mes = int(info.get("dia", _dia_mes))
		_anio = int(info.get("anio", _anio))
	_procesar_nuevo_dia()

## Punto unico de avance de dia: cumpleanos + maduracion de cartas (M29).
func _procesar_nuevo_dia() -> void:
	sincronizar_cumpleanos_desde_m19()   # frescura: refleja villagers que se mudaron hoy
	_verificar_cumpleanos_hoy()
	_madurar_cartas()

## ── Vecinos ─────────────────────────────────────────────

## Registra a un vecino (lo invoca M19 al mudarse). Idempotente.
func registrar_vecino(vecino_id: String) -> void:
	if vecino_id == "" or _vecinos.has(vecino_id):
		return
	var v := VECINO_SCRIPT.new(vecino_id)
	v.umbrales = _umbrales
	_vecinos[vecino_id] = v

## Asegura que un vecino exista (crea si llega una accion sin registro previo).
func _vecino(vecino_id: String) -> VecinoAmistad:
	if not _vecinos.has(vecino_id):
		var v := VECINO_SCRIPT.new(vecino_id)
		v.umbrales = _umbrales
		_vecinos[vecino_id] = v
	return _vecinos[vecino_id]

func vecinos() -> Array:
	return _vecinos.keys()

## ── Pivotes para tests / fallback sin M29 ─────────────

func pivote_dia(dia: int) -> void:
	_dia = dia

func set_dia(dia: int) -> void:
	_dia = dia

## Fija fecha completa (usado por tests y como fallback fuera del arbol).
func pivote_fecha(dia_absoluto: int, mes: int, dia: int, anio: int = 1) -> void:
	_dia = dia_absoluto
	_mes = mes
	_dia_mes = dia
	_anio = anio

## ── Consultas (API J) ─────────────────────────────────
func get_nivel(vecino_id: String) -> int:
	return _vecino(vecino_id).get_nivel()

func get_puntos(vecino_id: String) -> int:
	return _vecino(vecino_id).get_puntos()

func get_progreso(vecino_id: String) -> Dictionary:
	return _vecino(vecino_id).get_progreso()

func get_limite_dia(vecino_id: String, tipo: String) -> Dictionary:
	return _vecino(vecino_id).get_limite_dia(tipo)

func get_memoria(vecino_id: String) -> Array:
	return _vecino(vecino_id).get_memoria()

func get_recuerdos(vecino_id: String) -> Array:
	return _vecino(vecino_id).get_recuerdos()

func get_recompensas_pendientes(vecino_id: String) -> Array:
	return _vecino(vecino_id).get_recompensas_pendientes()

## ── Cumpleanos (M29) ──────────────────────────────────

## Devuelve los datos de cumpleanos de un vecino o {} si no tiene.
func get_cumpleanos(vecino_id: String) -> Dictionary:
	if not _cumpleanos.has(vecino_id):
		return {}
	var c: Dictionary = _cumpleanos[vecino_id]
	return {"nombre": c.get("nombre", ""), "mes": int(c.get("mes", 1)), "dia": int(c.get("dia", 1)), "edad_base": int(c.get("edad_base", 0))}

## ¿Es hoy el cumpleanos de este vecino? (logica pura: mes/dia vs calendario).
func es_cumpleanos_hoy(vecino_id: String) -> bool:
	if not _cumpleanos.has(vecino_id):
		return false
	var c: Dictionary = _cumpleanos[vecino_id]
	return int(c.get("mes", 0)) == _mes and int(c.get("dia", 0)) == _dia_mes

## Cuantos dias faltan para el proximo cumpleanos (wrap al ano siguiente si ya paso).
## Cozy: los cumpleanos no expiran; si se pierde este ano, el proximo es valido.
func proximo_cumpleanos(vecino_id: String) -> Dictionary:
	if not _cumpleanos.has(vecino_id):
		return {}
	var c: Dictionary = _cumpleanos[vecino_id]
	var mes_b: int = int(c.get("mes", 1))
	var dia_b: int = int(c.get("dia", 1))
	# dia del ano (1..336), mes=28 dias, ano=336 dias (M29).
	var da_cumple: int = (mes_b - 1) * 28 + dia_b
	var da_actual: int = (_mes - 1) * 28 + _dia_mes
	var delta: int = da_cumple - da_actual
	if delta <= 0:
		delta += 336
	return {
		"vecino_id": vecino_id,
		"nombre": c.get("nombre", ""),
		"mes": mes_b,
		"dia": dia_b,
		"dias": delta,
		"edad": _edad_cumpleanos(c),
	}

func _edad_cumpleanos(c: Dictionary) -> int:
	return int(c.get("edad_base", 0)) + maxi(0, _anio - 1)

## Al amanecer (M29), avisa los cumpleanos de hoy y el vecino envia una carta
## de cumpleanos al jugador (bandeja). Idempotente por dia.
func _verificar_cumpleanos_hoy() -> void:
	if _cumpleanos.is_empty():
		return
	for vid in _cumpleanos:
		if es_cumpleanos_hoy(vid):
			if int(_cumpleanos_anunciados.get(vid, -1)) == _dia:
				continue
			_cumpleanos_anunciados[vid] = _dia
			var edad: int = _edad_cumpleanos(_cumpleanos[vid])
			cumpleanos_hoy.emit(vid, edad)
			_emitir_npc_cumpleanos(vid, edad)
			_recibir_carta_npc(vid, "CUMPLEANOS")

## Regala en cumpleanos: regalo EXTRA que NO consume el limite diario "regalo"
## (pero si su propio tope de 1/dia). Incluye bonus de cumpleanos.
func regalar_en_cumpleanos(vecino_id: String, item_id: String) -> Dictionary:
	if not es_cumpleanos_hoy(vecino_id):
		return {"ok": false, "motivo": "no_es_cumpleanos"}
	var v := _vecino(vecino_id)
	if not v.intentar_usar_limite("cumpleanos", _dia):
		return {"ok": false, "motivo": "limite_cumpleanos"}
	var inv = get_node_or_null("/root/Inventario")
	var item_meta = _get_item_meta(item_id)
	if inv != null:
		if not bool(inv.remover_items({item_id: 1})):
			return {"ok": false, "motivo": "sin_item"}
	var vecino_data := _get_vecino_data(vecino_id)
	var evaluacion: Dictionary = EVALUADOR_SCRIPT.evaluar(vecino_data, item_meta, v.ha_regalado(item_id))
	var puntos := int(evaluacion["puntos"]) + BONUS_CUMPLEANOS_REGALO
	v.registrar_regalo(item_id)
	if v.get_memoria().size() == 1:
		v.agregar_recuerdo("primer_regalo:%s" % item_id)
	var subio := v.aplicar_puntos(puntos, _recompensas)
	regalo_entregado.emit(vecino_id, item_id, int(evaluacion["clase"]), puntos)
	_emitir_npc_events(vecino_id, item_id, int(evaluacion["clase"]))
	registrar_evento("regalo_cumpleanos", vecino_id, item_id, int(evaluacion["clase"]))
	if subio:
		nivel_subido.emit(vecino_id, v.get_nivel())
		registrar_evento("nivel", vecino_id, str(v.get_nivel()))
		_emitir_level_up(vecino_id, v.get_nivel())
	return {"ok": true, "clase": int(evaluacion["clase"]), "puntos": puntos, "nivel": v.get_nivel(), "cumpleanos": true}

## Celebrar el cumpleanos con el vecino: otorga puntos de evento y registra el
## recuerdo. Una vez por ano (cozy: no penaliza si no se hace; repetible al ano siguiente).
func celebrar_cumpleanos(vecino_id: String) -> Dictionary:
	if not es_cumpleanos_hoy(vecino_id):
		return {"ok": false, "motivo": "no_es_cumpleanos"}
	if int(_anio_cumpleanos.get(vecino_id, 0)) == _anio:
		return {"ok": false, "motivo": "ya_celebrado"}
	_anio_cumpleanos[vecino_id] = _anio
	var v := _vecino(vecino_id)
	v.agregar_recuerdo("cumpleanos_anio_%d" % _anio)
	var subio := v.aplicar_puntos(PUNTOS_CUMPLEANOS, _recompensas)
	evento_celebrado.emit("cumpleanos_%s" % vecino_id, [vecino_id])
	registrar_evento("cumpleanos", vecino_id, "")
	if subio and v.get_nivel() > 1:
		_emitir_level_up(vecino_id, v.get_nivel())
	return {"ok": true, "puntos": PUNTOS_CUMPLEANOS, "nivel": v.get_nivel()}

## ── Cartas (M29: respuesta al dia siguiente) ───────────

## Enviar carta: 1/dia por vecino, adjunto opcional. Los puntos se aplican al
## RECIBIR la respuesta (el dia siguiente de juego, M29), no ahora.
func enviar_carta(vecino_id: String, texto_id: String, adjunto_id: String = "") -> Dictionary:
	var v := _vecino(vecino_id)
	if not v.intentar_usar_limite("carta", _dia):
		return {"ok": false, "motivo": "limite_diario"}
	if adjunto_id != "":
		var inv = get_node_or_null("/root/Inventario")
		if inv != null and not bool(inv.remover_items({adjunto_id: 1})):
			return {"ok": false, "motivo": "sin_adjunto"}
	if not _cartas.has(vecino_id):
		_cartas[vecino_id] = {"pendientes": [], "recibidas": []}
	_cartas[vecino_id]["pendientes"].append({"texto_id": texto_id, "adjunto_id": adjunto_id, "dia_envio": _dia})
	carta_enviada.emit(vecino_id, texto_id)
	return {"ok": true, "texto_id": texto_id, "responde_el": _dia + 1}

## Madura las cartas pendientes: las enviadas en dias anteriores se responden
## hoy, aplicando sus puntos y entregando el adjunto de retorno.
func _madurar_cartas() -> void:
	for vid in _cartas.keys():
		var pend: Array = _cartas[vid].get("pendientes", [])
		var i: int = pend.size() - 1
		while i >= 0:
			var c: Dictionary = pend[i]
			if int(c.get("dia_envio", 0)) < _dia:
				var plantilla: Dictionary = _cartas_data.get(str(c.get("texto_id", "")), {})
				var respuesta_id: String = str(c.get("texto_id", "")) + "_R"
				var v := _vecino(vid)
				var subio := v.aplicar_puntos(PUNTOS_CARTA, _recompensas)
				var adjunto_retorno: String = str(plantilla.get("adjunto_retorno", ""))
				if adjunto_retorno != "":
					var inv = get_node_or_null("/root/Inventario")
					if inv != null and inv.has_method("agregar_items"):
						inv.agregar_items({adjunto_retorno: 1})
				_cartas[vid]["recibidas"].append({
					"respuesta_id": respuesta_id,
					"texto_id": c.get("texto_id"),
					"dia_recibido": _dia,
					"adjunto_retorno": adjunto_retorno,
				})
				pend.remove_at(i)
				carta_recibida.emit(vid, respuesta_id)
				_emitir_npc_carta_recibida(vid, respuesta_id)
				registrar_evento("carta_recibida", vid, respuesta_id)
				if subio:
					registrar_evento("nivel", vid, str(v.get_nivel()))
				if subio and v.get_nivel() > 1:
					_emitir_level_up(vid, v.get_nivel())
			i -= 1

## Carta que el vecino envia al jugador (p.ej. cumpleanos). Entra directo a la
## bandeja de recibidas; no requiere respuesta del jugador.
func _recibir_carta_npc(vecino_id: String, plantilla_id: String) -> void:
	var plantilla: Dictionary = _cartas_data.get(plantilla_id, {})
	var adjunto_retorno: String = str(plantilla.get("adjunto_retorno", ""))
	if not _cartas.has(vecino_id):
		_cartas[vecino_id] = {"pendientes": [], "recibidas": []}
	_cartas[vecino_id]["recibidas"].append({
		"respuesta_id": plantilla_id,
		"texto_id": plantilla_id,
		"dia_recibido": _dia,
		"adjunto_retorno": adjunto_retorno,
		"de_npc": true,
	})
	carta_recibida.emit(vecino_id, plantilla_id)
	_emitir_npc_carta_recibida(vecino_id, plantilla_id)
	registrar_evento("carta_npc", vecino_id, plantilla_id)

## Bandeja de correo recibido (para UI/notificaciones).
func get_bandeja(vecino_id: String) -> Array:
	if not _cartas.has(vecino_id):
		return []
	return _cartas[vecino_id].get("recibidas", []).duplicate()

## Cartas enviadas por el jugador aun sin responder.
func get_cartas_pendientes(vecino_id: String) -> Array:
	if not _cartas.has(vecino_id):
		return []
	return _cartas[vecino_id].get("pendientes", []).duplicate()

## Total de cartas enviadas esperando respuesta (para contador no intrusivo).
func get_cartas_pendientes_total() -> int:
	var t: int = 0
	for vid in _cartas:
		t += _cartas[vid].get("pendientes", []).size()
	return t

## ── Acciones base ──────────────────────────────────────

## Regalar. Devuelve Dictionary con resultado o motivo de rechazo.
func regalar(vecino_id: String, item_id: String) -> Dictionary:
	var v := _vecino(vecino_id)
	if not v.intentar_usar_limite("regalo", _dia):
		return {"ok": false, "motivo": "limite_diario"}
	var inv = get_node_or_null("/root/Inventario")
	var item_meta = _get_item_meta(item_id)
	if inv != null:
		if not bool(inv.remover_items({item_id: 1})):
			return {"ok": false, "motivo": "sin_item"}
	var vecino_data := _get_vecino_data(vecino_id)
	var evaluacion: Dictionary = EVALUADOR_SCRIPT.evaluar(vecino_data, item_meta, v.ha_regalado(item_id))
	var puntos := int(evaluacion["puntos"])
	var clase := int(evaluacion["clase"])
	v.registrar_regalo(item_id)
	if v.get_memoria().size() == 1:
		v.agregar_recuerdo("primer_regalo:%s" % item_id)
	var subio := v.aplicar_puntos(puntos, _recompensas)
	regalo_entregado.emit(vecino_id, item_id, clase, puntos)
	_emitir_npc_events(vecino_id, item_id, clase)
	registrar_evento("regalo", vecino_id, item_id, clase)
	if subio:
		nivel_subido.emit(vecino_id, v.get_nivel())
		registrar_evento("nivel", vecino_id, str(v.get_nivel()))
	_emitir_level_up(vecino_id, v.get_nivel())
	return {"ok": true, "clase": clase, "puntos": puntos, "nivel": v.get_nivel()}

## Charla diaria: 5 + 1 por nivel (max +10).
func charlar(vecino_id: String) -> Dictionary:
	var v := _vecino(vecino_id)
	if not v.intentar_usar_limite("charla", _dia):
		return {"ok": false, "motivo": "limite_diario"}
	var puntos := 5 + mini(v.get_nivel() - 1, 10)
	var subio := v.aplicar_puntos(puntos, _recompensas)
	charla_realizada.emit(vecino_id, puntos)
	if subio:
		registrar_evento("nivel", vecino_id, str(v.get_nivel()))
	if subio and v.get_nivel() > 1:
		_emitir_level_up(vecino_id, v.get_nivel())
	return {"ok": true, "clase": -1, "puntos": puntos, "nivel": v.get_nivel()}

func reclamar_recompensa(vecino_id: String, reward_id: String) -> bool:
	return _vecino(vecino_id).reclamar_recompensa(reward_id)

## ── Internos ──────────────────────────────────────────────
func _emitir_npc_events(vecino_id: String, item_id: String, clase: int) -> void:
	if not is_inside_tree():
		return
	var bus = get_node_or_null("/root/EventBus")
	if bus == null:
		return
	var liked := clase >= EVALUADOR_SCRIPT.Clase.GUSTA
	if bus.npc != null:
		bus.npc.gift_given.emit(vecino_id, item_id, clase)

func _emitir_level_up(vecino_id: String, nuevo_nivel: int) -> void:
	if not is_inside_tree():
		return
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.npc != null:
		bus.npc.friendship_level_up.emit(vecino_id, nuevo_nivel)

func _emitir_npc_cumpleanos(vecino_id: String, edad: int) -> void:
	if not is_inside_tree():
		return
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.npc != null and bus.npc.has_signal("cumpleanos"):
		bus.npc.cumpleanos.emit(vecino_id, edad)

func _emitir_npc_carta_recibida(vecino_id: String, respuesta_id: String) -> void:
	if not is_inside_tree():
		return
	var bus = get_node_or_null("/root/EventBus")
	if bus != null and bus.npc != null and bus.npc.has_signal("carta_recibida"):
		bus.npc.carta_recibida.emit(vecino_id, respuesta_id)

## Devuelve gustos/disgustos de un vecino como Dictionary para GiftEvaluator
## (duck-typing sobre el VillagerProfile cacheado desde M19). Si no hay perfil
## cacheado, devuelve {} => evaluacion neutral (cozy: sin castigo).
func _get_vecino_data(vecino_id: String) -> Dictionary:
	if not _perfiles.has(vecino_id):
		return {}
	var p = _perfiles[vecino_id]
	if p == null or not p.has_method("evaluar_objeto"):
		return {}
	return {
		"gustos": p.gustos,
		"disgustos": p.disgustos,
	}

## ── DOM-AMISTAD: log centralizado de eventos (regalos, niveles, eventos) ──
## Registra un evento con rotacion (cap LOG_CAP). `clase` = GiftEvaluator.Clase
## cuando aplica (regalo), -1 si no. `detalle` suele ser item_id / nivel / respuesta.
func registrar_evento(tipo: String, npc_id: String, detalle: String, clase: int = -1) -> void:
	_eventos.append({"tipo": tipo, "npc_id": npc_id, "detalle": detalle, "dia": _dia, "clase": clase})
	while _eventos.size() > LOG_CAP:
		_eventos.pop_front()

## Log completo (copia) para UI/notificaciones/debug.
func get_eventos() -> Array:
	return _eventos.duplicate()

## Log filtrado por vecino.
func get_eventos_npc(npc_id: String) -> Array:
	var out: Array = []
	for e in _eventos:
		if str(e.get("npc_id", "")) == npc_id:
			out.append(e)
	return out

func _get_item_meta(item_id: String):
	var db = get_node_or_null("/root/ItemDatabase")
	if db == null or not db.has_method("get_item"):
		return null
	return db.get_item(item_id)

## ── Persistencia (ISaveProvider M59) ──────────────────────
func get_section_name() -> String:
	return "friendship"

func get_save_data() -> Dictionary:
	var datos := {}
	for vid in _vecinos:
		datos[vid] = _vecinos[vid].serializar()
	var cartas := {}
	for vid in _cartas:
		cartas[vid] = {
			"pendientes": _cartas[vid].get("pendientes", []).duplicate(),
			"recibidas": _cartas[vid].get("recibidas", []).duplicate(),
		}
	return {
		"vecinos": datos,
		"dia": _dia,
		"mes": _mes,
		"dia_mes": _dia_mes,
		"anio": _anio,
		"cartas": cartas,
		"anio_cumpleanos": _anio_cumpleanos.duplicate(),
		"cumpleanos_anunciados": _cumpleanos_anunciados.duplicate(),
		"eventos": _eventos.duplicate(),
	}

func restore_save_data(data: Dictionary) -> void:
	_vecinos.clear()
	var vdata: Dictionary = data.get("vecinos", {})
	for vid in vdata:
		var v := VECINO_SCRIPT.new(str(vid))
		v.umbrales = _umbrales
		v.deserializar(vdata[vid])
		_vecinos[str(vid)] = v
	_dia = int(data.get("dia", 0))
	_mes = int(data.get("mes", 1))
	_dia_mes = int(data.get("dia_mes", 1))
	_anio = int(data.get("anio", 1))
	_cartas.clear()
	for vid in data.get("cartas", {}):
		var cd: Dictionary = data["cartas"][vid]
		_cartas[str(vid)] = {
			"pendientes": cd.get("pendientes", []).duplicate(),
			"recibidas": cd.get("recibidas", []).duplicate(),
		}
	_anio_cumpleanos.clear()
	for k in data.get("anio_cumpleanos", {}):
		_anio_cumpleanos[str(k)] = int(data["anio_cumpleanos"][k])
	_cumpleanos_anunciados.clear()
	for k in data.get("cumpleanos_anunciados", {}):
		_cumpleanos_anunciados[str(k)] = int(data["cumpleanos_anunciados"][k])
	_eventos.clear()
	for e in data.get("eventos", []):
		_eventos.append(e)
	while _eventos.size() > LOG_CAP:
		_eventos.pop_front()
