# Modelo: deepseek-v4-flash
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M123: Modding — ModdingManager (autoload)
# Carga de mods data-driven (mod_manifest.json): manifiesto, compatibilidad
# con la build, conflictos por override, activación. Adaptación Godot
# 4.7/GDScript del diseño (04-Codigo.md §2).
# ⚠️ Sin class_name: es autoload (pitfall §9.17/§9.41).

extends Node

const RUTA_MANIFEST := "res://data/mods/mod_manifest.json"

var config: Dictionary = {}
var _activos: Array = []

func _ready() -> void:
	_cargar_manifest()
	_registrar_servicio()
	print("[M123] ModdingManager listo (%d mods)" % config.get("mods", []).size())

func _cargar_manifest() -> void:
	if not FileAccess.file_exists(RUTA_MANIFEST):
		push_warning("[M123] mod_manifest.json no encontrado")
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_MANIFEST))
	if typeof(parsed) == TYPE_DICTIONARY:
		config = parsed

func _registrar_servicio() -> void:
	var sr := get_node_or_null("/root/ServiceRegistry")
	if sr == null:
		return
	if not sr.has("modding"):
		sr.register("modding", self)

func mod(id: String) -> Dictionary:
	for m in config.get("mods", []):
		if String(m.get("id", "")) == id:
			return m
	return {}

## ¿El mod es compatible con la build instalada?
func es_compatible(id: String, build: String) -> bool:
	var m := mod(id)
	if m.is_empty():
		return false
	var min_build: String = String(m.get("min_build", ""))
	if min_build.is_empty():
		return true
	return build >= min_build

## Detecta conflictos por override (mod A lista override a mod B).
func detectar_conflictos() -> Array:
	var conflictos: Array = []
	for m in config.get("mods", []):
		for over in m.get("override", []):
			conflictos.append({
				"mod": String(m.get("id", "")),
				"override": String(over),
			})
	return conflictos

func activar(id: String) -> bool:
	if mod(id).is_empty():
		return false
	if id not in _activos:
		_activos.append(id)
	return true

func esta_activo(id: String) -> bool:
	return id in _activos

func carpeta_mods() -> String:
	return String(config.get("carpeta_mods", "user://mods"))

func mods_ids() -> Array:
	var ids: Array = []
	for m in config.get("mods", []):
		ids.append(m.get("id", ""))
	return ids

## §6 "comportamiento: menor prioridad se omite + warning".
## Agrupa por objetivo de override: gana el de mayor `prioridad` (empate → orden
## de declaración); los demás se OMITEN y se devuelven como advertencia.
## `cfg` permite inyectar una config (tests); vacío = la real.
## Devuelve {activos: Array[String], omitidos: Array[{id, motivo}]}.
func resolver_prioridad(cfg: Dictionary = {}) -> Dictionary:
	var fuente: Dictionary = cfg if not cfg.is_empty() else config
	var grupos: Dictionary = {}
	var activos: Array = []
	for m in fuente.get("mods", []):
		var overs: Array = m.get("override", [])
		if overs.is_empty():
			activos.append(String(m.get("id", "")))
			continue
		for o in overs:
			var k := String(o)
			if not grupos.has(k):
				grupos[k] = []
			grupos[k].append(m)
	var omitidos: Array = []
	for objetivo in grupos.keys():
		var lista: Array = grupos[objetivo]
		lista.sort_custom(func(a, b): return int(a.get("prioridad", 0)) > int(b.get("prioridad", 0)))
		activos.append(String(lista[0].get("id", "")))
		for i in range(1, lista.size()):
			omitidos.append({
				"id": String(lista[i].get("id", "")),
				"motivo": "menor prioridad que %s sobre '%s'" % [String(lista[0].get("id", "")), objetivo],
			})
	return {"activos": activos, "omitidos": omitidos}

## §7 "regla de compatibilidad con updates (M118)": tras un update a `build_nuevo`
## el mod sigue compatible si y sólo si `build_nuevo >= min_build`. Un downgrade
## por debajo del min_build lo bloquea.
func es_compatible_update(id: String, build_nuevo: String) -> bool:
	var m := mod(id)
	if m.is_empty():
		return false
	var min_build: String = String(m.get("min_build", ""))
	if min_build.is_empty():
		return true
	return build_nuevo >= min_build