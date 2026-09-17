# Modelo: DeepSeek-V4.1-Flash
# Plataforma: WorkBuddy
# Fecha: 2026-09-15
#
# M124: Contenido Generado por Usuarios — UgcTelemetry
# Telemetría de UGC (publicar / ver / descargar / reportar) SIN datos personales:
#   - del alias del autor solo se guarda un hash FNV-1a de 32 bits (irreversible);
#   - el payload `extra` se rechaza si trae cualquier clave de la lista PII;
#   - export/import JSON con versión y gancho de export a M104.
#
# ⚠️ El reloj es inyectable (avanzar(delta)) para que el test sea determinista.

class_name UgcTelemetry
extends RefCounted

const VERSION := 1
const EVENTOS := ["publicar", "ver", "descargar", "reportar"]

# Claves que NUNCA se aceptan en `extra` ni en el registro (PII / plataforma).
const CLAVES_PII := [
	"alias", "nombre", "email", "ip", "ip_address", "device_id", "uuid",
	"steam_id", "platform_id", "cuenta", "save_id", "coords", "coordenadas",
	"posicion", "player_pos", "telefono", "discord",
]

var _eventos: Array = []
var _contadores: Dictionary = {}
var _reloj: float = 0.0

# ---------------------------------------------------------------- reloj
func avanzar(delta_s: float) -> void:
	_reloj += maxf(0.0, delta_s)

func tiempo() -> float:
	return _reloj

# ---------------------------------------------------------------- hash
# FNV-1a 32 bits (mismo algoritmo que VfxPool.semilla_de de M52): determinista,
# estable entre corridas y sin posibilidad de recuperar el alias original.
static func hash_alias(alias: String) -> String:
	var h: int = 0x811C9DC5
	for i in alias.length():
		h = (h ^ alias.unicode_at(i)) & 0xFFFFFFFF
		h = (h * 0x01000193) & 0xFFFFFFFF
	return "%08x" % h

# ---------------------------------------------------------------- PII
static func claves_pii(datos: Dictionary) -> Array:
	var encontradas: Array = []
	for k in datos.keys():
		var clave := str(k).strip_edges().to_lower()
		if CLAVES_PII.has(clave):
			encontradas.append(clave)
			continue
		var valor: Variant = datos[k]
		if typeof(valor) == TYPE_DICTIONARY:
			for sub in claves_pii(valor as Dictionary):
				encontradas.append("%s.%s" % [clave, str(sub)])
	encontradas.sort()
	return encontradas

static func tiene_pii(datos: Dictionary) -> bool:
	return not claves_pii(datos).is_empty()

# ---------------------------------------------------------------- registro
func registrar(evento: String, item_id: String, alias: String = "", extra: Dictionary = {}) -> bool:
	if not EVENTOS.has(evento):
		return false
	if not claves_pii(extra).is_empty():
		return false
	_eventos.append({
		"evento": evento,
		"item_id": item_id,
		"autor": hash_alias(alias) if not alias.is_empty() else "",
		"extra": extra.duplicate(true),
		"t": _reloj,
	})
	_contadores[evento] = int(_contadores.get(evento, 0)) + 1
	return true

func eventos() -> Array:
	return _eventos.duplicate(true)

func contadores() -> Dictionary:
	return _contadores.duplicate()

func cantidad(evento: String) -> int:
	return int(_contadores.get(evento, 0))

func items_unicos() -> int:
	var s := {}
	for e in _eventos:
		s[str((e as Dictionary).get("item_id", ""))] = true
	return s.size()

func autores_unicos() -> int:
	var s := {}
	for e in _eventos:
		var a := str((e as Dictionary).get("autor", ""))
		if not a.is_empty():
			s[a] = true
	return s.size()

func resumen() -> Dictionary:
	return {
		"version": VERSION,
		"total": _eventos.size(),
		"por_evento": _contadores.duplicate(),
		"items_unicos": items_unicos(),
		"autores_unicos": autores_unicos(),
	}

# ---------------------------------------------------------------- persistencia
func exportar_json() -> String:
	return JSON.stringify({
		"version": VERSION,
		"eventos": _eventos,
		"contadores": _contadores,
		"tiempo": _reloj,
	})

func cargar_json(txt: String) -> bool:
	var parsed: Variant = JSON.parse_string(txt)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var d: Dictionary = parsed as Dictionary
	if int(d.get("version", 0)) != VERSION:
		return false
	var ev: Variant = d.get("eventos", [])
	if typeof(ev) != TYPE_ARRAY:
		return false
	_eventos = (ev as Array).duplicate(true)
	_contadores = {}
	for e in _eventos:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var nombre := str((e as Dictionary).get("evento", ""))
		if nombre.is_empty():
			continue
		_contadores[nombre] = int(_contadores.get(nombre, 0)) + 1
	_reloj = float(d.get("tiempo", 0.0))
	return true

# Gancho a M104: mismo shape de evento que el resto de la telemetría de gameplay.
func exportar_a_m104() -> Array:
	var out: Array = []
	for e in _eventos:
		var d: Dictionary = e as Dictionary
		out.append({
			"categoria": "ugc",
			"evento": d.get("evento", ""),
			"item": d.get("item_id", ""),
			"autor_hash": d.get("autor", ""),
			"t": d.get("t", 0.0),
		})
	return out

func reiniciar() -> void:
	_eventos.clear()
	_contadores.clear()
	_reloj = 0.0

func descripcion() -> String:
	return "[M124] UgcTelemetry: %d eventos (%s) · %d ítems · %d autores" % [
		_eventos.size(), str(_contadores), items_unicos(), autores_unicos()]
