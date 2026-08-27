class_name SaveSchema
extends RefCounted

## Módulo 59: Guardado — Esquema del save
## Define la versión actual del schema, los defaults por sistema y la
## validación de estructura. Es la única fuente de verdad sobre el formato.
##
## Reglas duras del módulo:
##  - schema_version siempre presente y >= 1
##  - Migración solo hacia delante (carga verifica y migra con M60)
##  - Nunca degradar un save

## Versión actual del schema del save
const SCHEMA_VERSION: int = 1

## Prefijo dentro de user:// para los archivos de save
const SAVE_DIR: String = "user://saves"

## Devuelve un payload nuevo con los defaults de TODOS los sistemas.
## Los sistemas aún no implementados quedan con estructuras vacías pero
## presentes, para que el schema sea estable y forward-compatible.
static func default_payload(profile_id: String = "") -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"profile_id": profile_id,
		"world": {
			"seed": 0,
			"islands": [],
			"points_of_interest": [],
			"explored": [],
			"fog": {},
			"modified_blocks": {},
		},
		"player": {
			"name": "",
			"position": [0.0, 0.0, 0.0],
			"spawn_position": [0.0, 0.0, 0.0],
			"zone": "",
		},
		"inventory": {
			"items": [],
			"equipment": [],
			"hotbar": [],
		},
		"buildings": {
			"structures": [],
		},
		"npc": {
			"npcs": [],
			"dialogs_seen": {},
		},
		"quests": {
			"active": [],
			"completed": [],
		},
		"friendship": {
			"relations": {},
		},
		"economy": {
			"coins": 0,
			"shops": {},
		},
		"time": {
			"day": 1,
			"season": 0,
			"hour": 6,
			"minute": 0,
		},
		"events": {
			"completed": [],
			"upcoming": [],
			"cooldowns": {},
		},
		"collections": {
			"museum": {},
			"bestiary": [],
			"diary": [],
		},
		"diary": {
			"entries": [],
		},
		"photos": {
			"ids": [],
		},
		"meta": {
			"last_saved": "",
			"playtime_seconds": 0.0,
		},
	}

## Valida la estructura de un payload cargado.
## Devuelve un Array de Strings con los errores encontrados (vacío = OK).
## NO valida checksum (eso lo hace SaveLoader): aquí solo estructura/tipos/básicos.
static func validate(payload: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	if not payload.has("schema_version"):
		errors.append("Falta schema_version")
	elif typeof(payload["schema_version"]) != TYPE_INT:
		errors.append("schema_version no es int")
	elif int(payload["schema_version"]) < 1:
		errors.append("schema_version inválido: %s" % payload["schema_version"])

	# profile_id debe existir (puede ser vacío en slot nuevo)
	if not payload.has("profile_id"):
		errors.append("Falta profile_id")

	# Los sistemas principales deben existir como Dictionary
	var required_sections := [
		"world", "player", "inventory", "buildings", "npc",
		"quests", "friendship", "economy", "time", "events",
		"collections", "diary", "photos", "meta",
	]
	for section in required_sections:
		if not payload.has(section):
			errors.append("Falta sección: %s" % section)
		elif typeof(payload[section]) != TYPE_DICTIONARY:
			errors.append("Sección %s no es Dictionary" % section)

	# Validaciones mínimas de rangos clave
	if payload.has("time") and typeof(payload["time"]) == TYPE_DICTIONARY:
		var time_dict: Dictionary = payload["time"]
		if time_dict.has("day") and typeof(time_dict["day"]) != TYPE_INT:
			errors.append("time.day no es int")

	return errors
