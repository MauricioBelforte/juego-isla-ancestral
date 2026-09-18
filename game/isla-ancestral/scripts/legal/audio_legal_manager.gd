# Modelo: mimo-v2.5
# Plataforma: OpenCode
# Fecha: 2026-09-15
#
# M84: Música y Audio Legal — AudioLegalManager (autoload "audio_legal_manager")
# Gestiona licencias de audio, créditos, y validación legal.
# Carga data desde data/legal/audio_licenses.json.
# Sin class_name (autoload, GUIA-GODOT/INDICE.md 9.17/9.41).
#
# Integración:
# - Con M41 (Música): lee composiciones para licenciar
# - Con M78 (Legal PI): verifica propiedad intelectual
# - Con M83 (Licencias Software): coexiste con license_validator.gd
# - Con M117 (Build Pipeline): genera reporte de licencias
# - Con M131 (Créditos): comparte estructura de créditos

extends Node

const RUTA_DATA := "res://data/legal/audio_licenses.json"
const ValidatorRef = preload("res://scripts/legal/audio_license_validator.gd")
const AudioLicenseRef = preload("res://scripts/legal/audio_license.gd")
const AudioCreditRef = preload("res://scripts/legal/audio_credit.gd")

## Señales para integración
signal licencia_agregada(licencia: AudioLicense)
signal credito_agregado(credito: AudioCredit)
signal validacion_completada(errores: Array)

## Estado
var _licencias: Array[AudioLicense] = []
var _creditos: Array[AudioCredit] = []
var _datos_raw: Dictionary = {}


func _ready() -> void:
	cargar_datos()


func cargar_datos() -> void:
	var file := FileAccess.open(RUTA_DATA, FileAccess.READ)
	if not file:
		push_warning("[M84] No se pudo cargar %s" % RUTA_DATA)
		return
	var texto := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(texto)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("[M84] JSON inválido en %s" % RUTA_DATA)
		return
	_datos_raw = parsed
	_parsear_tracks()


func _parsear_tracks() -> void:
	_licencias.clear()
	for t in _datos_raw.get("tracks", []):
		var lic := AudioLicense.new()
		lic.track_id = String(t.get("id", ""))
		lic.titulo = String(t.get("titulo", ""))
		lic.autor = String(t.get("autor", ""))
		var licencia_str := String(t.get("licencia", "PROPIA"))
		lic.license_type = _mapear_licencia(licencia_str)
		lic.attribution_requerida = licencia_str == "CC-BY"
		lic.attribution_texto = String(t.get("attribution", ""))
		lic.uso_comercial = licencia_str != "CC-BY-NC"
		_licencias.append(lic)


func _mapear_licencia(licencia_str: String) -> AudioLicense.LicenseType:
	match licencia_str:
		"propia": return AudioLicense.LicenseType.PROPIA
		"MIT": return AudioLicense.LicenseType.MIT
		"CC0": return AudioLicense.LicenseType.CC0
		"CC-BY": return AudioLicense.LicenseType.CC_BY
		"CC-BY-SA": return AudioLicense.LicenseType.CC_BY_SA
		"CC-BY-NC": return AudioLicense.LicenseType.CC_BY_NC
		_: return AudioLicense.LicenseType.OTRO


## --- API pública ---


func get_licencias() -> Array[AudioLicense]:
	return _licencias


func get_creditos() -> Array[AudioCredit]:
	return _creditos


func get_cantidad_licencias() -> int:
	return _licencias.size()


func get_cantidad_creditos() -> int:
	return _creditos.size()


func agregar_licencia(licencia: AudioLicense) -> void:
	_licencias.append(licencia)
	licencia_agregada.emit(licencia)


func agregar_credito(credito: AudioCredit) -> void:
	_creditos.append(credito)
	credito_agregado.emit(credito)


func eliminar_licencia(track_id: String) -> bool:
	for i in range(_licencias.size()):
		if _licencias[i].track_id == track_id:
			_licencias.remove_at(i)
			return true
	return false


func eliminar_credito(nombre: String) -> bool:
	for i in range(_creditos.size()):
		if _creditos[i].persona_nombre == nombre:
			_creditos.remove_at(i)
			return true
	return false


func buscar_licencia(track_id: String) -> AudioLicense:
	for lic in _licencias:
		if lic.track_id == track_id:
			return lic
	return null


func buscar_credito(nombre: String) -> AudioCredit:
	for cred in _creditos:
		if cred.persona_nombre == nombre:
			return cred
	return null


## --- Validación ---


func validate_all_audio() -> Array:
	var errores: Array = []

	if _licencias.is_empty():
		errores.append("No hay licencias de audio registradas")

	for lic in _licencias:
		if lic.track_id.is_empty():
			errores.append("Licencia sin track_id")
		if lic.license_type == AudioLicense.LicenseType.CC_BY_NC:
			errores.append("Licencia CC-BY-NC no permitida: %s" % lic.track_id)
		if not lic.uso_comercial:
			errores.append("Licencia sin uso comercial: %s" % lic.track_id)
		if lic.attribution_requerida and lic.attribution_texto.is_empty():
			errores.append("CC-BY sin atribución: %s" % lic.track_id)

	for cred in _creditos:
		if cred.persona_nombre.is_empty():
			errores.append("Crédito con nombre vacío")
		if cred.rol == AudioCredit.AudioRole.OTRO:
			errores.append("Crédito con rol no definido: %s" % cred.persona_nombre)

	validacion_completada.emit(errores)
	return errores


func validate_with_json_data() -> Array:
	return ValidatorRef.validar(_datos_raw)


## --- Utilidades ---

## M84: Modo dry-run — verifica sin generar outputs
var _dry_run: bool = false

func set_dry_run(active: bool) -> void:
	_dry_run = active

func is_dry_run() -> bool:
	return _dry_run

## M84: Logging de validación de build
func validar_build() -> Dictionary:
	var errores := validate_all_audio()
	var resultado := {
		"errores": errores,
		"total_licencias": _licencias.size(),
		"total_creditos": _creditos.size(),
		"dry_run": _dry_run,
		"timestamp": Time.get_datetime_string_from_system(),
	}
	if not _dry_run and errores.is_empty():
		_generar_archivos_build()
	 resultado["archivos_generados"] = not _dry_run and errores.is_empty()
	return resultado

func _generar_archivos_build() -> void:
	var gen := AudioCreditsGenerator.new()
	var ruta_credits := "res://build/AUDIO_CREDITS.txt"
	gen.guardar_compacto(_creditos, ruta_credits)
	var ruta_reporte := "res://build/AUDIO_LICENSE_REPORT.txt"
	var file := FileAccess.open(ruta_reporte, FileAccess.WRITE)
	if file:
		file.store_string(gen.generar_reporte_licencias(_licencias))
		file.close()

## M84: Skip de validación en builds de desarrollo
var _skip_validation: bool = false

func set_skip_validation(skip: bool) -> void:
	_skip_validation = skip

func should_validate() -> bool:
	return not _skip_validation


func get_tracks_por_tipo(tipo: AudioLicense.AudioType) -> Array[AudioLicense]:
	var resultado: Array[AudioLicense] = []
	for lic in _licencias:
		if lic.audio_type == tipo:
			resultado.append(lic)
	return resultado


func get_tracks_con_atribucion() -> Array[AudioLicense]:
	var resultado: Array[AudioLicense] = []
	for lic in _licencias:
		if lic.attribution_requerida:
			resultado.append(lic)
	return resultado


func get_creditos_por_rol(rol: AudioCredit.AudioRole) -> Array[AudioCredit]:
	var resultado: Array[AudioCredit] = []
	for cred in _creditos:
		if cred.rol == rol:
			resultado.append(cred)
	return resultado


func get_resumen() -> Dictionary:
	return {
		"total_licencias": _licencias.size(),
		"total_creditos": _creditos.size(),
		"tracks_originales": get_tracks_por_tipo(AudioLicense.AudioType.COMPOSICION_ORIGINAL).size(),
		"tracks_stock": get_tracks_por_tipo(AudioLicense.AudioType.LIBRERIA_STOCK).size(),
		"tracks_ia": get_tracks_por_tipo(AudioLicense.AudioType.Generada_POR_IA).size(),
		"con_atribucion": get_tracks_con_atribucion().size(),
		"creditos_pendientes_pago": _contar_pendientes_pago(),
	}


func _contar_pendientes_pago() -> int:
	var count := 0
	for cred in _creditos:
		if not cred.es_pagado():
			count += 1
	return count
