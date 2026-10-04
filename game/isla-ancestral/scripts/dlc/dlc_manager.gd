# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M120: DLC y Expansiones — DlcManager (autoload)
# Roadmap y gestión de DLC data-driven (dlc_manifest.json): estados,
# compatibilidad con la versión base, bundles, sin bloquear contenido.
# Adaptación Godot 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).
#
# T-D5 (DeepSeek-V4.1-Flash, 2026-10-04, Log 1291): parte tecnica —
# (a) versionado: `es_compatible` comparaba versiones como STRINGS
#     ("1.10.0" >= "1.9.0" daba false) -> ahora `comparar_versiones` (semantica);
# (b) compatibilidad de saves: DlcManager es ISaveProvider (seccion "dlc") —
#     persiste los DLCs activos + la version base y reconcilia al cargar los
#     DLCs que el save referencia pero ya no estan instalados (`dlcs_faltantes`).

extends Node

const RUTA_MANIFEST := "res://data/dlc/dlc_manifest.json"
const RUTA_BUNDLES := "res://data/dlc/bundles.json"

var config: Dictionary = {}
var bundles: Dictionary = {}
var _activos: Array = []
## DLCs que el save referencia pero NO estan instalados (reconciliacion al cargar).
var _faltantes: Array = []
## Version del juego base al momento de guardar (para detectar downgrade).
var _version_guardada: String = ""

func _ready() -> void:
	_cargar_manifest()
	_cargar_bundles()
	_registrar_servicio()
	_registrar_proveedor_guardado()
	print("[M120] DlcManager listo (%d DLC, %d bundles)" % [config.get("dlcs", []).size(), bundles.size()])

func _cargar_manifest() -> void:
	if not FileAccess.file_exists(RUTA_MANIFEST):
		push_warning("[M120] dlc_manifest.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_MANIFEST))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _cargar_bundles() -> void:
	if not FileAccess.file_exists(RUTA_BUNDLES):
		push_warning("[M120] bundles.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_BUNDLES))
	if typeof(parsed) == TYPE_DICTIONARY:
		for b in parsed.get("bundles", []):
			if typeof(b) == TYPE_DICTIONARY:
				bundles[String(b.get("id", ""))] = b

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("dlc"):
		sr.register("dlc", self)

## Se registra en SaveManager (M59) como proveedor ISaveProvider (seccion "dlc").
## Duck-typing defensivo: si SaveManager aun no existe, no aborta.
func _registrar_proveedor_guardado() -> void:
	var sm := get_node_or_null("/root/SaveManager")
	if sm != null and sm.has_method("register_provider"):
		sm.register_provider(self)

func dlc(id: String) -> Dictionary:
	for d in config.get("dlcs", []):
		if String(d.get("id", "")) == id:
			return d
	return {}

## ¿Es compatible con la versión base instalada?
## La comparacion es SEMANTICA (comparar_versiones), NO lexicografica: con
## comparacion de strings "1.10.0" >= "1.9.0" daba FALSE (bug de versionado).
func es_compatible(id: String, version_base: String) -> bool:
	var d := dlc(id)
	if d.is_empty():
		return false
	var requerida: String = String(d.get("version_requerida", ""))
	if requerida.is_empty():
		return true
	return comparar_versiones(version_base, requerida) >= 0

## Compara dos versiones "a.b.c" SEMANTICAMENTE. Devuelve -1, 0 o 1.
## Tolera segmentos faltantes ("1.2" == "1.2.0") y sufijos ("1.0.0-beta" -> 1.0.0).
static func comparar_versiones(a: String, b: String) -> int:
	var pa := _parsear_version(a)
	var pb := _parsear_version(b)
	var n: int = maxi(pa.size(), pb.size())
	for i in range(n):
		var xa: int = pa[i] if i < pa.size() else 0
		var xb: int = pb[i] if i < pb.size() else 0
		if xa != xb:
			return 1 if xa > xb else -1
	return 0

static func _parsear_version(v: String) -> Array[int]:
	var out: Array[int] = []
	for parte in v.strip_edges().split("."):
		var limpio := ""
		for ch in parte.strip_edges():
			if ch.is_valid_int():
				limpio += ch
			else:
				break
		out.append(int(limpio) if limpio != "" else 0)
	return out

## Version del juego base en runtime (project.godot: application/config/version).
static func version_base_actual() -> String:
	return String(ProjectSettings.get_setting("application/config/version", "0.0.0"))

func activar(id: String) -> bool:
	var d := dlc(id)
	if d.is_empty():
		return false
	if id not in _activos:
		_activos.append(id)
	return true

func desactivar(id: String) -> void:
	_activos.erase(id)

func esta_activo(id: String) -> bool:
	return id in _activos

func bundle(id: String) -> Dictionary:
	return bundles.get(id, {})

## Bundles que contienen un DLC.
func bundles_que_contienen(dlc_id: String) -> Array:
	var resultado: Array = []
	for bid in bundles:
		if dlc_id in bundles[bid].get("dlcs", []):
			resultado.append(bid)
	return resultado

func dlcs_ids() -> Array:
	var ids: Array = []
	for d in config.get("dlcs", []):
		ids.append(d.get("id", ""))
	return ids

## ── ISaveProvider (M59) — seccion "dlc" (T-D5) ──────────────────
## Persiste QUE DLCs estan activos + la version base al guardar, para que
## cargar un save con DLCs que ya no estan instalados no corrompa nada: los
## ausentes quedan en `_faltantes` (consultables) en vez de perderse.

func get_section_name() -> String:
	return "dlc"

func get_save_data() -> Dictionary:
	return {
		"activos": _activos.duplicate(),
		"version_base": version_base_actual(),
	}

func restore_save_data(data: Dictionary) -> void:
	_activos.clear()
	_faltantes.clear()
	_version_guardada = String(data.get("version_base", ""))
	for id in data.get("activos", []):
		var sid := String(id)
		if sid.is_empty():
			continue
		if dlc(sid).is_empty():
			# El save referencia un DLC que NO esta instalado: se registra como
			# faltante en vez de activarlo a ciegas.
			if sid not in _faltantes:
				_faltantes.append(sid)
		elif sid not in _activos:
			_activos.append(sid)

## DLCs que el ultimo save cargado referencia pero no estan instalados.
func dlcs_faltantes() -> Array:
	return _faltantes.duplicate()

## Version del juego base registrada en el ultimo save cargado ("" si no hay).
func version_guardada() -> String:
	return _version_guardada

## ¿El save cargado fue hecho con una version base MAS NUEVA que la actual?
## (downgrade = riesgo de compatibilidad; el llamador decide como avisar).
func save_de_version_superior() -> bool:
	if _version_guardada.is_empty():
		return false
	return comparar_versiones(_version_guardada, version_base_actual()) > 0