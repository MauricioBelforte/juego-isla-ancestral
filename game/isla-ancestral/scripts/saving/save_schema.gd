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

## Devuelve true si el valor es un entero "semantico": int, o un float con
## valor entero.
##
## JSON NO preserva int vs float: JSON.parse_string() devuelve float para
## CUALQUIER numero (`1` -> `1.0`). Por eso un payload que vuelve del disco
## nunca es TYPE_INT. El schema exige un ENTERO, no el tipo de dato crudo, así
## que aceptamos ambos. Bug real corregido en M59 iter. 1 (DeepSeek-V4.1-Flash):
## validate() rechazaba TODO save leído del disco con "schema_version no es int"
## -> SaveLoader.load() devolvía CORRUPTED (sin backup) o RECOVERED (con backup)
## y el juego no podía cargar la partida.
static func _es_entero(v: Variant) -> bool:
	if typeof(v) == TYPE_INT:
		return true
	if typeof(v) == TYPE_FLOAT:
		var f: float = v
		# 2^53: por encima, los enteros ya no son representables exactos en float.
		return is_finite(f) and f == floorf(f) and absf(f) <= 9007199254740992.0
	return false

## Completa con los defaults del schema toda SECCION de nivel superior que falte
## en un payload cargado. NO sobrescribe nada existente.
##
## M59 iter. 3 (DeepSeek-V4.1-Flash) — item H: "Manejar campos nuevos (defaults)
## y faltantes (sin crash)". Antes, un save al que le faltaba una seccion fallaba
## `validate()` con "Falta sección: X" -> CORRUPTED y no se podia cargar.
##
## DELIBERADAMENTE NO toca el INTERIOR de las secciones: los proveedores reales
## usan su propio dialecto (ver Log 1202) y algunas restauraciones ITERAN las
## claves de su seccion. Inyectar una clave del schema dentro de una seccion con
## proveedor es PELIGROSO: `inventario_service.restore_save_data()` hace
## `for id in data: int(id)` y trata la clave como indice de contenedor, asi que
## una clave como "items" se leeria como el contenedor 0 y BORRARIA su contenido.
## El interior de una seccion es responsabilidad de su proveedor.
static func completar(payload: Dictionary) -> Dictionary:
	var base: Dictionary = default_payload(String(payload.get("profile_id", "")))
	for seccion in base:
		if seccion == "schema_version" or seccion == "profile_id":
			continue
		if not payload.has(seccion):
			payload[seccion] = base[seccion]
	return payload

## Lee el "dia" de un payload de save, tolerando el dialecto del proveedor.
##
## M59 iter. 3: el proveedor de tiempo (M29) NO usa el dialecto del schema.
## Persiste `dia/mes/anio/hora/minuto`, mientras el schema declara
## `day/season/hour/minute`. Como `collect()` REEMPLAZA la seccion entera,
## `time.day` no existe en disco y leerlo devolvia SIEMPRE 0 (la UI de slots
## habria mostrado "dia 0" para cualquier partida). Este helper es la UNICA
## traduccion del dialecto; si algun dia los dueños de M29/M14/M38 reconcilian
## las claves, se cambia solo aca.
static func dia_de(payload: Dictionary) -> int:
	var t: Variant = payload.get("time", {})
	if typeof(t) != TYPE_DICTIONARY:
		return 0
	return int((t as Dictionary).get("dia", (t as Dictionary).get("day", 0)))

## Valida la estructura de un payload cargado.
## Devuelve un Array de Strings con los errores encontrados (vacío = OK).
## NO valida checksum (eso lo hace SaveLoader): aquí solo estructura/tipos/básicos.
static func validate(payload: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	if not payload.has("schema_version"):
		errors.append("Falta schema_version")
	elif not _es_entero(payload["schema_version"]):
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
		if time_dict.has("day") and not _es_entero(time_dict["day"]):
			errors.append("time.day no es int")

	return errors
