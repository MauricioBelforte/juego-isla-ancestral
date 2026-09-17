# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Transporte y Navegación: VIAJES ESPECIALES (sección N).
#
# Registro data-driven de viajes especiales: los 5 festivales REALES de M74
# (festival_primavera / _verano / _otono / _invierno / _luces) y dos tours
# (luna llena M31 y panorámico en dirigible).
#
# La red (`transport_network.tres`) sigue siendo la ÚNICA fuente de verdad de
# paradas y rutas; este registro SOLO las etiqueta con una ventana de
# disponibilidad (calendario M29 o evento M74). No crea paradas ni rutas.
#
# Regla dura de la sección N — "No aparecer en el grafo normal (solo programados)":
# las rutas marcadas con `ocultar_en_grafo_normal` NO deben listarse en
# `TransportManager.list_routes()` salvo que su viaje especial esté disponible.
# Eso es lo que hace que el Puerto del Festival (parada temporal, M74) no
# aparezca en el panel de transporte el resto del año.
#
# Puro y sin escena: TODO entra por parámetro (`fecha`, `contexto`), así que es
# verificable headless y no depende del reloj real, del clima ni de los autoloads.

class_name TransportSpecialTrips
extends RefCounted

const TIPO_FESTIVAL := "festival"
const TIPO_LUNA := "luna"
const TIPO_TOUR := "tour"
const TIPOS: Array[String] = [TIPO_FESTIVAL, TIPO_LUNA, TIPO_TOUR]

## Ciclo lunar derivado del día absoluto de M29 (M31 todavía no existe).
## 28 días, luna llena el día 14 del ciclo.
const CICLO_LUNAR_DIAS := 28
const DIA_LUNA_LLENA := 14

## Recargo del tour de luna llena sobre el boleto normal (precio especial).
const FACTOR_PRECIO_LUNA := 1.5

var _viajes: Array[Dictionary] = []


func _init(viajes: Array[Dictionary] = []) -> void:
	_viajes = viajes if not viajes.is_empty() else crear_registro_defecto()


## ── Registro por defecto (anclado a datos reales) ─────────

## Los 5 festivales vienen de `scripts/eventos/data/festivales/*.tres` (M74) y
## sus fechas son las reales de esos recursos. La ida/vuelta al Puerto del
## Festival (`puerto_festival`, flag `festival_activo`) se oculta del grafo normal.
static func crear_registro_defecto() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	# Festivales (M74): parada temporal, ruta oculta salvo en su ventana.
	var festivales := [
		["festival_primavera", 1, 15, 0, 6, 22],
		["festival_verano", 5, 15, 1, 6, 23],
		["festival_otono", 9, 15, 2, 8, 20],
		["festival_invierno", 11, 15, 3, 8, 22],
		["festival_luces", 12, 28, 3, 20, 23],
	]
	for f in festivales:
		var ev_id: String = str(f[0])
		out.append({
			"id": "esp_" + ev_id,
			"tipo": TIPO_FESTIVAL,
			"nombre_clave": "M68.SPECIAL." + ev_id.to_upper(),
			"descripcion_clave": "M68.SPECIAL." + ev_id.to_upper() + "_DESC",
			"ruta_id": "r_muelle_festival",
			"ruta_vuelta_id": "r_festival_muelle",
			"origen_id": "muelle_raiz_sur",
			"destino_id": "puerto_festival",
			"evento_id": ev_id,
			"calendario": {"mes": int(f[1]), "dia": int(f[2]), "estacion": int(f[3])},
			"hora_inicio": int(f[4]),
			"hora_fin": int(f[5]),
			"precio": 10,
			"precio_base": 10,
			"duracion_seg": 8.0,
			"ocultar_en_grafo_normal": true,
			"requiere_luna_llena": false,
		})
	# Tour de luna llena (M31): reutiliza la ruta secreta al Espejo, con recargo.
	out.append({
		"id": "esp_luna_llena",
		"tipo": TIPO_LUNA,
		"nombre_clave": "M68.SPECIAL.LUNA_LLENA",
		"descripcion_clave": "M68.SPECIAL.LUNA_LLENA_DESC",
		"ruta_id": "r_aurora_espejo",
		"ruta_vuelta_id": "",
		"origen_id": "puerto_aurora",
		"destino_id": "puerto_espejo",
		"evento_id": "",
		"calendario": {},
		"hora_inicio": 20,
		"hora_fin": 23,
		"precio": 330,
		"precio_base": 220,
		"duracion_seg": 110.0,
		"ocultar_en_grafo_normal": false,
		"requiere_luna_llena": true,
	})
	# Tour panorámico en dirigible: sólo fines de semana, precio con recargo.
	out.append({
		"id": "esp_tour_dirigible",
		"tipo": TIPO_TOUR,
		"nombre_clave": "M68.SPECIAL.TOUR_DIRIGIBLE",
		"descripcion_clave": "M68.SPECIAL.TOUR_DIRIGIBLE_DESC",
		"ruta_id": "r_plataforma_norte",
		"ruta_vuelta_id": "r_norte_plataforma",
		"origen_id": "plataforma_norte",
		"destino_id": "puerto_norte",
		"evento_id": "",
		"calendario": {"semana_dia": [5, 6]},
		"hora_inicio": 8,
		"hora_fin": 19,
		"precio": 120,
		"precio_base": 100,
		"duracion_seg": 50.0,
		"ocultar_en_grafo_normal": false,
		"requiere_luna_llena": false,
	})
	return out


## ── Consulta del registro ─────────────────────────────────

func viajes() -> Array[Dictionary]:
	return _viajes.duplicate()


func contar() -> int:
	return _viajes.size()


func viaje(id: String) -> Dictionary:
	for v in _viajes:
		if str(v.get("id", "")) == id:
			return v
	return {}


func por_tipo(tipo: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for v in _viajes:
		if str(v.get("tipo", "")) == tipo:
			out.append(v)
	return out


## Rutas que este registro manda ocultar del grafo normal. Incluye las vueltas.
func rutas_ocultas() -> Array[String]:
	var out: Array[String] = []
	for v in _viajes:
		if not bool(v.get("ocultar_en_grafo_normal", false)):
			continue
		for clave in ["ruta_id", "ruta_vuelta_id"]:
			var rid: String = str(v.get(clave, ""))
			if not rid.is_empty() and not out.has(rid):
				out.append(rid)
	out.sort()
	return out


## ¿La ruta debe omitirse del grafo normal salvo ventana activa?
func ruta_oculta(ruta_id: String) -> bool:
	return rutas_ocultas().has(ruta_id)


## ¿Algún viaje especial usa esta ruta? (sirve para no duplicar costes)
func viajes_con_ruta(ruta_id: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for v in _viajes:
		if str(v.get("ruta_id", "")) == ruta_id or str(v.get("ruta_vuelta_id", "")) == ruta_id:
			out.append(v)
	return out


## ── Disponibilidad (calendario M29 / evento M74) ──────────

## ¿Está disponible `viaje` en `fecha`? Devuelve {ok, motivo} con el motivo en
## español listo para el panel (M53). `contexto` puede traer:
##   "eventos_activos": Array[String]  → M74 manda (si está presente)
##   "luna_llena": bool                → M31 manda (si está presente)
func disponible_en(viaje: Dictionary, fecha: Dictionary, contexto: Dictionary = {}) -> Dictionary:
	if viaje.is_empty():
		return {"ok": false, "motivo": "viaje especial inexistente"}
	if bool(viaje.get("requiere_luna_llena", false)) and not es_luna_llena(fecha, contexto):
		return {"ok": false, "motivo": "sólo en luna llena"}
	var evento_id: String = str(viaje.get("evento_id", ""))
	var activos: Array = contexto.get("eventos_activos", []) if contexto.has("eventos_activos") else []
	if not evento_id.is_empty() and not activos.is_empty():
		var hay := false
		for e in activos:
			if str(e) == evento_id:
				hay = true
				break
		if not hay:
			return {"ok": false, "motivo": "el evento %s no está activo" % evento_id}
	else:
		var motivo_cal: String = _motivo_calendario(viaje, fecha)
		if not motivo_cal.is_empty():
			return {"ok": false, "motivo": motivo_cal}
	return {"ok": true, "motivo": ""}


## Viajes disponibles ahora mismo (con su precio), para el panel (M53).
func disponibles(fecha: Dictionary, contexto: Dictionary = {}) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for v in _viajes:
		var d: Dictionary = disponible_en(v, fecha, contexto)
		if bool(d.get("ok", false)):
			var copia: Dictionary = v.duplicate(true)
			copia["motivo"] = ""
			out.append(copia)
	return out


## ¿Hay luna llena? M31 manda si expone `contexto.luna_llena`; si no, se deriva
## del día absoluto de M29 (ciclo de 28 días, llena en el día 14 del ciclo).
func es_luna_llena(fecha: Dictionary, contexto: Dictionary = {}) -> bool:
	if contexto.has("luna_llena"):
		return bool(contexto.get("luna_llena", false))
	if not fecha.has("dia_absoluto"):
		return false
	var d: int = int(fecha.get("dia_absoluto", 1))
	return posmod(d, CICLO_LUNAR_DIAS) == DIA_LUNA_LLENA


func _motivo_calendario(viaje: Dictionary, fecha: Dictionary) -> String:
	var cal: Dictionary = viaje.get("calendario", {}) if viaje.get("calendario", null) is Dictionary else {}
	if cal.is_empty():
		return ""
	# Día de la semana (fines de semana para el tour panorámico).
	if cal.has("semana_dia"):
		var dias: Array = cal.get("semana_dia", [])
		var sd: int = int(fecha.get("semana_dia", -1))
		if not dias.has(sd):
			return "sólo los fines de semana"
	# Fecha exacta (festivales M74).
	if cal.has("mes") and cal.has("dia"):
		var mismo := int(fecha.get("mes", -1)) == int(cal.get("mes", -2)) \
			and int(fecha.get("dia", -1)) == int(cal.get("dia", -2))
		if not mismo:
			return "sólo el %d/%d" % [int(cal.get("dia", 0)), int(cal.get("mes", 0))]
	# Estación (M29) si no hay fecha exacta.
	if cal.has("estacion") and not (cal.has("mes") and cal.has("dia")):
		if int(fecha.get("estacion", -1)) != int(cal.get("estacion", -2)):
			return "sólo en su estación"
	# Ventana horaria del evento.
	if fecha.has("hora") and viaje.has("hora_inicio") and viaje.has("hora_fin"):
		var h: int = int(fecha.get("hora", -1))
		var hi: int = int(viaje.get("hora_inicio", 0))
		var hf: int = int(viaje.get("hora_fin", 24))
		if h < hi or h > hf:
			return "sólo de %02d:00 a %02d:00" % [hi, hf]
	return ""


## ── Validación ────────────────────────────────────────────

## Verifica el registro contra la red real. Devuelve la lista de problemas.
func validar(red: TransportNetwork) -> Array[String]:
	var errores: Array[String] = []
	if red == null:
		return ["sin red de transporte"]
	var vistos: Array[String] = []
	for v in _viajes:
		var id: String = str(v.get("id", ""))
		if id.is_empty():
			errores.append("viaje especial sin id")
			continue
		if vistos.has(id):
			errores.append("id de viaje especial duplicado: %s" % id)
		vistos.append(id)
		if not TIPOS.has(str(v.get("tipo", ""))):
			errores.append("%s: tipo inválido '%s'" % [id, str(v.get("tipo", ""))])
		var ruta_id: String = str(v.get("ruta_id", ""))
		var ruta: TransportRoute = red.ruta(StringName(ruta_id))
		if ruta == null:
			errores.append("%s: ruta inexistente '%s'" % [id, ruta_id])
		else:
			if String(ruta.from_id) != str(v.get("origen_id", "")):
				errores.append("%s: origen declarado no coincide con la ruta" % id)
			if String(ruta.to_id) != str(v.get("destino_id", "")):
				errores.append("%s: destino declarado no coincide con la ruta" % id)
			if int(v.get("precio_base", -1)) != ruta.base_cost:
				errores.append("%s: precio_base %d != base_cost %d de la ruta" % [
					id, int(v.get("precio_base", -1)), ruta.base_cost])
		var vuelta: String = str(v.get("ruta_vuelta_id", ""))
		if not vuelta.is_empty() and red.ruta(StringName(vuelta)) == null:
			errores.append("%s: ruta de vuelta inexistente '%s'" % [id, vuelta])
		var precio: int = int(v.get("precio", 0))
		if precio <= 0:
			errores.append("%s: precio debe ser > 0" % id)
		if str(v.get("tipo", "")) != TIPO_FESTIVAL and precio <= int(v.get("precio_base", 0)):
			errores.append("%s: el precio especial debe superar el boleto normal" % id)
		if red.stop(StringName(str(v.get("destino_id", "")))) == null:
			errores.append("%s: parada de destino inexistente" % id)
		# Un viaje oculto sin ventana sería inalcanzable (parada muerta).
		var cal: Dictionary = v.get("calendario", {}) if v.get("calendario", null) is Dictionary else {}
		if bool(v.get("ocultar_en_grafo_normal", false)) and str(v.get("evento_id", "")).is_empty() and cal.is_empty():
			errores.append("%s: oculto del grafo pero sin ventana de disponibilidad" % id)
		if bool(v.get("requiere_luna_llena", false)) and str(v.get("tipo", "")) != TIPO_LUNA:
			errores.append("%s: requiere_luna_llena sólo vale para tipo '%s'" % [id, TIPO_LUNA])
		if cal.has("mes") and (int(cal.get("mes", 0)) < 1 or int(cal.get("mes", 0)) > 12):
			errores.append("%s: mes fuera de rango" % id)
		if cal.has("dia") and (int(cal.get("dia", 0)) < 1 or int(cal.get("dia", 0)) > 31):
			errores.append("%s: día fuera de rango" % id)
	return errores


## Claves de localización (M87) que este registro introduce.
func claves_localizacion() -> Array[String]:
	var out: Array[String] = []
	for v in _viajes:
		for clave in ["nombre_clave", "descripcion_clave"]:
			var k: String = str(v.get(clave, ""))
			if not k.is_empty() and not out.has(k):
				out.append(k)
	out.sort()
	return out


func resumen(fecha: Dictionary = {}, contexto: Dictionary = {}) -> String:
	var abiertos := 0
	if not fecha.is_empty():
		abiertos = disponibles(fecha, contexto).size()
	var ocultas := rutas_ocultas()
	return "M68 especiales: %d viajes (%d festival, %d luna, %d tour), %d disponibles, %d rutas ocultas" % [
		_viajes.size(),
		por_tipo(TIPO_FESTIVAL).size(),
		por_tipo(TIPO_LUNA).size(),
		por_tipo(TIPO_TOUR).size(),
		abiertos,
		ocultas.size(),
	]
