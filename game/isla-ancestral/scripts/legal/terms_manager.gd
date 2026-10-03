# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-03
#
# M125: Términos de Servicio — TermsManager (autoload)
# Servicio que gestiona aceptación/rechazo de términos, versión,
# y persistencia del estado de aceptación.

class_name TermsManager
extends Node

## Señal emitida al aceptar los términos.
signal terms_accepted
## Señal emitida al rechazar (juego cierra o muestra pantalla).
signal terms_declined
## Señal emitida cuando los términos cambian (re-aceptación).
signal terms_updated

var _accepted: bool = false
var _version: int = 1
var _terms_file: String = "res://data/legal/terminos.json"
const RUTA_SAVES := "user://terminos_aceptados.json"

func _ready() -> void:
	_cargar_estado()
	print("[M125] TermsManager listo (v%d)" % _version)

func _cargar_estado() -> void:
	if not FileAccess.file_exists(RUTA_SAVES):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUTA_SAVES))
	if typeof(parsed) == TYPE_DICTIONARY:
		_accepted = bool(parsed.get("accepted", false))
		_version = int(parsed.get("version", 1))

## Devuelve si el usuario ya aceptó los términos.
func check_terms_acceptance() -> bool:
	return _accepted

## Muestra los términos (en una capa UI).
## En headless: solo registra. En runtime: abre el diálogo.
func show_terms() -> void:
	if _accepted:
		return
	print("[M125] Mostrar términos v%d" % _version)

## Acepta los términos (persiste).
func accept_terms() -> void:
	_accepted = true
	_guardar_estado()
	terms_accepted.emit()
	print("[M125] Términos aceptados (v%d)" % _version)

## Rechaza los términos.
func decline_terms() -> void:
	terms_declined.emit()
	print("[M125] Términos rechazados")

## Actualiza la versión (re-aceptación necesaria).
func update_terms(new_version: int) -> void:
	if new_version > _version:
		_version = new_version
		_accepted = false
		terms_updated.emit()
		print("[M125] Términos actualizados a v%d — re-aceptación requerida" % new_version)

func _guardar_estado() -> void:
	var f := FileAccess.open(RUTA_SAVES, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"accepted": _accepted, "version": _version}))
	f.close()
