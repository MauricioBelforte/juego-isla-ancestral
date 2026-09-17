# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M27: Islas del Mundo — IslandTravelGuard (iter. 2).
#
# Resuelve los 9 EDGE CASES del bloque K del checklist (sección K: "Edge cases")
# como reglas puras, sin escena, sin disco y sin autoloads:
#
#   K1  Carga de isla vecina mientras el jugador navega el borde (sin congelar)
#   K2  Viajar a una isla mientras otra se está descargando (cola de operaciones)
#   K3  Jugador en el mar sin barco → salvavidas / límite de zona
#   K4  Isla secreta descubierta por pista pero su ancla aún no generada
#   K5  Desembarco sobre agua si el muelle se generó mal → punto seguro
#   K6  Viaje cancelado a mitad de carga → cancelación limpia
#   K7  Guardado durante una carga → el guardado espera
#   K8  El jugador suelta el barco en el océano abierto → respawn cozy
#   K9  Streaming falla por memoria baja → descarga forzada sin perder estado
#
# La guardia NO carga nada: decide y encola. Quien ejecuta es M63 (streaming) y
# M28 (viaje). Ese corte es lo que la hace verificable headless.
#
# La fuente de datos es una "vista" (Dictionary de registros) que se puede
# construir a mano en un test o desde el autoload `IslandRegistry` real con
# `vista_desde_registry()`.

class_name IslandTravelGuard
extends RefCounted

# ── Parámetros por defecto (sobreescribibles en configurar()) ─────────────
const ID_PRINCIPAL := "aurora"
const NIVEL_MAR := 0.0
## Radio (m) dentro del cual una isla cuenta como "refugio" para un náufrago.
const RADIO_SEGURIDAD_M := 1200.0
## Margen de chunk al cruzar el borde de una isla (M63).
const MARGEN_BORDE_M := 256.0
## Presupuesto de memoria del diseño (NFR: máx 2 islas completas en memoria).
const TOPE_MEMORIA_MB := 2048.0
const COSTE_MB_POR_ISLA := 320.0
const MAX_ISLAS_EN_MEMORIA := 2

var _vista: Dictionary = {}
var _id_principal: String = ID_PRINCIPAL
var _nivel_mar: float = NIVEL_MAR
var _radio_seguridad: float = RADIO_SEGURIDAD_M
var _tope_memoria: float = TOPE_MEMORIA_MB
var _coste_mb: float = COSTE_MB_POR_ISLA
var _margen_borde: float = MARGEN_BORDE_M


# ── Construcción de la vista ──────────────────────────────────────────────

func configurar(vista: Dictionary, opciones: Dictionary = {}) -> void:
	_vista = vista
	_id_principal = str(opciones.get("id_principal", ID_PRINCIPAL))
	_nivel_mar = float(opciones.get("nivel_mar", NIVEL_MAR))
	_radio_seguridad = float(opciones.get("radio_seguridad_m", RADIO_SEGURIDAD_M))
	_tope_memoria = float(opciones.get("tope_memoria_mb", TOPE_MEMORIA_MB))
	_coste_mb = float(opciones.get("coste_mb_por_isla", COSTE_MB_POR_ISLA))
	_margen_borde = float(opciones.get("margen_borde_m", MARGEN_BORDE_M))


## Construye la vista desde el autoload `IslandRegistry` real.
## `reg` se recibe como `Node` y se usa por duck-typing: en modo `--script` un
## autoload no es un identificador global (trampa conocida del proyecto).
##
## El estado de partida (descubierta/visitada) NO vive en la guardia: vive en
## M59 (`IslandRegistry`). Si el registry lo expone, la vista lo refleja desde el
## primer momento; si no, arranca en `false` y se refresca con
## `sincronizar_estado_partida()`.
static func vista_desde_registry(reg: Node) -> Dictionary:
	var out: Dictionary = {}
	if reg == null:
		return out
	var ids: Array = reg.ids()
	for raw in ids:
		var id: StringName = raw
		var d: IslandDefinition = reg.get_isla(id)
		if d == null:
			continue
		var r: Dictionary = registro_desde_definicion(id, d)
		if reg.has_method("esta_descubierta"):
			r["descubierta"] = bool(reg.esta_descubierta(id))
		if reg.has_method("esta_visitada"):
			r["visitada"] = bool(reg.esta_visitada(id))
		out[str(id)] = r
	return out


## Refresca SÓLO el estado de partida (descubierta/visitada) de la vista desde
## el registry real. No toca anclas, radios ni caché (`cargada`/`ultimo_uso`):
## el gestor de mundo lo llama cuando el jugador descubre o visita una isla.
## Devuelve cuántas islas quedaron sincronizadas (0 si el registry no lo expone).
func sincronizar_estado_partida(reg: Node) -> int:
	if reg == null or _vista.is_empty():
		return 0
	if not reg.has_method("esta_descubierta") or not reg.has_method("esta_visitada"):
		return 0
	var n: int = 0
	for id in _vista.keys():
		var sid: StringName = StringName(str(id))
		var r: Dictionary = _vista[id]
		var desc: bool = bool(reg.esta_descubierta(sid))
		var vis: bool = bool(reg.esta_visitada(sid))
		if bool(r.get("descubierta", false)) != desc or bool(r.get("visitada", false)) != vis:
			n += 1
		r["descubierta"] = desc
		r["visitada"] = vis
	return n


## Registro de la vista a partir de una `IslandDefinition` real.
## Nace sin estado de partida: `descubierta`/`visitada` en `false` (ese estado
## lo posee M59, no la definición geométrica).
static func registro_desde_definicion(id: StringName, d: IslandDefinition) -> Dictionary:
	var centro: Vector3 = Vector3(float(d.ancla.x), 0.0, float(d.ancla.z))
	var llegada: Vector3 = d.punto_llegada_mundo()
	var partida: Vector3 = d.punto_partida_mundo()
	var radio: int = d.radio
	return {
		"id": id,
		"ancla": d.ancla,
		"centro": centro,
		"radio": radio,
		"altura_min": d.altura_min,
		"altura_max": d.altura_max,
		"playa_ancho": d.playa_ancho,
		"anillo": d.anillo,
		"es_flotante": d.es_flotante,
		"es_secreta": d.es_secreta,
		"tiene_ancla": d.ancla_asignada,
		"descubierta": false,
		"visitada": false,
		"desbloqueada": true,
		"punto_llegada": llegada,
		"punto_partida": partida,
		"cargada": false,
		"ultimo_uso": 0,
	}


# ── Consultas básicas ─────────────────────────────────────────────────────

func islas() -> Array[String]:
	var out: Array[String] = []
	for k in _vista.keys():
		out.append(str(k))
	out.sort()
	return out


## Copia del registro de una isla (nunca la referencia interna).
func registro(id: String) -> Dictionary:
	var r: Dictionary = _ref(id)
	if r.is_empty():
		return {}
	return r.duplicate(true)


func existe(id: String) -> bool:
	return _vista.has(id)


func contar() -> int:
	return _vista.size()


static func distancia_xz(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))


## Isla cuyo disco (XZ) contiene el punto; si hay varias, la de centro más cercano.
func isla_en(pos: Vector3) -> String:
	var mejor: String = ""
	var mejor_d: float = INF
	for id in islas():
		var r: Dictionary = _ref(id)
		var centro: Vector3 = r["centro"]
		var d: float = distancia_xz(pos, centro)
		if d <= float(r["radio"]) and d < mejor_d:
			mejor_d = d
			mejor = id
	return mejor


func mas_cercana(pos: Vector3) -> Dictionary:
	var mejor: Dictionary = {}
	var mejor_d: float = INF
	for id in islas():
		var r: Dictionary = _ref(id)
		var centro: Vector3 = r["centro"]
		var d: float = distancia_xz(pos, centro)
		if d < mejor_d:
			mejor_d = d
			mejor = {"id": id, "distancia": d, "radio": float(r["radio"])}
	return mejor


## Punto sobre tierra firme: dentro del disco y con `y` entre altura_min/max.
func es_tierra_firme(pos: Vector3) -> bool:
	var id: String = isla_en(pos)
	if id.is_empty():
		return false
	var r: Dictionary = _ref(id)
	return pos.y >= float(r["altura_min"]) and pos.y <= float(r["altura_max"])


## Agua abierta o agua de una isla no flotante. Debajo de una isla flotante hay
## vacío, no océano (diseño: las islas del cielo no tienen mar debajo).
func es_agua(pos: Vector3) -> bool:
	var id: String = isla_en(pos)
	if id.is_empty():
		return true
	var r: Dictionary = _ref(id)
	if bool(r["es_flotante"]):
		return false
	return pos.y < float(r["altura_min"])


func es_playa(pos: Vector3) -> bool:
	var id: String = isla_en(pos)
	if id.is_empty():
		return false
	var r: Dictionary = _ref(id)
	var d: float = distancia_xz(pos, r["centro"])
	var radio: float = float(r["radio"])
	var playa: float = float(r["playa_ancho"])
	return d > radio - playa and d <= radio


# ── K1: precarga sin congelar el frame ────────────────────────────────────

## Islas vecinas que conviene precargar estando el jugador en `pos_jugador`.
## Devuelve como máximo `presupuesto` ids (por defecto 1 op por frame) ordenados
## por cercanía: la cola nunca monopoliza el frame.
func debe_precargar(pos_jugador: Vector3, isla_actual: String, presupuesto: int = -1) -> Array[String]:
	var out: Array[String] = []
	var tope: int = presupuesto if presupuesto >= 0 else IslandOps.MAX_OPS_POR_FRAME
	if tope <= 0:
		return out
	var actual: Dictionary = _ref(isla_actual)
	var radio_actual: float = 0.0
	if not actual.is_empty():
		radio_actual = float(actual["radio"])
	var candidatas: Array[Dictionary] = []
	for id in islas():
		if id == isla_actual:
			continue
		var r: Dictionary = _ref(id)
		if bool(r["cargada"]):
			continue
		var d: float = distancia_xz(pos_jugador, r["centro"])
		var umbral: float = float(r["radio"]) + radio_actual + _margen_borde
		if d <= umbral:
			candidatas.append({"id": id, "distancia": d, "umbral": umbral})
	candidatas.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distancia"]) < float(b["distancia"]))
	for c in candidatas:
		if out.size() >= tope:
			break
		out.append(str(c["id"]))
	return out


func coste_por_frame() -> Dictionary:
	return {
		"ops_por_frame": IslandOps.MAX_OPS_POR_FRAME,
		"etapas_por_operacion": IslandOps.ETAPAS.size(),
		"margen_borde_m": _margen_borde,
		"no_congela": IslandOps.MAX_OPS_POR_FRAME <= 1,
	}


# ── K4: ¿se puede viajar a esta isla? ─────────────────────────────────────

func estado_destino(destino: String) -> Dictionary:
	var r: Dictionary = _ref(destino)
	if r.is_empty():
		return {
			"viajable": false, "motivo": "isla_desconocida",
			"espera_coherente": false, "clave": "M27.VIAJE.DESCONOCIDA",
		}
	if bool(r["es_secreta"]) and not bool(r["descubierta"]):
		return {
			"viajable": false, "motivo": "secreta_no_descubierta",
			"espera_coherente": false, "clave": "M27.VIAJE.SECRETA",
		}
	if not bool(r["tiene_ancla"]):
		return {
			"viajable": false, "motivo": "ancla_pendiente",
			"espera_coherente": true, "clave": "M27.VIAJE.ANCLA_PENDIENTE",
		}
	if not bool(r["desbloqueada"]):
		return {
			"viajable": false, "motivo": "bloqueada_por_progreso",
			"espera_coherente": true, "clave": "M27.VIAJE.BLOQUEADA",
		}
	return {"viajable": true, "motivo": "ok", "espera_coherente": false, "clave": ""}


# ── K2: viajar mientras otra isla se descarga ─────────────────────────────

## Decide si el viaje puede empezar ya, encolarse detrás de una descarga o
## esperar. NUNCA cancela una descarga en curso: hacerlo dejaría chunks a medio
## liberar. Si el DESTINO se está descargando, cargarlo a la vez sería una
## carrera → se encola y espera.
func evaluar_viaje(destino: String, isla_actual: String, ops: IslandOps) -> Dictionary:
	if destino == isla_actual:
		return {
			"permitido": false, "accion": "ninguna", "motivo": "ya_estas_ahi",
			"clave": "M27.VIAJE.YA_ESTAS", "bloquea": [],
		}
	var st: Dictionary = estado_destino(destino)
	if not bool(st["viajable"]):
		return {
			"permitido": false,
			"accion": "esperar" if bool(st["espera_coherente"]) else "ninguna",
			"motivo": str(st["motivo"]), "clave": str(st["clave"]), "bloquea": [],
		}
	if ops == null:
		return {"permitido": true, "accion": "encolar", "motivo": "ok", "clave": "", "bloquea": []}
	var descargando: Array[String] = _ids_de(ops, IslandOps.TIPO_DESCARGA)
	if not descargando.is_empty() and not descargando.has(destino):
		return {
			"permitido": true, "accion": "encolar", "motivo": "descarga_en_curso",
			"clave": "M27.VIAJE.ESPERA_DESCARGA", "bloquea": descargando,
		}
	if descargando.has(destino):
		return {
			"permitido": true, "accion": "encolar", "motivo": "destino_descargandose",
			"clave": "M27.VIAJE.DESTINO_DESCARGANDO", "bloquea": descargando,
		}
	var cargando: Array[String] = _ids_de(ops, IslandOps.TIPO_CARGA)
	if cargando.has(destino):
		return {
			"permitido": true, "accion": "esperar", "motivo": "carga_ya_en_curso",
			"clave": "M27.VIAJE.CARGA_EN_CURSO", "bloquea": [],
			"op": ops.primera_de_tipo(IslandOps.TIPO_CARGA),
		}
	if ops.esta_ocupada():
		return {
			"permitido": true, "accion": "encolar", "motivo": "cola_ocupada",
			"clave": "M27.VIAJE.EN_COLA", "bloquea": [],
			"op": ops.en_curso_id(),
		}
	return {"permitido": true, "accion": "encolar", "motivo": "ok", "clave": "", "bloquea": []}


# ── K3 / K8: náufrago y respawn cozy ──────────────────────────────────────

func evaluar_naufrago(pos: Vector3, en_barco: bool = false) -> Dictionary:
	var cercana: Dictionary = mas_cercana(pos)
	var id: String = str(cercana.get("id", ""))
	var dist: float = float(cercana.get("distancia", -1.0))
	if es_tierra_firme(pos):
		return {
			"riesgo": false, "motivo": "en_tierra", "isla": id,
			"distancia_m": dist, "accion": "ninguna", "limite_m": _radio_seguridad,
		}
	if en_barco:
		return {
			"riesgo": false, "motivo": "a_bordo", "isla": id,
			"distancia_m": dist, "accion": "ninguna", "limite_m": _radio_seguridad,
		}
	if id.is_empty() or dist > _radio_seguridad:
		return {
			"riesgo": true, "motivo": "oceano_abierto", "isla": id,
			"distancia_m": dist, "accion": "respawn_cozy", "limite_m": _radio_seguridad,
		}
	return {
		"riesgo": true, "motivo": "en_agua_cerca_de_isla", "isla": id,
		"distancia_m": dist, "accion": "salvavidas", "limite_m": _radio_seguridad,
	}


## Devuelve SIEMPRE un punto de tierra firme si el archipiélago tiene islas.
func respawn_cozy(pos: Vector3) -> Dictionary:
	var cercana: Dictionary = mas_cercana(pos)
	var id: String = str(cercana.get("id", ""))
	if id.is_empty():
		return {
			"ok": false, "motivo": "sin_islas", "isla": "", "posicion": Vector3.ZERO,
			"distancia_m": 0.0, "ajustado": false,
		}
	var r: Dictionary = _ref(id)
	var muelle: Vector3 = r["punto_llegada"]
	var seguro: Dictionary = punto_seguro(id, muelle)
	var p: Vector3 = seguro["posicion"]
	return {
		"ok": bool(seguro["ok"]), "motivo": "respawn_cozy", "isla": id, "posicion": p,
		"distancia_m": distancia_xz(pos, p), "ajustado": bool(seguro["ajustado"]),
	}


# ── K5: punto seguro de desembarco ────────────────────────────────────────

## Si `pos_deseada` cae sobre agua o fuera del disco, devuelve el punto seco más
## razonable: proyección radial al interior → muelle declarado → centro.
func punto_seguro(destino: String, pos_deseada: Vector3) -> Dictionary:
	var r: Dictionary = _ref(destino)
	if r.is_empty():
		return {
			"ok": false, "motivo": "isla_desconocida", "posicion": pos_deseada,
			"ajustado": false, "fiable": false,
		}
	var radio: float = float(r["radio"])
	var playa: float = float(r["playa_ancho"])
	var interior: float = maxf(1.0, radio - playa)
	var centro: Vector3 = r["centro"]
	var muelle: Vector3 = r["punto_llegada"]
	var y_piso: float = float(r["altura_min"]) + 1.0
	if _es_punto_firme(destino, pos_deseada, interior):
		return {
			"ok": true, "motivo": "ok", "posicion": pos_deseada,
			"ajustado": false, "fiable": true,
		}
	var dir: Vector2 = Vector2(pos_deseada.x - centro.x, pos_deseada.z - centro.z)
	if dir.length() < 0.001:
		dir = Vector2(1.0, 0.0)
	# ⚠️ Proyectar EXACTAMENTE a `interior` deja el punto en el borde del disco y
	# el redondeo flotante lo manda afuera (`188.000003 > 188`): medido con la
	# sonda. Se proyecta 1 m adentro para que quede firme sin discusión.
	var tope: float = maxf(1.0, interior - 1.0)
	dir = dir.normalized() * minf(dir.length(), tope)
	var proyectado: Vector3 = Vector3(centro.x + dir.x, y_piso, centro.z + dir.y)
	if _es_punto_firme(destino, proyectado, interior):
		return {
			"ok": true, "motivo": "proyectado", "posicion": proyectado,
			"ajustado": true, "fiable": true,
		}
	if _es_punto_firme(destino, muelle, interior):
		return {
			"ok": true, "motivo": "muelle", "posicion": muelle,
			"ajustado": true, "fiable": true,
		}
	var centro_seco: Vector3 = Vector3(centro.x, y_piso, centro.z)
	if _es_punto_firme(destino, centro_seco, interior):
		return {
			"ok": true, "motivo": "centro", "posicion": centro_seco,
			"ajustado": true, "fiable": true,
		}
	return {
		"ok": false, "motivo": "sin_tierra_segura", "posicion": muelle,
		"ajustado": true, "fiable": false,
	}


# ── K6: cancelación limpia ────────────────────────────────────────────────

func cancelar_viaje(destino: String, ops: IslandOps) -> Dictionary:
	var canceladas: int = 0
	if ops != null:
		var sid: StringName = _sid(destino)
		if sid != &"":
			canceladas = ops.cancelar_por_isla(sid)
	var restantes: Array[String] = []
	if ops != null:
		for isla in ops.islas_con_ops_vivas():
			restantes.append(str(isla))
	return {
		"canceladas": canceladas,
		"limpio": not restantes.has(destino),
		"ops_vivas": restantes,
	}


# ── K7: guardado durante una carga ────────────────────────────────────────

func evaluar_guardado(ops: IslandOps) -> Dictionary:
	if ops == null:
		return {"puede_guardar": true, "esperar": false, "motivo": "libre", "op": 0, "clave": ""}
	if ops.esta_ocupada():
		return {
			"puede_guardar": false, "esperar": true, "motivo": "carga_en_curso",
			"op": ops.en_curso_id(), "pendientes": 0, "clave": "M27.GUARDADO.ESPERA_CARGA",
		}
	var pend: Array[Dictionary] = ops.pendientes()
	if not pend.is_empty():
		return {
			"puede_guardar": false, "esperar": true, "motivo": "cola_pendiente",
			"op": int(pend[0]["id"]), "pendientes": pend.size(),
			"clave": "M27.GUARDADO.ESPERA_COLA",
		}
	return {"puede_guardar": true, "esperar": false, "motivo": "libre", "op": 0, "pendientes": 0, "clave": ""}


# ── K9: descarga forzada por presión de memoria ───────────────────────────

## Descarga islas cacheadas (LRU) hasta bajar del tope. NUNCA descarga la isla
## principal ni la isla actual. Sólo cambia `cargada`; el estado de partida
## (descubierta/visitada) vive en M59 y se verifica que quede intacto.
func descarga_forzada(memoria_mb: float, ops: IslandOps, isla_actual: String, tope_mb: float = -1.0) -> Dictionary:
	var tope: float = tope_mb if tope_mb >= 0.0 else _tope_memoria
	var intocables: Array[String] = [_id_principal, isla_actual]
	var candidatas: Array[Dictionary] = []
	for id in islas():
		if intocables.has(id):
			continue
		var r: Dictionary = _ref(id)
		if not bool(r["cargada"]):
			continue
		candidatas.append({"id": id, "uso": int(r["ultimo_uso"])})
	candidatas.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["uso"]) != int(b["uso"]):
			return int(a["uso"]) < int(b["uso"])
		return str(a["id"]) < str(b["id"]))
	var previo: Dictionary = {}
	for c in candidatas:
		var id: String = str(c["id"])
		var r: Dictionary = _ref(id)
		previo[id] = [bool(r["descubierta"]), bool(r["visitada"])]
	var descargadas: Array[String] = []
	var memoria: float = memoria_mb
	for c in candidatas:
		if memoria <= tope:
			break
		var id: String = str(c["id"])
		if ops != null:
			var sid: StringName = _sid(id)
			if sid != &"":
				ops.encolar(IslandOps.TIPO_DESCARGA, sid, IslandOps.PRIORIDAD_DESCARGA)
		var r: Dictionary = _ref(id)
		r["cargada"] = false
		memoria -= _coste_mb
		descargadas.append(id)
	var preservado: bool = true
	for id in descargadas:
		var r: Dictionary = _ref(id)
		var p: Array = previo[id]
		if bool(r["descubierta"]) != bool(p[0]) or bool(r["visitada"]) != bool(p[1]):
			preservado = false
	return {
		"descargadas": descargadas,
		"memoria_resultante_mb": maxf(0.0, memoria),
		"tope_mb": tope,
		"intocables": intocables,
		"estado_preservado": preservado,
		"motivo": "presion_de_memoria" if not descargadas.is_empty() else "sin_presion",
	}


# ── Estado de partida (para verificar K9 desde fuera) ─────────────────────

## Snapshot de descubrimiento/visita. El test lo compara antes y después de una
## descarga forzada: es la prueba de que la descarga NO pierde progreso.
func snapshot_estado() -> Dictionary:
	var out: Dictionary = {}
	for id in islas():
		var r: Dictionary = _ref(id)
		out[id] = {"descubierta": bool(r["descubierta"]), "visitada": bool(r["visitada"])}
	return out


func islas_cargadas() -> Array[String]:
	var out: Array[String] = []
	for id in islas():
		var r: Dictionary = _ref(id)
		if bool(r["cargada"]):
			out.append(id)
	return out


# ── Validación / informe ──────────────────────────────────────────────────

const CLAVES_REGISTRO: Array[String] = [
	"id", "ancla", "centro", "radio", "altura_min", "altura_max", "playa_ancho",
	"anillo", "es_flotante", "es_secreta", "tiene_ancla", "descubierta",
	"visitada", "desbloqueada", "punto_llegada", "punto_partida", "cargada",
	"ultimo_uso",
]

func validar() -> Array[String]:
	var err: Array[String] = []
	if _vista.is_empty():
		err.append("la vista está vacía: no hay islas configuradas")
		return err
	if not _vista.has(_id_principal):
		err.append("falta la isla principal: %s" % _id_principal)
	for id in islas():
		var r: Dictionary = _ref(id)
		for k in CLAVES_REGISTRO:
			if not r.has(k):
				err.append("%s: falta la clave '%s'" % [id, k])
		if err.size() > 40:
			break
		var radio: float = float(r.get("radio", 0.0))
		var amin: float = float(r.get("altura_min", 0.0))
		var amax: float = float(r.get("altura_max", 0.0))
		var playa: float = float(r.get("playa_ancho", 0.0))
		if radio <= 0.0:
			err.append("%s: radio <= 0" % id)
		if amax <= amin:
			err.append("%s: altura_max <= altura_min" % id)
		if playa * 2.0 >= radio:
			err.append("%s: playa_ancho*2 >= radio" % id)
		var centro: Vector3 = r.get("centro", Vector3.ZERO)
		for puerto in ["punto_llegada", "punto_partida"]:
			var p: Vector3 = r.get(puerto, Vector3.ZERO)
			if distancia_xz(p, centro) > radio:
				err.append("%s: %s cae fuera del disco (radio %d)" % [id, puerto, int(radio)])
	return err


func es_valida() -> bool:
	return validar().is_empty()


func informe() -> Dictionary:
	return {
		"islas": contar(),
		"id_principal": _id_principal,
		"cargadas": islas_cargadas(),
		"tope_memoria_mb": _tope_memoria,
		"coste_mb_por_isla": _coste_mb,
		"max_islas_en_memoria": MAX_ISLAS_EN_MEMORIA,
		"radio_seguridad_m": _radio_seguridad,
		"margen_borde_m": _margen_borde,
		"coste_por_frame": coste_por_frame(),
	}


func resumen() -> String:
	return "IslandTravelGuard(islas=%d, principal=%s, cargadas=%d)" % [
		contar(), _id_principal, islas_cargadas().size()
	]


# ── Interno ───────────────────────────────────────────────────────────────

func _ref(id: String) -> Dictionary:
	if not _vista.has(id):
		return {}
	var r: Variant = _vista[id]
	if typeof(r) != TYPE_DICTIONARY:
		return {}
	return r as Dictionary


func _sid(id: String) -> StringName:
	var r: Dictionary = _ref(id)
	if r.is_empty():
		return &""
	var sid: StringName = r["id"]
	return sid


func _es_punto_firme(destino: String, pos: Vector3, interior: float) -> bool:
	var r: Dictionary = _ref(destino)
	if r.is_empty():
		return false
	var centro: Vector3 = r["centro"]
	if distancia_xz(pos, centro) > interior:
		return false
	return pos.y >= float(r["altura_min"]) and pos.y <= float(r["altura_max"])


func _ids_de(ops: IslandOps, tipo: StringName) -> Array[String]:
	var out: Array[String] = []
	if ops == null:
		return out
	for isla in ops.islas_con_tipo(tipo):
		out.append(str(isla))
	return out
