# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M68 iter. 2 — Transporte y Navegación: EVENTOS DE RUTA (sección P).
#
# Encuentros suaves que ocurren al viajar (un vecino en el muelle, una escena
# del festival al llegar). Reglas duras:
#   * SIN PELIGRO: ningún evento puede ser hostil ni introducir clima adverso
#     (RF18). Se verifica en `validar()` y en `es_seguro()`.
#   * NUNCA rompen la transición: sólo se disparan en fases seguras
#     (`preparar` antes de los fundidos, `notificar` tras la llegada), jamás
#     durante `fundido_*`, `mover_jugador`, `orientar` o `cargar_destino`.
#   * SIEMPRE con señal (M43 audio / M44 visual) para que el jugador se entere.
#
# Los NPC están anclados a los perfiles REALES de `data/villagers/*.tres`
# (bruno_sapo, catalina_oso, finneas_zorro, luna_zorra, mateo_mapache) y las
# paradas a `transport_network.tres`.
#
# La selección es DETERMINISTA (semilla explícita) para que el test headless no
# dependa del azar: mismo contexto + misma semilla = mismo evento.

class_name TransportRouteEvents
extends RefCounted

const TIPO_NPC := "npc"
const TIPO_FESTIVAL := "festival"
const TIPO_VISUAL := "visual"
const TIPOS: Array[String] = [TIPO_NPC, TIPO_FESTIVAL, TIPO_VISUAL]

const SENAL_AUDIO := "audio"
const SENAL_VISUAL := "visual"
const SENAL_AMBAS := "ambas"
const SENALES: Array[String] = [SENAL_AUDIO, SENAL_VISUAL, SENAL_AMBAS]

## Fases del plan (TransportTripPlanner) en las que es seguro disparar un
## evento: antes de los fundidos o después de la llegada. Las demás fases son
## críticas para la transición y NO admiten eventos.
const FASES_SEGURAS: Array[String] = ["preparar", "notificar"]

## Clima adverso confirmado con M28/M32 (3 = tormenta, 7 = tropical).
## Con clima adverso NO se dispara ningún evento de ruta.
const CLIMAS_ADVERSOS: Array[int] = [3, 7]

var _eventos: Array[Dictionary] = []


func _init(eventos: Array[Dictionary] = []) -> void:
	_eventos = eventos if not eventos.is_empty() else crear_registro_defecto()


## ── Registro por defecto (anclado a NPC y paradas reales) ────────────────

static func crear_registro_defecto() -> Array[Dictionary]:
	return [
		{
			"id": "ev_muelle_mateo",
			"tipo": TIPO_NPC,
			"nombre_clave": "M68.EVENT.MUELLE_MATEO",
			"stop_id": "muelle_raiz_sur",
			"medio": "muelle",
			"npcs": ["mateo_mapache"],
			"fase": "notificar",
			"senal_clave": "M68.EVENT.MUELLE_MATEO.SENAL",
			"senal_tipo": SENAL_VISUAL,
			"peligroso": false,
			"clima_requerido": [],
			"evento_requerido": "",
			"peso": 3,
		},
		{
			"id": "ev_puerto_bruno",
			"tipo": TIPO_NPC,
			"nombre_clave": "M68.EVENT.PUERTO_BRUNO",
			"stop_id": "puerto_aurora",
			"medio": "barco",
			"npcs": ["bruno_sapo"],
			"fase": "preparar",
			"senal_clave": "M68.EVENT.PUERTO_BRUNO.SENAL",
			"senal_tipo": SENAL_AUDIO,
			"peligroso": false,
			"clima_requerido": [],
			"evento_requerido": "",
			"peso": 2,
		},
		{
			"id": "ev_dirigible_luna",
			"tipo": TIPO_NPC,
			"nombre_clave": "M68.EVENT.DIRIGIBLE_LUNA",
			"stop_id": "plataforma_norte",
			"medio": "dirigible",
			"npcs": ["luna_zorra"],
			"fase": "notificar",
			"senal_clave": "M68.EVENT.DIRIGIBLE_LUNA.SENAL",
			"senal_tipo": SENAL_AMBAS,
			"peligroso": false,
			"clima_requerido": [],
			"evento_requerido": "",
			"peso": 2,
		},
		{
			"id": "ev_llegada_finneas",
			"tipo": TIPO_NPC,
			"nombre_clave": "M68.EVENT.LLEGADA_FINNEAS",
			"stop_id": "puerto_aurora",
			"medio": "",
			"npcs": ["finneas_zorro"],
			"fase": "notificar",
			"senal_clave": "M68.EVENT.LLEGADA_FINNEAS.SENAL",
			"senal_tipo": SENAL_VISUAL,
			"peligroso": false,
			"clima_requerido": [],
			"evento_requerido": "",
			"peso": 1,
		},
		{
			"id": "ev_festival_catalina",
			"tipo": TIPO_FESTIVAL,
			"nombre_clave": "M68.EVENT.FESTIVAL_CATALINA",
			"stop_id": "puerto_festival",
			"medio": "",
			"npcs": ["catalina_oso"],
			"fase": "notificar",
			"senal_clave": "M68.EVENT.FESTIVAL_CATALINA.SENAL",
			"senal_tipo": SENAL_AMBAS,
			"peligroso": false,
			"clima_requerido": [],
			"evento_requerido": "festival_otono",
			"peso": 1,
		},
	]


## ── Consulta ─────────────────────────────────────────────────────────────

func eventos() -> Array[Dictionary]:
	return _eventos.duplicate()


func contar() -> int:
	return _eventos.size()


func evento(id: String) -> Dictionary:
	for e in _eventos:
		if str(e.get("id", "")) == id:
			return e
	return {}


func por_tipo(tipo: String) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for e in _eventos:
		if str(e.get("tipo", "")) == tipo:
			out.append(e)
	return out


## ¿El evento es seguro por diseño? (nunca hostil, nunca clima adverso)
func es_seguro(evento: Dictionary) -> bool:
	if evento.is_empty():
		return false
	if bool(evento.get("peligroso", true)):
		return false
	if not FASES_SEGURAS.has(str(evento.get("fase", ""))):
		return false
	for c in _enteros(evento.get("clima_requerido", [])):
		if CLIMAS_ADVERSOS.has(c):
			return false
	return str(evento.get("senal_clave", "")) != ""


## ¿El evento puede romper la transición? Sólo si su fase es crítica.
func rompe_transicion(evento: Dictionary) -> bool:
	return not FASES_SEGURAS.has(str(evento.get("fase", "")))


## ── Selección determinista ───────────────────────────────────────────────

## Elige un evento para `ruta_id` con `contexto`:
##   "clima"            int          → si es adverso, no hay evento
##   "stop_id"          String       → parada de destino (para filtrar)
##   "medio"            String       → medio de la ruta (si no se da, se infiere)
##   "eventos_activos"  Array[String]→ para eventos de festival (M74)
## `semilla` fija el azar: mismo contexto + misma semilla = mismo evento.
func elegir(ruta_id: String, contexto: Dictionary = {}, semilla: int = 0, red: TransportNetwork = null) -> Dictionary:
	var clima: int = int(contexto.get("clima", 0))
	if CLIMAS_ADVERSOS.has(clima):
		return {"ok": false, "motivo": "clima adverso: sin eventos de ruta", "evento": {}}
	var destino: String = str(contexto.get("stop_id", ""))
	var medio: String = str(contexto.get("medio", ""))
	if medio.is_empty() and red != null:
		var r: TransportRoute = red.ruta(StringName(ruta_id))
		if r != null:
			medio = r.medio
			if destino.is_empty():
				destino = String(r.to_id)
	var activos: Array = contexto.get("eventos_activos", []) if contexto.has("eventos_activos") else []
	var candidatos: Array[Dictionary] = []
	for e in _eventos:
		if not es_seguro(e):
			continue
		var e_stop: String = str(e.get("stop_id", ""))
		if not e_stop.is_empty() and not destino.is_empty() and e_stop != destino:
			continue
		var e_medio: String = str(e.get("medio", ""))
		if not e_medio.is_empty() and not medio.is_empty() and e_medio != medio:
			continue
		var req: String = str(e.get("evento_requerido", ""))
		if not req.is_empty() and not activos.has(req):
			continue
		candidatos.append(e)
	if candidatos.is_empty():
		return {"ok": false, "motivo": "sin eventos aplicables", "evento": {}}
	var elegido: Dictionary = _elegir_ponderado(candidatos, semilla)
	return {"ok": true, "motivo": "", "evento": elegido}


## Señal sonora/visual del evento (M43/M44). Siempre presente.
func senal(evento: Dictionary) -> Dictionary:
	return {
		"clave": str(evento.get("senal_clave", "")),
		"tipo": str(evento.get("senal_tipo", SENAL_VISUAL)),
	}


## Fase del plan en la que debe dispararse (debe ser segura).
func fase(evento: Dictionary) -> String:
	return str(evento.get("fase", ""))


static func _elegir_ponderado(candidatos: Array[Dictionary], semilla: int) -> Dictionary:
	var total: int = 0
	for c in candidatos:
		total += maxi(1, int(c.get("peso", 1)))
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	var tiro: int = rng.randi_range(0, maxi(0, total - 1))
	var acumulado: int = 0
	for c in candidatos:
		acumulado += maxi(1, int(c.get("peso", 1)))
		if tiro < acumulado:
			return c
	return candidatos[candidatos.size() - 1]


## ── Validación ───────────────────────────────────────────────────────────

func validar(red: TransportNetwork = null, villager_manager: Object = null) -> Array[String]:
	var errores: Array[String] = []
	var vistos: Array[String] = []
	for e in _eventos:
		var id: String = str(e.get("id", ""))
		if id.is_empty():
			errores.append("evento de ruta sin id")
			continue
		if vistos.has(id):
			errores.append("id de evento duplicado: %s" % id)
		vistos.append(id)
		# Regla dura: sin peligro.
		if bool(e.get("peligroso", true)):
			errores.append("%s: un evento de ruta no puede ser peligroso" % id)
		# Regla dura: no rompe la transición.
		if rompe_transicion(e):
			errores.append("%s: fase '%s' no es segura para un evento" % [id, str(e.get("fase", ""))])
		# Regla dura: señal siempre presente (M43/M44).
		if str(e.get("senal_clave", "")).is_empty():
			errores.append("%s: sin señal (M43/M44)" % id)
		if not SENALES.has(str(e.get("senal_tipo", ""))):
			errores.append("%s: tipo de señal inválido '%s'" % [id, str(e.get("senal_tipo", ""))])
		# Regla dura: nunca clima adverso.
		for c in _enteros(e.get("clima_requerido", [])):
			if CLIMAS_ADVERSOS.has(c):
				errores.append("%s: pide clima adverso (%d) — prohibido en RF18" % [id, c])
		if int(e.get("peso", 0)) <= 0:
			errores.append("%s: peso debe ser > 0" % id)
		if not TIPOS.has(str(e.get("tipo", ""))):
			errores.append("%s: tipo inválido '%s'" % [id, str(e.get("tipo", ""))])
		# Parada real.
		var stop_id: String = str(e.get("stop_id", ""))
		if red != null and not stop_id.is_empty() and red.stop(StringName(stop_id)) == null:
			errores.append("%s: parada inexistente '%s'" % [id, stop_id])
		# NPC real (si M64 está disponible Y su catálogo cargó: si el catálogo
		# está vacío no se puede validar el id, así que no se acusa en falso).
		if villager_manager != null and villager_manager.has_method("obtener_perfil"):
			var tiene_catalogo: bool = true
			if villager_manager.has_method("catalogo_count"):
				tiene_catalogo = int(villager_manager.call("catalogo_count")) > 0
			if tiene_catalogo:
				for npc in _cadenas(e.get("npcs", [])):
					var perfil: Variant = villager_manager.call("obtener_perfil", npc)
					if perfil == null:
						errores.append("%s: NPC inexistente en M64: '%s'" % [id, npc])
	return errores


func claves_localizacion() -> Array[String]:
	var out: Array[String] = []
	for e in _eventos:
		for clave in ["nombre_clave", "senal_clave"]:
			var k: String = str(e.get(clave, ""))
			if not k.is_empty() and not out.has(k):
				out.append(k)
	out.sort()
	return out


func resumen() -> String:
	return "M68 eventos de ruta: %d (%d npc, %d festival, %d visual)" % [
		_eventos.size(),
		por_tipo(TIPO_NPC).size(),
		por_tipo(TIPO_FESTIVAL).size(),
		por_tipo(TIPO_VISUAL).size(),
	]


static func _enteros(valor: Variant) -> Array[int]:
	var out: Array[int] = []
	if valor is Array:
		for x in valor:
			out.append(int(x))
	return out


static func _cadenas(valor: Variant) -> Array[String]:
	var out: Array[String] = []
	if valor is Array:
		for x in valor:
			out.append(str(x))
	return out
